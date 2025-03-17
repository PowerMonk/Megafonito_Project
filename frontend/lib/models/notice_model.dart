class Notice {
  final String title;
  final String content;
  final String category;
  final bool hasFile;
  final String? fileUrl;
  final String? fileKey;
  final DateTime createdAt;

  Notice({
    required this.title,
    required this.content,
    required this.category,
    required this.hasFile,
    this.fileUrl,
    this.fileKey,
    required this.createdAt,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      title: json['title'],
      content: json['content'],
      category: json['category'] ?? 'Materias',
      hasFile: json['has_file'] == 1 || json['has_file'] == true,
      fileUrl: json['file_url'],
      fileKey: json['file_key'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'has_file': hasFile ? 1 : 0,
      'file_url': fileUrl,
      'file_key': fileKey,
    };
  }
}
