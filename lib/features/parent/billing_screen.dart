import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../core/json.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../auth/auth_controller.dart';
import '../common/models.dart';
import '../common/school_providers.dart';
import '../learner/report_card.dart' show fileNameFromDisposition, safeFileName;
import 'billing_models.dart';

/// Parent has the «own invoices» right (C9); the billing UI is hidden without it.
final billingVisibleProvider = Provider<bool>((ref) => ref.watch(canProvider('nav.billing_own')));

final myInvoicesProvider = StreamProvider<MyInvoices>((ref) {
  ref.watch(schoolIdProvider);
  return cachedGet(ref, '/billing/my-invoices/', parse: MyInvoices.fromJson);
});

final invoiceDetailProvider = StreamProvider.family<InvoiceDetail, String>(
  (ref, id) => cachedGet(ref, '/billing/my-invoices/$id/', parse: (d) => InvoiceDetail.fromJson(d as Json)),
);

(GTone, String, IconData) _statusStyle(AppLocalizations l, InvoiceStatus s) => switch (s) {
  InvoiceStatus.sent => (GTone.info, l.p8StatusSent, GIcons.payments),
  InvoiceStatus.partiallyPaid => (GTone.warn, l.p8StatusPartial, GIcons.pending),
  InvoiceStatus.paid => (GTone.ok, l.p8StatusPaid, GIcons.ok),
  InvoiceStatus.overdue => (GTone.bad, l.p8StatusOverdue, GIcons.error),
  InvoiceStatus.cancelled => (GTone.neutral, l.p8StatusCancelled, GIcons.close),
};

String _dueText(AppLocalizations l, String due, String loc) =>
    due.isEmpty ? '' : l.p8DueDate(Fmt.dayMonth(DateTime.parse(due), loc));

/// «К оплате 85 000 ₸ до 25.11» at the top of «Семья» (P8): the nearest
/// payable invoice. Nothing without the right or an invoice.
class PayableCard extends ConsumerWidget {
  const PayableCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(billingVisibleProvider)) return const SizedBox.shrink();
    final data = ref.watch(myInvoicesProvider).value;
    final inv = data?.nextPayable;
    if (inv == null) return const SizedBox.shrink();
    final l = context.l10n;
    final c = context.c;
    final overdue = displayStatus(inv, isoDate(DateTime.now())) == InvoiceStatus.overdue;
    final tone = overdue ? GTone.bad : GTone.info;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GCard(
        color: tone.soft(c),
        onTap: () => context.push('/billing/${inv.id}'),
        semanticLabel: l.p8PayableSemantic(fmtMoney(inv.remaining), _dueText(l, inv.dueDate, context.localeTag)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (overdue ? l.p8StatusOverdue : l.p8ToPay).toUpperCase(),
                    style: context.t.eyebrow.copyWith(color: tone.fg(c)),
                  ),
                  const SizedBox(height: 4),
                  Text('${fmtMoney(inv.remaining)} ₸', style: context.t.title1.copyWith(color: tone.fg(c))),
                  Text(
                    [if (inv.studentName.isNotEmpty) inv.studentName, _dueText(l, inv.dueDate, context.localeTag)]
                        .where((x) => x.isNotEmpty)
                        .join(' · '),
                    style: context.t.footnote.copyWith(color: tone.fg(c)),
                  ),
                ],
              ),
            ),
            GIcon(GIcons.chevron, size: 22, color: tone.fg(c)),
          ],
        ),
      ),
    );
  }
}

/// All invoices of the family.
class BillingScreen extends ConsumerWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final g = GSpace.gutter(context);
    final async = ref.watch(myInvoicesProvider);
    final today = isoDate(DateTime.now());
    final loc = context.localeTag;
    Widget row(Invoice i) {
      final st = displayStatus(i, today);
      final (tone, label, icon) = _statusStyle(l, st);
      return GRow(
        minHeight: 68,
        title: Text(i.title.isEmpty ? l.p8InvoiceNo(i.number) : i.title),
        subtitle: Text(
          [if (i.studentName.isNotEmpty) i.studentName, _dueText(l, i.dueDate, loc)].where((x) => x.isNotEmpty).join(' · '),
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${fmtMoney(i.payable ? i.remaining : i.amount)} ₸', style: context.t.bodyStrong),
            const SizedBox(height: 4),
            GStatusPill(label: label, tone: tone, icon: icon),
          ],
        ),
        onTap: () => context.push('/billing/${i.id}'),
      );
    }

    final data = async.value;
    final open = data?.invoices.where((i) => i.payable).toList() ?? const <Invoice>[];
    final rest = data?.invoices.where((i) => !i.payable).toList() ?? const <Invoice>[];
    return Scaffold(
      backgroundColor: c.canvas,
      appBar: GNavBar(backLabel: l.back),
      body: ListView(
        padding: EdgeInsets.fromLTRB(g, 8, g, 32 + MediaQuery.paddingOf(context).bottom),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Semantics(header: true, child: Text(l.p8Title, style: context.t.title1)),
          ),
          if (data == null)
            async.hasError
                ? GEmpty(
                    error: true,
                    title: l.errorTitle,
                    message: l.errorOffline,
                    action: l.retry,
                    onAction: () => ref.invalidate(myInvoicesProvider),
                  )
                : const GSkeleton(hero: false)
          else if (data.invoices.isEmpty)
            GCard(child: GEmpty(title: l.p8Empty, message: l.p8EmptyHint, icon: GIcons.payments))
          else ...[
            if (open.isNotEmpty) ...[GSectionTitle(title: l.p8ToPay), GGroup(children: [for (final i in open) row(i)])],
            if (rest.isNotEmpty) ...[GSectionTitle(title: l.p8History), GGroup(children: [for (final i in rest) row(i)])],
            if (!data.kaspiEnabled && !data.requisites.isEmpty) ...[
              GSectionTitle(title: l.p8HowToPay),
              _RequisitesCard(req: data.requisites, purpose: null),
            ],
          ],
        ],
      ),
    );
  }
}

/// One invoice: amount, payments, how to pay, PDF.
class InvoiceScreen extends ConsumerStatefulWidget {
  const InvoiceScreen({super.key, required this.invoiceId});
  final String invoiceId;

  @override
  ConsumerState<InvoiceScreen> createState() => _InvoiceState();
}

class _InvoiceState extends ConsumerState<InvoiceScreen> {
  late final AppLifecycleListener _life = AppLifecycleListener(onResume: _onResume);
  bool _opening = false;
  bool _pdfBusy = false;

  /// Set when the pay page was opened: the paid total at that moment.
  double? _awaitingBefore;
  bool _checking = false;
  bool _delayed = false;
  bool _arrived = false;

  @override
  void initState() {
    super.initState();
    _life;
  }

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  void _onResume() {
    if (_awaitingBefore != null && !_checking) unawaited(_check());
  }

  /// «Проверяем оплату»: asks the server a few times; only its answer counts.
  Future<void> _check() async {
    final before = _awaitingBefore;
    if (before == null) return;
    setState(() {
      _checking = true;
      _delayed = false;
    });
    var arrived = false;
    for (var i = 0; i < 6 && mounted; i++) {
      try {
        final res = await ref.read(dioProvider).get<Json>('/billing/my-invoices/${widget.invoiceId}/');
        ref.invalidate(invoiceDetailProvider(widget.invoiceId));
        arrived = paymentArrived(paidBefore: before, after: InvoiceDetail.fromJson(res.data!).invoice);
      } catch (_) {}
      if (arrived) break;
      await Future<void>.delayed(const Duration(seconds: 3));
    }
    if (!mounted) return;
    ref
      ..invalidate(myInvoicesProvider)
      ..invalidate(invoiceDetailProvider(widget.invoiceId));
    setState(() {
      _checking = false;
      _arrived = arrived;
      _delayed = !arrived;
      if (arrived) _awaitingBefore = null;
    });
    if (arrived) GHaptics.success();
  }

  Future<void> _pay(InvoiceDetail d) async {
    final l = context.l10n;
    final school = ref.read(schoolProvider).value?.name ?? '';
    final name = d.requisites.recipient ?? school;
    final bin = d.requisites.bin;
    final amount = fmtMoney(d.invoice.remaining);
    final ok = await confirmSheet(
      context,
      title: l.p8ConfirmTitle,
      message: bin == null ? l.p8ConfirmNoBin(name, amount) : l.p8Confirm(name, bin, amount),
      confirm: l.p8ConfirmGo,
      cancel: l.cancel,
    );
    if (!ok || !mounted) return;
    setState(() => _opening = true);
    try {
      final res = await ref.read(dioProvider).post<Json>('/billing/invoices/${d.invoice.id}/pay-online/');
      final url = res.data?.strOrNull('pay_url');
      final uri = url == null ? null : Uri.tryParse(url);
      if (uri == null || !(uri.scheme == 'https' || uri.scheme == 'http')) throw StateError('no pay_url');
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) throw StateError('cannot open');
      if (mounted) {
        setState(() {
          _awaitingBefore = d.invoice.paidTotal;
          _delayed = false;
          _arrived = false;
        });
      }
    } catch (e) {
      GHaptics.error();
      if (mounted) {
        final unavailable = e is DioException && e.response?.statusCode == 409;
        GToast.show(
          context,
          unavailable ? l.p8PayUnavailable : (isOffline(e) ? l.reportCardOffline : l.p8PayFailed),
          icon: GIcons.error,
        );
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _pdf(Invoice inv) async {
    final l = context.l10n;
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    setState(() => _pdfBusy = true);
    try {
      final res = await ref.read(dioProvider).get<List<int>>(
        '/billing/invoices/${inv.id}/pdf/',
        options: Options(responseType: ResponseType.bytes, receiveTimeout: const Duration(seconds: 60)),
      );
      final name = safeFileName(
        fileNameFromDisposition(res.headers.value('content-disposition')) ?? '',
        fallback: 'invoice-${inv.number}.pdf',
      );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$name');
      await file.writeAsBytes(res.data!, flush: true);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path, mimeType: 'application/pdf', name: name)], sharePositionOrigin: origin),
      );
    } catch (e) {
      GHaptics.error();
      if (mounted) GToast.show(context, isOffline(e) ? l.reportCardOffline : l.p8PdfFailed, icon: GIcons.error);
    } finally {
      if (mounted) setState(() => _pdfBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final g = GSpace.gutter(context);
    final async = ref.watch(invoiceDetailProvider(widget.invoiceId));
    final d = async.value;
    final loc = context.localeTag;
    Widget body;
    if (d == null) {
      body = async.hasError
          ? GEmpty(
              error: true,
              title: l.errorTitle,
              message: l.errorOffline,
              action: l.retry,
              onAction: () => ref.invalidate(invoiceDetailProvider(widget.invoiceId)),
            )
          : const GSkeleton(hero: false);
    } else {
      final inv = d.invoice;
      final st = displayStatus(inv, isoDate(DateTime.now()));
      final (tone, label, icon) = _statusStyle(l, st);
      final purpose = l.p8PurposeValue(inv.number);
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        inv.title.isEmpty ? l.p8InvoiceNo(inv.number) : inv.title,
                        style: t.footnote.copyWith(color: c.ink2),
                      ),
                    ),
                    GStatusPill(label: label, tone: tone, icon: icon),
                  ],
                ),
                const SizedBox(height: 6),
                Text('${fmtMoney(inv.payable ? inv.remaining : inv.amount)} ₸', style: t.titleXl.copyWith(fontSize: 40)),
                const SizedBox(height: 4),
                Text(
                  [
                    if (inv.studentName.isNotEmpty) inv.studentName,
                    _dueText(l, inv.dueDate, loc),
                    if (inv.payable && inv.paidTotal > 0) l.p8PaidSoFar(fmtMoney(inv.paidTotal)),
                  ].where((x) => x.isNotEmpty).join(' · '),
                  style: t.footnote.copyWith(color: c.ink2),
                ),
              ],
            ),
          ),
          if (_checking) ...[
            const SizedBox(height: 12),
            GStateRow(title: l.p8Checking, message: l.p8CheckingHint, tone: GTone.info, icon: GIcons.pending),
          ] else if (_arrived) ...[
            const SizedBox(height: 12),
            GStateRow(title: l.p8Arrived, tone: GTone.ok),
          ] else if (_delayed) ...[
            const SizedBox(height: 12),
            GStateRow(
              title: l.p8Delayed,
              message: l.p8DelayedHint,
              tone: GTone.warn,
              action: l.p8CheckNow,
              onAction: _check,
            ),
          ],
          if (inv.payable) ...[
            const SizedBox(height: 14),
            if (d.kaspiEnabled)
              GButton(
                label: l.p8Pay,
                size: GButtonSize.l,
                expand: true,
                loading: _opening,
                onPressed: () => _pay(d),
              )
            else
              GStateRow(title: l.p8OnlineOff, message: l.p8OnlineOffHint, tone: GTone.neutral),
          ],
          if (d.payments.isNotEmpty) ...[
            GSectionTitle(title: l.p8Payments),
            GGroup(
              children: [
                for (final p in d.payments)
                  GRow(
                    minHeight: GSpace.rowCompact,
                    title: Text('${fmtMoney(p.amount)} ₸'),
                    subtitle: Text(
                      [if (p.paidAt != null) Fmt.dayMonth(p.paidAt!, loc), _methodName(l, p.method)]
                          .where((x) => x.isNotEmpty)
                          .join(' · '),
                    ),
                  ),
              ],
            ),
          ],
          if (inv.payable && !d.requisites.isEmpty) ...[
            GSectionTitle(title: l.p8HowToPay),
            _RequisitesCard(req: d.requisites, purpose: purpose),
          ],
          GSectionTitle(title: l.p8Document),
          GGroup(
            inset: 52,
            children: [
              GRow(
                leading: GIcon(GIcons.file, size: 22, color: c.primaryText),
                title: Text(l.p8PdfTitle),
                subtitle: Text(l.p8PdfCaption),
                subtitleMaxLines: 2,
                trailing: _pdfBusy ? const GLoader(size: 22) : GIcon(GIcons.openInNew, size: 20, color: c.ink3),
                onTap: _pdfBusy ? null : () => unawaited(_pdf(inv)),
              ),
            ],
          ),
        ],
      );
    }
    return Scaffold(
      backgroundColor: c.canvas,
      appBar: GNavBar(backLabel: l.p8Title),
      body: ListView(padding: EdgeInsets.fromLTRB(g, 8, g, 32 + MediaQuery.paddingOf(context).bottom), children: [body]),
    );
  }
}

String _methodName(AppLocalizations l, String m) => switch (m) {
  'kaspi' => 'Kaspi',
  'cash' => l.p8MethodCash,
  'bank_transfer' => l.p8MethodTransfer,
  _ => '',
};

/// Transfer details (recipient, БИН, IBAN…): tap a row to copy it.
class _RequisitesCard extends StatelessWidget {
  const _RequisitesCard({required this.req, required this.purpose});
  final Requisites req;
  final String? purpose;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    String label(String k) => switch (k) {
      'recipient' => l.p8ReqRecipient,
      'bin' => l.p8ReqBin,
      'iban' => 'IBAN',
      'bank' => l.p8ReqBank,
      'bik' => l.p8ReqBik,
      'kbe' => l.p8ReqKbe,
      'knp' => l.p8ReqKnp,
      _ => l.p8ReqPurpose,
    };
    final rows = [
      for (final k in Requisites.keys)
        if (req.values[k]?.trim().isNotEmpty ?? false) (k, req.values[k]!.trim()),
      if (purpose != null && (req.values['purpose'] ?? '').trim().isEmpty) ('purpose', purpose!),
    ];
    return GGroup(
      children: [
        for (final (k, v) in rows)
          GRow(
            title: Text(v),
            titleMaxLines: 3,
            subtitle: Text(label(k)),
            trailing: GIcon(GIcons.copy, size: 20, color: c.ink3, semanticLabel: l.p8Copy),
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: v));
              if (context.mounted) GToast.show(context, l.p8Copied);
            },
          ),
      ],
    );
  }
}
