class Invoice {
  final String id;
  final String clientName;
  final String service;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;

  Invoice({
    required this.id,
    required this.clientName,
    required this.service,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
  });

  Map<String, dynamic> toMap() => {
        'clientName': clientName,
        'service': service,
        'amount': amount,
        'dueDate': dueDate.toIso8601String(),
        'isPaid': isPaid,
      };

  factory Invoice.fromMap(String id, Map<String, dynamic> map) => Invoice(
        id: id,
        clientName: map['clientName'],
        service: map['service'],
        amount: (map['amount'] as num).toDouble(),
        dueDate: DateTime.parse(map['dueDate']),
        isPaid: map['isPaid'] ?? false,
      );
}
