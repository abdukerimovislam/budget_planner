class AchievementModel {
  final String id;
  final String titleKey;
  final String subtitleKey;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AchievementModel({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.isUnlocked,
    required this.unlockedAt,
  });

  AchievementModel copyWith({
    String? id,
    String? titleKey,
    String? subtitleKey,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      titleKey: titleKey ?? this.titleKey,
      subtitleKey: subtitleKey ?? this.subtitleKey,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}