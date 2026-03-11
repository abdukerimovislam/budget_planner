import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/custom_category_model.dart';
import '../../l10n/app_localizations.dart';
import '../providers/home_provider.dart';

class CustomCategorySheet extends StatefulWidget {
  const CustomCategorySheet({super.key});

  static Future<CustomCategoryModel?> show(BuildContext context) {
    return showModalBottomSheet<CustomCategoryModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CustomCategorySheet(),
    );
  }

  @override
  State<CustomCategorySheet> createState() => _CustomCategorySheetState();
}

class _CustomCategorySheetState extends State<CustomCategorySheet> {
  final TextEditingController _nameController = TextEditingController();

  // Доступные иконки для пользователя
  final List<IconData> _availableIcons = [
    CupertinoIcons.car_detailed,
    CupertinoIcons.house_fill,
    CupertinoIcons.paw_solid,
    CupertinoIcons.gamecontroller_fill,
    CupertinoIcons.book_fill,
    CupertinoIcons.bag_fill,
    CupertinoIcons.heart_fill,
    CupertinoIcons.airplane,
    CupertinoIcons.scissors,
    CupertinoIcons.hammer_fill,
    CupertinoIcons.desktopcomputer,
    CupertinoIcons.camera_fill,
  ];

  // Доступные цвета Apple
  final List<Color> _availableColors = [
    CupertinoColors.systemRed,
    CupertinoColors.systemOrange,
    CupertinoColors.systemYellow,
    CupertinoColors.systemGreen,
    CupertinoColors.systemTeal,
    CupertinoColors.systemBlue,
    CupertinoColors.systemIndigo,
    CupertinoColors.systemPurple,
    CupertinoColors.systemPink,
  ];

  late IconData _selectedIcon;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedIcon = _availableIcons.first;
    _selectedColor = _availableColors.first;
    _nameController.addListener(_updateState);
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateState);
    _nameController.dispose();
    super.dispose();
  }

  void _updateState() => setState(() {});

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final newCategory = CustomCategoryModel(
      id: const Uuid().v4(),
      name: name,
      iconCodePoint: _selectedIcon.codePoint,
      colorValue: _selectedColor.value,
    );

    context.read<HomeProvider>().addCustomCategory(newCategory);
    Navigator.of(context).pop(newCategory);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Для BottomSheet в iOS мы берем сплошной цвет с закруглениями сверху
    final backgroundColor = theme.brightness == Brightness.dark ? const Color(0xFF1C1C1E) : Colors.white;

    return Padding(
      // Поднимаем контент, когда открывается клавиатура
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75, // 75% экрана
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            // Pull tab (маленькая серая полоска сверху)
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Заголовок
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text('Cancel', style: TextStyle(color: theme.colorScheme.primary, fontSize: 17)),
                  ),
                  const Text('New Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                  GestureDetector(
                    onTap: _nameController.text.trim().isEmpty ? null : _save,
                    child: Text(
                        'Save',
                        style: TextStyle(
                            color: _nameController.text.trim().isEmpty ? CupertinoColors.systemGrey : theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 17
                        )
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 24),

                  // ПРЕВЬЮ ИКОНКИ (Большой круг)
                  Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _selectedColor.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(_selectedIcon, color: Colors.white, size: 40),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ПОЛЕ ВВОДА ИМЕНИ
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _nameController,
                      autofocus: true,
                      style: const TextStyle(fontSize: 17),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Category Name (e.g. Pet Food)',
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ВЫБОР ЦВЕТА
                  const Text('COLOR', style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _availableColors.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final color = _availableColors[index];
                        final isSelected = color == _selectedColor;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 50,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected ? Border.all(color: theme.colorScheme.onSurface, width: 3) : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ВЫБОР ИКОНКИ
                  const Text('ICON', style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: _availableIcons.map((icon) {
                      final isSelected = icon == _selectedIcon;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = icon),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? theme.colorScheme.surfaceVariant : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            icon,
                            size: 32,
                            color: isSelected ? theme.colorScheme.onSurface : CupertinoColors.systemGrey,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}