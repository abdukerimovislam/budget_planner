import '../../data/models/expense_category.dart';
import 'insight_type.dart';

class InsightModel {
  final String id;
  final InsightType type;
  final String titleKey;
  final String descriptionKey;
  final Map<String, String> params;
  final ExpenseCategory? category;

  const InsightModel({
    required this.id,
    required this.type,
    required this.titleKey,
    required this.descriptionKey,
    this.params = const {},
    this.category,
  });
}