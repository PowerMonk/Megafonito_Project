import 'api_client.dart';

class AnnouncementDraft {
  final String title;
  final String content;
  final String category;
  final String audience;
  final String? group;

  const AnnouncementDraft({
    required this.title,
    required this.content,
    required this.category,
    required this.audience,
    this.group,
  });

  Map<String, dynamic> toBody() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'audience': audience,
      'groups': audience == 'groups' && group != null ? [group] : <String>[],
    };
  }

  String get audienceLabel {
    if (audience == 'all' || group == null) return 'Todos los estudiantes';
    return group!;
  }
}

class NoticesService {
  Future<Map<String, dynamic>> loadNotices({
    int page = 1,
    int limit = 5,
    String? category,
    String? sort,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (category != null && category.isNotEmpty) 'category': category,
      if (sort != null && sort.isNotEmpty) 'sort': sort,
    };

    final response = await ApiClient.get('/api/announcements', query: query);
    if (response is! Map<String, dynamic>) {
      throw const ApiException(500, 'Respuesta inesperada del servidor.');
    }
    return response;
  }

  Future<List<String>> loadGroups() async {
    final response = await ApiClient.get('/api/groups');
    if (response is! Map<String, dynamic>) {
      throw const ApiException(500, 'Respuesta inesperada del servidor.');
    }
    final groups = response['groups'];
    if (groups is! List) return [];
    return groups
        .whereType<String>()
        .where((group) => group.trim().isNotEmpty)
        .toList();
  }

  Future<void> createNotice(AnnouncementDraft draft) async {
    await ApiClient.post('/api/announcements', draft.toBody());
  }

  Future<void> updateNotice(int id, AnnouncementDraft draft) async {
    await ApiClient.put('/api/announcements/$id', draft.toBody());
  }

  Future<void> deleteNotice(int id) async {
    await ApiClient.delete('/api/announcements/$id');
  }
}
