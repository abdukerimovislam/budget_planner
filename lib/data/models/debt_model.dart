import 'package:uuid/uuid.dart';

class DebtModel {
  final String id;
  final double amount;
  final String currency;
  final String personName;
  final bool isOwedToMe; // true = Мне должны (Я дал в долг), false = Я должен (Я взял в долг)
  final DateTime? dueDate; // Когда должны вернуть
  final String? description;
  final bool isPaid; // Возвращен ли долг
  final DateTime createdAt;

  DebtModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.personName,
    required this.isOwedToMe,
    this.dueDate,
    this.description,
    this.isPaid = false,
    required this.createdAt,
  });

  DebtModel copyWith({
    String? id,
    double? amount,
    String? currency,
    String? personName,
    bool? isOwedToMe,
    DateTime? dueDate,
    String? description,
    bool? isPaid,
    DateTime? createdAt,
  }) {
    return DebtModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      personName: personName ?? this.personName,
      isOwedToMe: isOwedToMe ?? this.isOwedToMe,
      dueDate: dueDate ?? this.dueDate,
      description: description ?? this.description,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'personName': personName,
      'isOwedToMe': isOwedToMe,
      'dueDate': dueDate?.toIso8601String(),
      'description': description,
      'isPaid': isPaid,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String,
      personName: map['personName'] as String,
      isOwedToMe: map['isOwedToMe'] as bool,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
      description: map['description'] as String?,
      isPaid: map['isPaid'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}