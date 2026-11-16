import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/api/api_client.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/models.dart';
import '../../core/analytics.dart';

/// What the server sent for `GET /grades/period/report_card/`.
class ReportCardFile {
  const ReportCardFile({required this.bytes, required this.name, required this.mime});
  final List<int> bytes;
  final String name;
  final String mime;
}

/// `attachment; filename*=UTF-8''%D0%A2…pdf` → the decoded file name.
String? fileNameFromDisposition(String? header) {
  if (header == null) return null;
  final star = RegExp(r"filename\*\s*=\s*(?:UTF-8|utf-8)''([^;]+)").firstMatch(header);
  if (star != null) {
    try {
      return Uri.decodeComponent(star.group(1)!.trim());
    } on FormatException {
      // fall through to the plain form
    }
  }
  final plain = RegExp(r'filename\s*=\s*"?([^";]+)"?').firstMatch(header);
  return plain?.group(1)?.trim();
}

/// A name safe for a temp file: no path separators or control characters.
String safeFileName(String name, {required String fallback}) {
  final cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), '_').trim();
  return cleaned.isEmpty ? fallback : cleaned;
}

/// The server answers a .docx when it has no PDF renderer; both are fine to share.
String mimeOfReportCard(String? contentType) {
  final base = contentType?.split(';').first.trim().toLowerCase();
  return base == null || base.isEmpty ? 'application/pdf' : base;
}

/// Why the download failed, for the toast.
enum ReportCardError { offline, denied, failed }

ReportCardError reportCardErrorOf(Object e) {
  if (isOffline(e)) return ReportCardError.offline;
  if (e is DioException && (e.response?.statusCode == 403 || e.response?.statusCode == 404)) {
    return ReportCardError.denied;
  }
  return ReportCardError.failed;
}

Future<ReportCardFile> fetchReportCard(
  Dio dio, {
  required String studentId,
  required Term term,
  required String lang,
}) async {
  final res = await dio.get<List<int>>(
    '/grades/period/report_card/',
    queryParameters: {'student': studentId, 'term': term.id, 'file_format': 'pdf', 'lang': lang},
    options: Options(responseType: ResponseType.bytes, receiveTimeout: const Duration(seconds: 60)),
  );
  final mime = mimeOfReportCard(res.headers.value(Headers.contentTypeHeader));
  final ext = mime == 'application/pdf' ? 'pdf' : 'docx';
  final name = safeFileName(
    fileNameFromDisposition(res.headers.value('content-disposition')) ?? '',
    fallback: 'report-card-${term.number}.$ext',
  );
  return ReportCardFile(bytes: res.data!, name: name, mime: mime);
}

/// «Табель за 1 четверть · PDF»: downloads the card and opens the system
/// share sheet (save to Files, AirDrop, messenger, print).
class ReportCardRow extends ConsumerStatefulWidget {
  const ReportCardRow({super.key, required this.studentId, required this.term});
  final String studentId;
  final Term term;

  @override
  ConsumerState<ReportCardRow> createState() => _ReportCardRowState();
}

class _ReportCardRowState extends ConsumerState<ReportCardRow> {
  bool _busy = false;

  Future<void> _download() async {
    if (_busy) return;
    final l = context.l10n;
    final lang = apiLang(Localizations.localeOf(context));
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    setState(() => _busy = true);
    try {
      final card = await fetchReportCard(
        ref.read(dioProvider),
        studentId: widget.studentId,
        term: widget.term,
        lang: lang,
      );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${card.name}');
      await file.writeAsBytes(card.bytes, flush: true);
      GHaptics.success();
      ref.read(analyticsProvider).track(AnalyticsEvents.reportCardDownload);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: card.mime, name: card.name)],
          sharePositionOrigin: origin,
        ),
      );
    } catch (e) {
      GHaptics.error();
      if (mounted) {
        GToast.show(context, switch (reportCardErrorOf(e)) {
          ReportCardError.offline => l.reportCardOffline,
          ReportCardError.denied => l.reportCardDenied,
          ReportCardError.failed => l.reportCardFailed,
        }, icon: GIcons.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    return GGroup(
      inset: 52,
      children: [
        GRow(
          leading: GIcon(GIcons.file, size: 22, color: c.primaryText),
          title: Text(l.reportCardRow(widget.term.name)),
          subtitle: Text(_busy ? l.reportCardPreparing : l.reportCardHint),
          trailing: _busy ? const GLoader(size: 22) : GIcon(GIcons.openInNew, size: 20, color: c.ink3),
          onTap: _busy ? null : () => unawaited(_download()),
        ),
      ],
    );
  }
}
