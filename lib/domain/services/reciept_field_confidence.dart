class ReceiptFieldConfidence {
  final double amount;
  final double merchant;
  final double currency;
  final double date;

  const ReceiptFieldConfidence({
    required this.amount,
    required this.merchant,
    required this.currency,
    required this.date,
  });
}