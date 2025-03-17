// Sorting function
List<Map<String, dynamic>> sortNotices(
  List<Map<String, dynamic>> notices,
  String? sortOption,
) {
  List<Map<String, dynamic>> sorted = List.from(notices);
  if (sortOption == 'Más recientes') {
    sorted.sort(
        (a, b) => (b['fecha'] as DateTime).compareTo(a['fecha'] as DateTime));
  } else if (sortOption == 'Más antiguos') {
    sorted.sort(
        (a, b) => (a['fecha'] as DateTime).compareTo(b['fecha'] as DateTime));
  }
  return sorted;
}
