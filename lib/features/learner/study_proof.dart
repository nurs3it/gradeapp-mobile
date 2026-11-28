import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/json.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import 'learner_providers.dart';

/// S14 «Справка об обучении»: the parent or the student asks the school
/// office for a study proof; once issued, the PDF opens and the check link
/// can be shared. API: `/certificates/study-proof-requests/`.

enum ProofRequestStatus { pending, issued, declined }

class IssuedProof {
  const IssuedProof({required this.number, this.issuedAt, this.verifyUrl, this.pdfUrl});
  final String number;
  final DateTime? issuedAt;
  final String? verifyUrl;
  final String? pdfUrl;

  factory IssuedProof.fromJson(Json j) => IssuedProof(
    number: j.str('display_number'),
    issuedAt: DateTime.tryParse(j.str('issued_at'))?.toLocal(),
    verifyUrl: j.strOrNull('verify_url'),
    pdfUrl: j.strOrNull('pdf_url'),
  );
}

class ProofRequest {
  const ProofRequest({
    required this.id,
    required this.status,
    this.purpose = '',
    this.declineReason = '',
    this.createdAt,
    this.proof,
  });

  final String id;
  final ProofRequestStatus status;
  final String purpose;
  final String declineReason;
  final DateTime? createdAt;
  final IssuedProof? proof;

  factory ProofRequest.fromJson(Json j) => ProofRequest(
    id: j.str('id'),
    status: switch (j.str('status')) {
      'issued' => ProofRequestStatus.issued,
      'declined' => ProofRequestStatus.declined,
      _ => ProofRequestStatus.pending,
    },
    purpose: j.str('purpose'),
    declineReason: j.str('decline_reason'),
    createdAt: DateTime.tryParse(j.str('created_at'))?.toLocal(),
    proof: j['study_proof'] is Json ? IssuedProof.fromJson(j['study_proof'] as Json) : null,
  );
}

/// Newest first; a new request is possible only without a pending one.
bool canRequestProof(List<ProofRequest> list) => !list.any((r) => r.status == ProofRequestStatus.pending);

final proofRequestsProvider = StreamProvider.family<List<ProofRequest>, String>(
  (ref, studentId) => cachedGet(
    ref,
    '/certificates/study-proof-requests/',
    query: {'student_id': studentId},
    parse: (d) => parseList(d, ProofRequest.fromJson)
      ..sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000))),
  ),
);

class StudyProofScreen extends ConsumerWidget {
  const StudyProofScreen({super.key, this.studentId});
  final String? studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final g = GSpace.gutter(context);
    final id = studentId ?? ref.watch(learnerIdProvider);
    final async = id == null ? null : ref.watch(proofRequestsProvider(id));
    final list = async?.value;
    return Scaffold(
      backgroundColor: c.canvas,
      appBar: GNavBar(backLabel: l.back),
      body: CustomScrollView(
        slivers: [
          GRefreshControl(onRefresh: () async => ref.invalidate(proofRequestsProvider)),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(g, 8, g, 32 + MediaQuery.paddingOf(context).bottom),
            sliver: SliverList.list(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Semantics(header: true, child: Text(l.s14Title, style: context.t.title1)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 16),
                  child: Text(l.s14Hint, style: context.t.footnote.copyWith(color: c.ink2)),
                ),
                if (list == null)
                  async != null && async.hasError
                      ? GEmpty(
                          error: true,
                          title: l.errorTitle,
                          message: l.errorOffline,
                          action: l.retry,
                          onAction: () => ref.invalidate(proofRequestsProvider),
                        )
                      : const GSkeleton(hero: false)
                else ...[
                  if (canRequestProof(list))
                    GButton(
                      label: l.s14Request,
                      icon: GIcons.add,
                      onPressed: id == null ? null : () => unawaited(_request(context, ref, id)),
                    ),
                  if (list.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: GCard(child: GEmpty(title: l.s14Empty, icon: GIcons.file)),
                    )
                  else ...[
                    const SizedBox(height: 16),
                    GGroup(inset: 16, children: [for (final r in list) _RequestRow(r: r)]),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _request(BuildContext context, WidgetRef ref, String studentId) async {
    final l = context.l10n;
    final purpose = TextEditingController();
    var lang = Localizations.localeOf(context).languageCode == 'kk' ? 'kz' : 'ru';
    final ok = await showGSheet<bool>(
      context,
      title: l.s14Request,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GField(controller: purpose, label: l.s14Purpose, hint: l.s14PurposeHint, maxLines: 2, minLines: 1),
              const SizedBox(height: 14),
              Text(l.s14Language, style: ctx.t.subhead.copyWith(color: ctx.c.ink2)),
              const SizedBox(height: 6),
              GSegmented<String>(
                values: const ['ru', 'kz', 'en'],
                labels: const ['Русский', 'Қазақша', 'English'],
                selected: lang,
                onChanged: (v) => setState(() => lang = v),
              ),
              const SizedBox(height: 18),
              GButton(label: l.s14Send, onPressed: () => Navigator.of(ctx).pop(true)),
            ],
          ),
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(dioProvider).post<Json>(
        '/certificates/study-proof-requests/',
        data: {'student': studentId, 'purpose': purpose.text.trim(), 'language': lang},
      );
      ref.invalidate(proofRequestsProvider(studentId));
      GHaptics.success();
      if (context.mounted) GToast.show(context, l.s14Sent, icon: GIcons.ok);
    } on DioException catch (e) {
      if (!context.mounted) return;
      final pending = e.response?.statusCode == 409;
      GToast.show(context, pending ? l.s14AlreadyPending : l.errorOffline, icon: GIcons.error);
      if (pending) ref.invalidate(proofRequestsProvider(studentId));
    }
  }
}

/// The PDF needs the session: downloaded here, then the share sheet
/// (save to Files, print, send).
Future<void> _sharePdf(BuildContext context, WidgetRef ref, IssuedProof proof) async {
  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  try {
    final res = await ref.read(dioProvider).get<List<int>>(
      proof.pdfUrl!,
      options: Options(responseType: ResponseType.bytes, receiveTimeout: const Duration(seconds: 60)),
    );
    final dir = await getTemporaryDirectory();
    final name = 'spravka-${proof.number.replaceAll('/', '-')}.pdf';
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(res.data!, flush: true);
    GHaptics.success();
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: 'application/pdf', name: name)], sharePositionOrigin: origin),
    );
  } catch (_) {
    GHaptics.error();
    if (context.mounted) GToast.show(context, context.l10n.errorOffline, icon: GIcons.error);
  }
}

class _RequestRow extends ConsumerWidget {
  const _RequestRow({required this.r});
  final ProofRequest r;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final proof = r.proof;
    final (label, tone) = switch (r.status) {
      ProofRequestStatus.pending => (l.s14Pending, GTone.warn),
      ProofRequestStatus.issued => (proof == null ? l.s14Issued : l.s14IssuedNo(proof.number), GTone.ok),
      ProofRequestStatus.declined => (l.s14Declined, GTone.bad),
    };
    final when = r.createdAt == null ? '' : Fmt.dayMonth(r.createdAt!, context.localeTag);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: t.headline.copyWith(color: tone.fg(c)))),
              Text(when, style: t.footnote.copyWith(color: c.ink3)),
            ],
          ),
          if (r.purpose.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(r.purpose, style: t.body.copyWith(color: c.ink2)),
          ],
          if (r.status == ProofRequestStatus.declined && r.declineReason.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(r.declineReason, style: t.footnote.copyWith(color: c.ink2)),
          ],
          if (proof != null && (proof.pdfUrl != null || proof.verifyUrl != null)) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (proof.pdfUrl != null)
                  GButton(
                    label: l.s14OpenPdf,
                    icon: GIcons.file,
                    size: GButtonSize.s,
                    variant: GButtonVariant.tinted,
                    onPressed: () => unawaited(_sharePdf(context, ref, proof)),
                  ),
                if (proof.pdfUrl != null && proof.verifyUrl != null) const SizedBox(width: 8),
                if (proof.verifyUrl != null)
                  GButton(
                    label: l.s14Share,
                    icon: GIcons.forward,
                    size: GButtonSize.s,
                    variant: GButtonVariant.plain,
                    onPressed: () => unawaited(SharePlus.instance.share(ShareParams(text: l.s14ShareText(proof.number, proof.verifyUrl!)))),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
