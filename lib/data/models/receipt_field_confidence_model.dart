class ReceiptFieldConfidenceModel {
  final double amount;
  final double merchant;
  final double currency;
  final double date;

  const ReceiptFieldConfidenceModel({
    required this.amount,
    required this.merchant,
    required this.currency,
    required this.date,
  });
}