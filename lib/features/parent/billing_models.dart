import '../../core/json.dart';

/// Invoice status as the backend names it (`billing.InvoiceStatus`).
enum InvoiceStatus { sent, partiallyPaid, paid, overdue, cancelled }

InvoiceStatus invoiceStatusOf(String s) => switch (s) {
  'partially_paid' => InvoiceStatus.partiallyPaid,
  'paid' => InvoiceStatus.paid,
  'overdue' => InvoiceStatus.overdue,
  'cancelled' => InvoiceStatus.cancelled,
  _ => InvoiceStatus.sent,
};

class Invoice {
  const Invoice({
    required this.id,
    required this.number,
    required this.amount,
    required this.paidTotal,
    required this.dueDate,
    required this.status,
    this.studentName = '',
    this.planName = '',
    this.periodLabel = '',
    this.currency = 'KZT',
  });

  final String id;
  final String number;
  final double amount;
  final double paidTotal;
  final String dueDate;
  final InvoiceStatus status;
  final String studentName;
  final String planName;
  final String periodLabel;
  final String currency;

  /// Still to pay.
  double get remaining => (amount - paidTotal).clamp(0, double.infinity).toDouble();

  bool get payable => status == InvoiceStatus.sent || status == InvoiceStatus.partiallyPaid || status == InvoiceStatus.overdue;

  String get title => [planName, periodLabel].where((s) => s.isNotEmpty).join(' · ');

  factory Invoice.fromJson(Json j) => Invoice(
    id: j.str('id'),
    number: j.str('number'),
    amount: j.number('amount')?.toDouble() ?? 0,
    paidTotal: j.number('paid_total')?.toDouble() ?? 0,
    dueDate: j.str('due_date'),
    status: invoiceStatusOf(j.str('status')),
    studentName: j.str('student_name'),
    planName: j.str('plan_name'),
    periodLabel: j.str('period_label'),
    currency: j.strOrNull('currency') ?? 'KZT',
  );
}

class InvoicePayment {
  const InvoicePayment({required this.amount, required this.method, required this.status, this.paidAt});
  final double amount;
  final String method;
  final String status;
  final DateTime? paidAt;

  factory InvoicePayment.fromJson(Json j) => InvoicePayment(
    amount: j.number('amount')?.toDouble() ?? 0,
    method: j.str('method'),
    status: j.str('status'),
    paidAt: DateTime.tryParse(j.str('paid_at'))?.toLocal(),
  );
}

/// School's payment details (`payment_requisites`): free-form config of the
/// manual provider. Known keys are shown in a fixed order.
class Requisites {
  const Requisites(this.values);
  final Map<String, String> values;

  static const keys = ['recipient', 'bin', 'iban', 'bank', 'bik', 'kbe', 'knp', 'purpose'];

  /// Who is paid: the legal recipient, shown before leaving the app.
  String? get recipient => _v('recipient');
  String? get bin => _v('bin');
  String? _v(String k) => (values[k] ?? '').trim().isEmpty ? null : values[k]!.trim();

  bool get isEmpty => keys.every((k) => _v(k) == null);

  factory Requisites.fromJson(Object? raw) => Requisites({
    if (raw is Map<String, dynamic>)
      for (final e in raw.entries)
        if (e.value is String || e.value is num) e.key: '${e.value}',
  });
}

/// `GET /billing/my-invoices/`.
class MyInvoices {
  const MyInvoices({required this.invoices, required this.requisites, required this.kaspiEnabled});
  final List<Invoice> invoices;
  final Requisites requisites;
  final bool kaspiEnabled;

  Invoice? get nextPayable {
    final list = invoices.where((i) => i.payable).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list.firstOrNull;
  }

  factory MyInvoices.fromJson(Object? d) {
    final j = d is Json ? d : <String, dynamic>{};
    return MyInvoices(
      invoices: resultsOf(d).map(Invoice.fromJson).toList(),
      requisites: Requisites.fromJson(j['payment_requisites']),
      kaspiEnabled: j.flag('kaspi_enabled'),
    );
  }
}

/// `GET /billing/my-invoices/{id}/`.
class InvoiceDetail {
  const InvoiceDetail({required this.invoice, required this.payments, required this.requisites, required this.kaspiEnabled});
  final Invoice invoice;
  final List<InvoicePayment> payments;
  final Requisites requisites;
  final bool kaspiEnabled;

  factory InvoiceDetail.fromJson(Json j) => InvoiceDetail(
    invoice: Invoice.fromJson(j),
    payments: j.list('payments', InvoicePayment.fromJson),
    requisites: Requisites.fromJson(j['payment_requisites']),
    kaspiEnabled: j.flag('kaspi_enabled'),
  );
}

/// Status shown to the parent: a sent invoice past its due date is overdue
/// even before the server's nightly job says so.
InvoiceStatus displayStatus(Invoice i, String today) =>
    (i.status == InvoiceStatus.sent || i.status == InvoiceStatus.partiallyPaid) && i.dueDate.isNotEmpty && i.dueDate.compareTo(today) < 0
    ? InvoiceStatus.overdue
    : i.status;

/// The server confirmed a payment: the invoice is paid, or more was paid than
/// before. The client never marks anything paid by itself.
bool paymentArrived({required double paidBefore, required Invoice after}) =>
    after.status == InvoiceStatus.paid ||
    (after.status == InvoiceStatus.partiallyPaid && after.paidTotal > paidBefore + 0.001);

/// «85 000» (no currency): thin groups, no decimals when whole.
String fmtMoney(num v) {
  final whole = v == v.roundToDouble();
  final s = whole ? v.round().toString() : v.toStringAsFixed(2);
  final parts = s.split('.');
  final grouped = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
  return parts.length > 1 ? '$grouped,${parts[1]}' : grouped;
}
