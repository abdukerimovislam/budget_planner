class CustomCategoryModel {
  final String id;
  final String name;
  final int iconCodePoint; // Код иконки (чтобы красиво отображать в UI)
  final int colorValue;    // Цвет категории

  const CustomCategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
  });

  CustomCategoryModel copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    int? colorValue,
  }) {
    return CustomCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
    };
  }

  factory CustomCategoryModel.fromMap(Map<String, dynamic> map) {
    return CustomCategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      iconCodePoint: map['iconCodePoint'] as int,
      colorValue: map['colorValue'] as int,
    );
  }
}