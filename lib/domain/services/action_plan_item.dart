enum ActionPlanType {
  saveMore,
  cutCategory,
  reduceSubscriptions,
  improveBudgetDiscipline,
}

class ActionPlanItem {
  final ActionPlanType type;
  final String titleKey;
  final String descriptionKey;
  final Map<String, String> params;
  final bool isPriority;

  const ActionPlanItem({
    required this.type,
    required this.titleKey,
    required this.descriptionKey,
    this.params = const {},
    this.isPriority = false,
  });
}