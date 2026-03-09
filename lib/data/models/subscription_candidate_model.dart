class SubscriptionCandidateModel {
  final String merchant;
  final double averageAmount;
  final int occurrences;
  final int averageIntervalDays;
  final double estimatedMonthlyCost;

  const SubscriptionCandidateModel({
    required this.merchant,
    required this.averageAmount,
    required this.occurrences,
    required this.averageIntervalDays,
    required this.estimatedMonthlyCost,
  });
}