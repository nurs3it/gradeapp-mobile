import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/settings.dart';
import '../../core/api/api_client.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import 'auth_controller.dart';

/// First screen (§2.2): brand zone, «Как вы войдёте?», two ways in, language.
class LoginChooseScreen extends ConsumerWidget {
  const LoginChooseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final size = MediaQuery.sizeOf(context);
    final brandH = size.height < 700 ? 300.0 : 440.0;
    final locale = ref.watch(settingsProvider).locale?.languageCode ?? Localizations.localeOf(context).languageCode;
    return Scaffold(
      backgroundColor: c.canvas,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: brandH + 40,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [GColors.brandGradTop, GColors.brand],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    Positioned(
                      right: -60,
                      top: 40,
                      child: Transform.rotate(
                        angle: -0.6,
                        child: Container(
                          width: 260,
                          height: 64,
                          decoration: ShapeDecoration(
                            color: GColors.onFill.withValues(alpha: 0.06),
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GMark(size: brandH < 400 ? 72 : 104, color: GColors.onFill),
                            const SizedBox(height: 12),
                            Text(
                              l.appName,
                              style: context.t.largeTitle.copyWith(
                                color: GColors.onFill,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.7,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l.loginTagline,
                              textAlign: TextAlign.center,
                              style: context.t.body.copyWith(color: GColors.onFill, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: brandH - 36,
            child: Container(
              decoration: ShapeDecoration(
                color: c.canvas,
                shape: const RoundedSuperellipseBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
              ),
              child: SafeArea(
                top: false,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(GSpace.gutter(context), 28, GSpace.gutter(context), 24),
                  children: [
                    Semantics(header: true, child: Text(l.loginHow, style: context.t.title1)),
                    const SizedBox(height: 16),
                    _WayCard(
                      icon: GIcons.password,
                      tint: c.primarySoft,
                      iconColor: c.primarySoftText,
                      title: l.loginWithPassword,
                      subtitle: l.loginWithPasswordHint,
                      onTap: () => context.push('/login/password'),
                    ),
                    const SizedBox(height: 10),
                    _WayCard(
                      icon: GIcons.code,
                      tint: c.goldSoft,
                      iconColor: c.goldText,
                      title: l.loginWithCode,
                      subtitle: l.loginWithCodeHint,
                      onTap: () => context.push('/login/code'),
                    ),
                    const SizedBox(height: 24),
                    GSegmented<String>(
                      height: 40,
                      values: const ['kk', 'ru', 'en'],
                      selected: locale,
                      labels: [l.langKk, l.langRu, l.langEn],
                      onChanged: (code) => ref.read(settingsProvider.notifier).setLocale(Locale(code)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WayCard extends StatelessWidget {
  const _WayCard({
    required this.icon,
    required this.tint,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color tint;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GCard(
    onTap: onTap,
    semanticLabel: '$title. $subtitle',
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: ShapeDecoration(color: tint, shape: GRadius.surface(16)),
            child: GIcon(icon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.t.bodyStrong),
                const SizedBox(height: 2),
                Text(subtitle, style: context.t.footnote.copyWith(color: context.c.ink2), maxLines: 2),
              ],
            ),
          ),
          GIcon(GIcons.chevron, size: 22, color: context.c.ink3),
        ],
      ),
    ),
  );
}

/// Shared frame of the login sub-screens: nav bar, big title, scrollable form
/// and an L button that rides above the keyboard.
class _AuthFrame extends StatelessWidget {
  const _AuthFrame({required this.title, required this.children, required this.button, this.subtitle, this.top});
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget button;
  final Widget? top;

  @override
  Widget build(BuildContext context) {
    final g = GSpace.gutter(context);
    return Scaffold(
      backgroundColor: context.c.canvas,
      appBar: GNavBar(backLabel: context.l10n.back),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(g, 8, g, 16),
                children: [
                  ?top,
                  Semantics(header: true, child: Text(title, style: context.t.title1)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(subtitle!, style: context.t.body.copyWith(color: context.c.ink2)),
                  ],
                  const SizedBox(height: 20),
                  ...children,
                ],
              ),
            ),
            Padding(padding: EdgeInsets.fromLTRB(g, 8, g, 12), child: button),
          ],
        ),
      ),
    );
  }
}

String _authError(AppLocalizations l, Object e) {
  if (isOffline(e)) return l.errorOffline;
  if (e is DioException) {
    final code = e.response?.statusCode;
    final body = e.response?.data;
    if (code == 429) return l.loginThrottled;
    if (body is Map && body['otp'] != null) return l.otpInvalid;
    final detail = body is Map ? '${body['detail'] ?? ''}'.toLowerCase() : '';
    if (detail.contains('inactive') || detail.contains('disabled') || detail.contains('blocked')) return l.loginBlocked;
    return l.loginInvalid;
  }
  return l.errorGeneric;
}

/// Login + password (+ 2FA code when the server asks).
class PasswordLoginScreen extends ConsumerStatefulWidget {
  const PasswordLoginScreen({super.key});

  @override
  ConsumerState<PasswordLoginScreen> createState() => _PasswordLoginScreenState();
}

class _PasswordLoginScreenState extends ConsumerState<PasswordLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _otp = TextEditingController();
  bool _needOtp = false;
  bool _busy = false;
  bool _obscure = true;
  String? _error;
  bool _offline = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _otp.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = context.l10n;
    if (_email.text.trim().isEmpty || _password.text.isEmpty || _busy) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
      _offline = false;
    });
    try {
      await ref.read(authProvider.notifier).login(_email.text, _password.text, otp: _needOtp ? _otp.text.trim() : null);
      final user = ref.read(authProvider).value;
      if (user != null && user.appRoles.isEmpty) {
        await ref.read(authProvider.notifier).logout();
        _error = l.loginNoRole;
      }
    } on OtpRequired {
      _needOtp = true;
    } catch (e) {
      GHaptics.error();
      _offline = isOffline(e);
      _error = _authError(l, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return _AuthFrame(
      title: l.loginTitle,
      button: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_offline) ...[
            GStateRow(title: l.errorOffline, tone: GTone.neutral, icon: GIcons.syncFailed),
            const SizedBox(height: 10),
          ],
          GButton(label: l.signIn, size: GButtonSize.l, expand: true, loading: _busy, onPressed: _submit),
        ],
      ),
      children: [
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GField(
                controller: _email,
                label: l.loginField,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                autofillHints: const [AutofillHints.username, AutofillHints.email],
                error: _offline || _needOtp ? null : _error,
              ),
              const SizedBox(height: 14),
              GField(
                controller: _password,
                label: l.password,
                obscure: _obscure,
                textInputAction: _needOtp ? TextInputAction.next : TextInputAction.go,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _submit(),
                suffix: GIconButton(
                  icon: _obscure ? GIcons.show : GIcons.hide,
                  label: _obscure ? l.showPassword : l.hidePassword,
                  size: 40,
                  background: Colors.transparent,
                  color: context.c.ink2,
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              if (_needOtp) ...[
                const SizedBox(height: 14),
                GField(
                  controller: _otp,
                  label: l.otpTitle,
                  hint: l.otpHint,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                  onSubmitted: (_) => _submit(),
                  style: context.t.title2.copyWith(letterSpacing: 6),
                  error: _offline ? null : _error,
                ),
              ],
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: GButton(
            label: l.forgotPassword,
            variant: GButtonVariant.plain,
            size: GButtonSize.s,
            onPressed: () =>
                context.push(Uri(path: '/login/reset', queryParameters: {'email': _email.text.trim()}).toString()),
          ),
        ),
      ],
    );
  }
}

/// «Код из школы» (§2.4): code → new password → «Ваш логин».
class CodeLoginScreen extends ConsumerStatefulWidget {
  const CodeLoginScreen({super.key});

  @override
  ConsumerState<CodeLoginScreen> createState() => _CodeLoginScreenState();
}

class _CodeLoginScreenState extends ConsumerState<CodeLoginScreen> {
  final _code = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  final _otp = TextEditingController();
  int _step = 0;
  bool _busy = false;
  bool _needOtp = false;
  String? _codeError;
  String? _pwError;
  String? _login;

  @override
  void initState() {
    super.initState();
    for (final c in [_pw, _pw2]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_code, _pw, _pw2, _otp]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _lenOk => _pw.text.length >= 8;
  bool get _mixOk => RegExp(r'[^\d\s]').hasMatch(_pw.text) && RegExp(r'\d').hasMatch(_pw.text);
  bool get _matchOk => _pw.text.isNotEmpty && _pw.text == _pw2.text;

  void _next() {
    final l = context.l10n;
    if (AccessCodeFormatter.normalize(_code.text).length != 10) {
      setState(() => _codeError = l.codeIncomplete);
      return;
    }
    GHaptics.selection();
    setState(() {
      _codeError = null;
      _step = 1;
    });
  }

  Future<void> _redeem() async {
    final l = context.l10n;
    if (!(_lenOk && _mixOk && _matchOk) || _busy) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _pwError = null;
    });
    try {
      final login = await ref
          .read(authProvider.notifier)
          .redeemCode(_code.text, newPassword: _pw.text, otp: _needOtp ? _otp.text.trim() : null);
      GHaptics.success();
      setState(() {
        _login = login;
        _step = 2;
      });
    } on OtpRequired {
      setState(() => _needOtp = true);
    } on DioException catch (e) {
      GHaptics.error();
      final body = e.response?.data;
      if (body is Map && body['new_password'] is List) {
        _pwError = (body['new_password'] as List).join(' ');
      } else if (body is Map && body['otp'] != null) {
        _pwError = l.otpInvalid;
      } else if (isOffline(e)) {
        _pwError = l.errorOffline;
      } else {
        // The code is wrong, used or expired: back to step 1.
        _codeError = l.codeInvalid;
        _step = 0;
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final stepLabel = Text(l.stepOf(_step + 1, 3).toUpperCase(), style: context.t.eyebrow.copyWith(color: c.ink2));
    return switch (_step) {
      0 => _AuthFrame(
        top: stepLabel,
        title: l.codeTitle,
        subtitle: l.codeHint,
        button: GButton(label: l.continueAction, size: GButtonSize.l, expand: true, onPressed: _next),
        children: [
          GField(
            controller: _code,
            hint: 'ABCDE-12345',
            autofocus: true,
            autocorrect: false,
            keyboardType: TextInputType.visiblePassword,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [AccessCodeFormatter()],
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _next(),
            style: context.t.key.copyWith(fontWeight: FontWeight.w700, letterSpacing: 2),
            error: _codeError,
          ),
        ],
      ),
      1 => _AuthFrame(
        top: stepLabel,
        title: l.codePasswordTitle,
        subtitle: l.codePasswordHint,
        button: GButton(
          label: l.continueAction,
          size: GButtonSize.l,
          expand: true,
          loading: _busy,
          onPressed: _lenOk && _mixOk && _matchOk ? _redeem : null,
        ),
        children: [
          AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GField(
                  controller: _pw,
                  label: l.password,
                  obscure: true,
                  autofocus: true,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                GField(
                  controller: _pw2,
                  label: l.codePwRepeat,
                  obscure: true,
                  autofillHints: const [AutofillHints.newPassword],
                  onSubmitted: (_) => _redeem(),
                  error: _needOtp ? null : _pwError,
                ),
                if (_needOtp) ...[
                  const SizedBox(height: 14),
                  GField(
                    controller: _otp,
                    label: l.otpTitle,
                    hint: l.otpHint,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                    error: _pwError,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final (ok, text) in [(_lenOk, l.codePwLength), (_mixOk, l.codePwMixed), (_matchOk, l.codePwMatch)])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  GIcon(ok ? GIcons.ok : GIcons.check, size: 20, color: ok ? c.ok : c.ink3, fill: ok ? 1 : 0),
                  const SizedBox(width: 8),
                  Text(text, style: context.t.callout.copyWith(color: ok ? c.ink : c.ink2)),
                ],
              ),
            ),
        ],
      ),
      _ => _AuthFrame(
        top: stepLabel,
        title: l.codeLoginTitle,
        button: GButton(
          label: l.continueAction,
          size: GButtonSize.l,
          expand: true,
          onPressed: () => ref.read(authProvider.notifier).finishCodeSignIn(),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: ShapeDecoration(color: c.okSoft, shape: GRadius.surface(GRadius.card)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.codeLoginTitle, style: context.t.subhead.copyWith(color: c.ok)),
                const SizedBox(height: 6),
                SelectableText(
                  _login ?? '',
                  style: context.t.title2.copyWith(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                GButton(
                  label: l.copy,
                  icon: GIcons.copy,
                  size: GButtonSize.s,
                  variant: GButtonVariant.surface,
                  onPressed: () {
                    unawaited(Clipboard.setData(ClipboardData(text: _login ?? '')));
                    GHaptics.light();
                    GToast.show(context, l.copied, bottomOffset: 90);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(l.codeLoginHint, style: context.t.body.copyWith(color: c.ink2)),
        ],
      ),
    };
  }
}

/// «Забыли пароль?» → email → «Проверьте почту».
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.email});
  final String? email;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  late final _email = TextEditingController(text: widget.email);
  bool _busy = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _email.text.trim();
    if (!email.contains('@') || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(apiClientProvider).requestPasswordReset(email);
      GHaptics.success();
      setState(() => _sent = true);
    } catch (e) {
      GHaptics.error();
      setState(() => _error = isOffline(e) ? context.l10n.errorOffline : context.l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    if (_sent) {
      return _AuthFrame(
        title: l.resetSentTitle,
        button: GButton(
          label: l.resetOtherEmail,
          variant: GButtonVariant.secondary,
          size: GButtonSize.l,
          expand: true,
          onPressed: () => setState(() => _sent = false),
        ),
        top: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 64,
              height: 64,
              decoration: ShapeDecoration(color: c.primarySoft, shape: GRadius.surface(22)),
              child: const Center(child: GMark(size: 44)),
            ),
          ),
        ),
        children: [Text(l.resetSentBody(_email.text.trim()), style: context.t.body.copyWith(color: c.ink2))],
      );
    }
    return _AuthFrame(
      title: l.resetTitle,
      subtitle: l.resetHint,
      button: GButton(label: l.resetSend, size: GButtonSize.l, expand: true, loading: _busy, onPressed: _send),
      children: [
        GField(
          controller: _email,
          label: l.resetEmail,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          autocorrect: false,
          autofocus: true,
          onSubmitted: (_) => _send(),
          error: _error,
        ),
      ],
    );
  }
}
