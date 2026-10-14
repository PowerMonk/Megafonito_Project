import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class NoticesFilter extends StatefulWidget {
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<String> onSortOptionSelected;

  const NoticesFilter({
    super.key,
    required this.onCategorySelected,
    required this.onSortOptionSelected,
  });

  @override
  State<NoticesFilter> createState() => _NoticesFilterState();
}

class _NoticesFilterState extends State<NoticesFilter> {
  static const List<String> _categories = [
    'Materias',
    'Convocatorias',
    'Eventos',
    'Deportivos',
    'Culturales',
    'Comunidad',
  ];

  String? _selectedCategory;
  String? _selectedSortOption;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDesign.pagePadding,
        8,
        AppDesign.pagePadding - 4,
        4,
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;

                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: colorScheme.secondaryContainer,
                    backgroundColor: colorScheme.surface,
                    side: BorderSide(
                      color: isSelected
                          ? colorScheme.secondaryContainer
                          : colorScheme.outlineVariant,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                      widget.onCategorySelected(_selectedCategory ?? '');
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            tooltip: 'Filtrar y ordenar anuncios',
            icon: const Icon(Icons.tune_rounded),
            onSelected: (value) {
              setState(() => _selectedSortOption = value);
              widget.onSortOptionSelected(value);
            },
            itemBuilder: (context) => [
              _menuItem('Más recientes'),
              _menuItem('Más antiguos'),
              _menuItem('Con archivos'),
            ],
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesign.controlRadius),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String label) {
    return PopupMenuItem<String>(
      value: label,
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (_selectedSortOption == label)
            const Icon(Icons.check_rounded, size: 18),
        ],
      ),
    );
  }
}
