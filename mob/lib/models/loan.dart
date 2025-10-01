
enum LoanStatus {
  PENDING,
  ACTIVE,
  CLOSED,
  OVERDUE,
  CANCELLED,
}


enum Currency {
  MAD,
  USD,
  EUR,
}

class Loan {
  final int id;
  final int lenderId;
  final int borrowerId;
  final double amount; // Backend uses Decimal, use double in Dart
  final Currency currency;
  final DateTime dueDate;
  final LoanStatus status;
  final bool lenderConfirmed;
  final bool borrowerConfirmed;
  final DateTime? confirmedAt;
  final int? createdById;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;
  final String? hederaTransactionId;

  Loan({
    required this.id,
    required this.lenderId,
    required this.borrowerId,
    required this.amount,
    required this.currency,
    required this.dueDate,
    required this.status,
    required this.lenderConfirmed,
    required this.borrowerConfirmed,
    this.confirmedAt,
    this.createdById,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.hederaTransactionId,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'],
      lenderId: json['lender_id'],
      borrowerId: json['borrower_id'],
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      currency: Currency.values.firstWhere(
        (e) => e.toString().split('.').last == (json['currency'] ?? 'MAD'),
        orElse: () => Currency.MAD,
      ),
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : DateTime.now(),
      status: LoanStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] ?? 'PENDING'),
        orElse: () => LoanStatus.PENDING,
      ),
      lenderConfirmed: json['lender_confirmed'] ?? false,
      borrowerConfirmed: json['borrower_confirmed'] ?? false,
      confirmedAt: json['confirmed_at'] != null ? DateTime.parse(json['confirmed_at']) : null,
      createdById: json['created_by_id'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      description: json['description']?.toString() ?? '',
      hederaTransactionId: json['hederaTransactionId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lender_id': lenderId,
      'borrower_id': borrowerId,
      'amount': amount,
      'currency': currency.toString().split('.').last,
      'due_date': dueDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'lender_confirmed': lenderConfirmed,
      'borrower_confirmed': borrowerConfirmed,
      'confirmed_at': confirmedAt?.toIso8601String(),
      'created_by_id': createdById,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'description': description,
      'hederaTransactionId': hederaTransactionId,
    };
  }
}
