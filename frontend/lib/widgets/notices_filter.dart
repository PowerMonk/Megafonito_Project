import 'package:flutter/material.dart';

class NoticesFilter extends StatefulWidget {
  final Function(String) onCategorySelected;
  final Function(String) onSortOptionSelected;

  NoticesFilter({
    required this.onCategorySelected,
    required this.onSortOptionSelected,
  });

  @override
  _NoticesFilterState createState() => _NoticesFilterState();
}

class _NoticesFilterState extends State<NoticesFilter> {
  final List<String> categories = [
    'Materias',
    'Convocatorias',
    'Eventos',
    'Deportivos',
    'Culturales',
    'Comunidad',
  ];

  String? selectedCategory;
  String? selectedSortOption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          // Category filters - takes most of the width
          Expanded(
            flex: 7,
            child: Container(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      selectedColor: Color(0xFFFCA311),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = selected ? category : null;
                        });
                        widget.onCategorySelected(selectedCategory ?? '');
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // Filter button - takes remaining width
          Container(
            child: PopupMenuButton<String>(
              icon: Icon(Icons.filter_list),
              tooltip: 'Ordenar',
              onSelected: (value) {
                setState(() {
                  selectedSortOption = value;
                });
                widget.onSortOptionSelected(selectedSortOption ?? '');
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'Más recientes',
                  child: Text('Más recientes'),
                ),
                PopupMenuItem(
                  value: 'Más antiguos',
                  child: Text('Más antiguos'),
                ),
                PopupMenuItem(
                  value: 'Con archivos',
                  child: Text('Con archivos'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
