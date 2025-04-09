/// Basic notice model for frontend development
class Notice {
  final int id;
  final String title;
  final String content;
  final String category;
  final String? authorName;
  final DateTime createdAt;
  final bool hasAttachment;
  final String? attachmentUrl;
  final String? attachmentKey;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.authorName,
    required this.createdAt,
    required this.hasAttachment,
    this.attachmentUrl,
    this.attachmentKey,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'] ?? 'General',
      authorName: json['author_name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      hasAttachment: json['has_attachment'] ?? false,
      attachmentUrl: json['attachment_url'],
      attachmentKey: json['attachment_key'],
    );
  }
}
