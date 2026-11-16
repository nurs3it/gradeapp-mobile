import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/models.dart';
import '../common/school_providers.dart';
import '../learner/learner_providers.dart';
import 'check_in_state.dart';

enum _Stage { explain, camera, preview, sending, success, unavailable, denied }

/// «Я в школе» 2.0 (S2, §3.2): explainer on first use → own front camera with
/// an oval → preview → send with progress → «Отмечено». Location is looked up
/// while the camera opens, so the student never waits for GPS after the shot.
class CheckInFlow extends ConsumerStatefulWidget {
  const CheckInFlow({super.key});

  @override
  ConsumerState<CheckInFlow> createState() => _CheckInFlowState();
}

class _CheckInFlowState extends ConsumerState<CheckInFlow> with WidgetsBindingObserver {
  static const _explainedKey = 'checkin_explained';

  _Stage _stage = _Stage.camera;
  CameraController? _camera;
  XFile? _shot;
  bool _flash = false;
  bool _flashing = false;
  Position? _pos;
  bool _locating = false;
  bool _locDone = false;
  Timer? _autoClose;

  CheckInStatus? get _status {
    final id = ref.read(myStudentIdProvider);
    if (id == null) return null;
    return ref.read(learnerDayProvider((studentId: id, date: isoDate(DateTime.now())))).value?.checkIn;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.read(checkInProvider.notifier).reset();
    unawaited(_start());
  }

  Future<void> _start() async {
    final explained = await ref.read(prefsProvider).read(_explainedKey) == true;
    if (!explained) {
      setState(() => _stage = _Stage.explain);
      return;
    }
    await _openCamera();
  }

  Future<void> _openCamera() async {
    setState(() => _stage = _Stage.camera);
    if (_status?.geofence ?? false) unawaited(_locate());
    try {
      final cams = await availableCameras();
      final front = cams.where((c) => c.lensDirection == CameraLensDirection.front).firstOrNull ?? cams.firstOrNull;
      if (front == null) {
        if (mounted) setState(() => _stage = _Stage.unavailable);
        return;
      }
      final ctrl = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await ctrl.initialize();
      await ctrl.setFlashMode(FlashMode.off);
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      setState(() => _camera = ctrl);
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(
        () => _stage = e.code.contains('Denied') || e.code.contains('denied') ? _Stage.denied : _Stage.unavailable,
      );
    }
  }

  Future<void> _locate() async {
    setState(() => _locating = true);
    final p = await CheckInController.locate();
    if (!mounted) return;
    setState(() {
      _pos = p;
      _locating = false;
      _locDone = true;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cam = _camera;
    if (cam == null || !cam.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _camera = null;
      unawaited(cam.dispose());
    } else if (state == AppLifecycleState.resumed && _stage == _Stage.camera) {
      unawaited(_openCamera());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoClose?.cancel();
    unawaited(_camera?.dispose());
    super.dispose();
  }

  Future<void> _shoot() async {
    final cam = _camera;
    if (cam == null || !cam.value.isInitialized || cam.value.isTakingPicture) return;
    GHaptics.medium();
    if (_flash) {
      setState(() => _flashing = true);
      await Future<void>.delayed(const Duration(milliseconds: 180));
    }
    try {
      final shot = await cam.takePicture();
      if (mounted) setState(() => _shot = shot);
      if (mounted) setState(() => _stage = _Stage.preview);
    } on CameraException {
      GHaptics.error();
    } finally {
      if (mounted) setState(() => _flashing = false);
    }
  }

  /// Fallback for devices without a usable camera (old Android, simulator).
  Future<void> _systemPicker() async {
    final photo = await ImagePicker().pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 1280,
      imageQuality: 85,
    );
    if (photo == null || !mounted) return;
    setState(() {
      _shot = photo;
      _stage = _Stage.preview;
    });
  }

  Future<void> _send() async {
    final shot = _shot;
    if (shot == null) return;
    setState(() => _stage = _Stage.sending);
    var pos = _pos;
    if ((_status?.geofence ?? false) && pos == null) pos = await CheckInController.locate();
    final ok = await ref
        .read(checkInProvider.notifier)
        .submit(photoPath: shot.path, lat: pos?.latitude, lon: pos?.longitude);
    if (!mounted) return;
    if (ok) {
      setState(() => _stage = _Stage.success);
      _autoClose = Timer(const Duration(seconds: 4), _close);
    } else {
      GHaptics.error();
      // Errors live in the card on «Сегодня» with one action (§3.15).
      unawaited(Navigator.of(context).maybePop());
    }
  }

  void _close() {
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final dark = buildTheme(Brightness.dark);
    return Theme(
      data: _stage == _Stage.explain ? Theme.of(context) : dark,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: _stage == _Stage.explain ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        child: Builder(
          builder: (context) => switch (_stage) {
            _Stage.explain => _Explain(
              onContinue: () async {
                await ref.read(prefsProvider).write(_explainedKey, true);
                await _openCamera();
              },
              onClose: _close,
            ),
            _Stage.success => _Success(onDone: _close, status: _status),
            _ => Scaffold(
              backgroundColor: GColors.camera,
              body: Stack(
                fit: StackFit.expand,
                children: [
                  _viewfinder(context),
                  _chrome(context, l),
                  if (_flashing) const ColoredBox(color: GColors.onFill),
                ],
              ),
            ),
          },
        ),
      ),
    );
  }

  Widget _viewfinder(BuildContext context) {
    final cam = _camera;
    if (_stage == _Stage.preview || _stage == _Stage.sending) {
      return _shot == null
          ? const SizedBox.shrink()
          : Image.file(
              File(_shot!.path),
              fit: BoxFit.cover,
              cacheWidth: (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).round(),
            );
    }
    if (cam == null || !cam.value.isInitialized) return const ColoredBox(color: GColors.camera);
    final size = MediaQuery.sizeOf(context);
    final ratio = cam.value.aspectRatio;
    return ClipRect(
      child: OverflowBox(
        maxHeight: double.infinity,
        maxWidth: double.infinity,
        child: SizedBox(width: size.width, height: size.width * ratio, child: CameraPreview(cam)),
      ),
    );
  }

  Widget _chrome(BuildContext context, AppLocalizations l) {
    final t = context.t;
    final c = context.c;
    final status = _status;
    final run = ref.watch(checkInProvider);
    final sending = _stage == _Stage.sending;
    final school = ref.watch(schoolProvider).value;
    final far =
        _pos != null &&
        school?.lat != null &&
        Geolocator.distanceBetween(_pos!.latitude, _pos!.longitude, school!.lat!, school.lon!) > 300;
    final geo = status?.geofence ?? false;
    final (String pill, Color pillBg, bool loading) = !geo
        ? (l.camWindowUntil(status?.windowEnd ?? ''), GColors.onFill.withValues(alpha: 0.16), false)
        : _locating || !_locDone
        ? (l.camLocating, GColors.onFill.withValues(alpha: 0.16), true)
        : far || _pos == null
        ? (_pos == null ? l.checkInNeedLocation : l.camFar, GColors.badFill.withValues(alpha: 0.32), false)
        : (l.camAtSchool(status?.windowEnd ?? ''), GColors.okFill.withValues(alpha: 0.35), false);
    final top = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        Positioned.fill(
          child: _OvalOverlay(
            arc: !geo ? 1 : (_pos == null ? (_locating ? 0.25 : 0) : 1),
            progress: sending ? run.progress : null,
            arcColor: c.ok,
          ),
        ),
        Positioned(
          top: top + 8,
          left: 16,
          right: 16,
          child: Row(
            children: [
              GIconButton(
                icon: GIcons.close,
                label: l.close,
                background: GColors.onFill.withValues(alpha: 0.16),
                color: GColors.onFill,
                onPressed: _close,
              ),
              Expanded(
                child: Text(
                  l.checkInTitle,
                  textAlign: TextAlign.center,
                  style: t.headline.copyWith(color: GColors.onFill),
                ),
              ),
              GIconButton(
                icon: _flash ? GIcons.flash : GIcons.flashOff,
                label: _flash ? l.camFlashOff : l.camFlashOn,
                background: GColors.onFill.withValues(alpha: _flash ? 0.9 : 0.16),
                color: _flash ? GColors.camera : GColors.onFill,
                onPressed: () => setState(() => _flash = !_flash),
              ),
            ],
          ),
        ),
        Positioned(
          top: top + 66,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: ShapeDecoration(color: pillBg, shape: const StadiumBorder()),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (loading) ...[const GLoader(size: 18, color: GColors.onFill), const SizedBox(width: 8)],
                  Text(pill, style: t.subhead.copyWith(color: GColors.onFill)),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: MediaQuery.paddingOf(context).bottom + 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                switch (_stage) {
                  _Stage.sending => l.checkInSendingPct((run.progress * 100).round()),
                  _Stage.unavailable => l.camUnavailable,
                  _Stage.denied => l.camDenied,
                  _ => l.camHint,
                },
                textAlign: TextAlign.center,
                style: t.title2.copyWith(color: GColors.onFill),
              ),
              const SizedBox(height: 6),
              Text(
                l.camPrivacy,
                textAlign: TextAlign.center,
                style: t.subhead.copyWith(color: GColors.onFill.withValues(alpha: 0.78), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              switch (_stage) {
                _Stage.preview => Row(
                  children: [
                    Expanded(
                      child: GButton(
                        label: l.camRetake,
                        variant: GButtonVariant.secondary,
                        size: GButtonSize.l,
                        expand: true,
                        onPressed: () => setState(() {
                          _shot = null;
                          _stage = _Stage.camera;
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GButton(label: l.send, size: GButtonSize.l, expand: true, onPressed: _send),
                    ),
                  ],
                ),
                _Stage.sending => const SizedBox(height: 56),
                _Stage.unavailable => GButton(
                  label: l.checkInOpenCamera,
                  size: GButtonSize.l,
                  expand: true,
                  onPressed: _systemPicker,
                ),
                _Stage.denied => GButton(
                  label: l.openSettings,
                  size: GButtonSize.l,
                  expand: true,
                  onPressed: () => unawaited(Geolocator.openAppSettings()),
                ),
                _ => _Shutter(label: l.camShutter, onTap: _camera == null ? null : _shoot),
              },
            ],
          ),
        ),
      ],
    );
  }
}

/// Dimmed outside the 270 × 350 oval, white 3 pt outline; a green arc grows
/// as the location fix arrives; while sending the outline is the progress.
class _OvalOverlay extends StatelessWidget {
  const _OvalOverlay({required this.arc, required this.arcColor, this.progress});
  final double arc;
  final double? progress;
  final Color arcColor;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: RepaintBoundary(
      child: CustomPaint(
        painter: _OvalPainter(arc: arc, progress: progress, arcColor: arcColor),
      ),
    ),
  );
}

class _OvalPainter extends CustomPainter {
  _OvalPainter({required this.arc, required this.arcColor, this.progress});
  final double arc;
  final double? progress;
  final Color arcColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = math.min(270.0, size.width - 80);
    final h = w * 350 / 270;
    final oval = Rect.fromCenter(center: Offset(size.width / 2, size.height * 0.43), width: w, height: h);
    final dim = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addOval(oval);
    canvas.drawPath(dim, Paint()..color = GColors.camera.withValues(alpha: 0.62));
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = GColors.onFill;
    if (progress != null) {
      canvas.drawOval(oval, stroke..color = GColors.onFill.withValues(alpha: 0.3));
      canvas.drawArc(
        oval.inflate(4),
        -math.pi / 2,
        2 * math.pi * progress!.clamp(0.02, 1.0),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..color = GColors.onFill,
      );
      return;
    }
    canvas.drawOval(oval, stroke);
    if (arc > 0) {
      canvas.drawArc(
        oval.inflate(6),
        -math.pi / 2,
        2 * math.pi * 0.35 * arc,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = arcColor,
      );
    }
  }

  @override
  bool shouldRepaint(_OvalPainter old) => old.arc != arc || old.progress != progress;
}

class _Shutter extends StatelessWidget {
  const _Shutter({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GPressable(
    onTap: onTap,
    scale: 0.9,
    semanticLabel: label,
    excludeChildSemantics: true,
    child: Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: GColors.onFill, width: 4),
      ),
      padding: const EdgeInsets.all(4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: onTap == null ? GColors.onFill.withValues(alpha: 0.4) : GColors.onFill,
          shape: BoxShape.circle,
        ),
      ),
    ),
  );
}

/// Explainer before the first camera request (C3).
class _Explain extends StatelessWidget {
  const _Explain({required this.onContinue, required this.onClose});
  final VoidCallback onContinue;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final g = GSpace.gutter(context);
    return Scaffold(
      backgroundColor: c.canvas,
      appBar: GNavBar(onBack: onClose, backLabel: l.close),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(g, 16, g, 16),
                children: [
                  Center(
                    child: Container(
                      width: 88,
                      height: 108,
                      decoration: ShapeDecoration(color: c.primarySoft, shape: const OvalBorder()),
                      child: const Center(child: GMark(size: 52)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(l.camExplainTitle, style: context.t.title1, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  for (final (icon, text) in [
                    (GIcons.checkIn, l.camExplainWhy),
                    (GIcons.lock, l.camExplainWho),
                    (GIcons.clock, l.camExplainKeep),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: [
                          GIcon(icon, size: 22, color: c.primaryText),
                          const SizedBox(width: 12),
                          Expanded(child: Text(text, style: context.t.body)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(g, 8, g, 12),
              child: Column(
                children: [
                  GButton(label: l.continueAction, size: GButtonSize.l, expand: true, onPressed: onContinue),
                  const SizedBox(height: 4),
                  GButton(label: l.notNow, variant: GButtonVariant.plain, foreground: c.ink2, onPressed: onClose),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// «Отмечено» (§3.2): the mark unfolds as a fan, success haptic as the last
/// page lands, closes itself after 4 s.
class _Success extends ConsumerStatefulWidget {
  const _Success({required this.onDone, required this.status});
  final VoidCallback onDone;
  final CheckInStatus? status;

  @override
  ConsumerState<_Success> createState() => _SuccessState();
}

class _SuccessState extends ConsumerState<_Success> {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.t;
    final run = ref.watch(checkInProvider);
    final at = run.at ?? DateTime.now();
    final time = Fmt.clock(at);
    final end = widget.status?.windowEnd;
    final id = ref.watch(myStudentIdProvider);
    final day = id == null ? null : ref.watch(learnerDayProvider((studentId: id, date: isoDate(at)))).value;
    final first = day?.lessons.where((x) => !x.isCancelled && !x.isPast(at)).firstOrNull;
    final firstStart = first?.startsAt();
    final lateMin = firstStart != null && at.isAfter(firstStart) ? at.difference(firstStart).inMinutes : 0;
    final late =
        (day?.checkIn?.late ?? false) || lateMin > 0 || (end != null && at.hour * 60 + at.minute > minutesOf(end));
    return Scaffold(
      backgroundColor: GColors.brand,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: GSpace.gutter(context)),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const GMarkUnfold(onDone: GHaptics.success),
              const SizedBox(height: 20),
              Semantics(
                liveRegion: true,
                child: Text(l.doneTitle, style: t.titleXl.copyWith(color: GColors.onFill, fontSize: 44)),
              ),
              const SizedBox(height: 6),
              Text(
                late ? (lateMin > 0 ? l.doneLateMin(time, lateMin) : l.doneLate(time)) : l.doneOnTime(time),
                style: t.title2.copyWith(color: GColors.onFill.withValues(alpha: 0.9), fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (first != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: ShapeDecoration(
                    color: GColors.onFill.withValues(alpha: 0.14),
                    shape: GRadius.surface(GRadius.card),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 40,
                        decoration: const ShapeDecoration(color: GColors.onFill, shape: StadiumBorder()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.doneFirstLesson(hm(first.start)).toUpperCase(),
                              style: t.eyebrow.copyWith(color: GColors.onFill.withValues(alpha: 0.85)),
                            ),
                            Text(
                              [first.subject, if (first.room != null) l.room(first.room!)].join(' · '),
                              style: t.bodyStrong.copyWith(color: GColors.onFill),
                            ),
                          ],
                        ),
                      ),
                      if (firstStart != null && firstStart.isAfter(at))
                        Text(
                          l.inMinutes(firstStart.difference(at).inMinutes),
                          style: t.subhead.copyWith(color: GColors.onFill),
                        ),
                    ],
                  ),
                )
              else
                Text(
                  l.doneParents,
                  textAlign: TextAlign.center,
                  style: t.body.copyWith(color: GColors.onFill),
                ),
              const SizedBox(height: 24),
              GButton(
                label: l.done,
                variant: GButtonVariant.onColor,
                size: GButtonSize.l,
                expand: true,
                onPressed: widget.onDone,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
