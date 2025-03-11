import 'package:flutter/material.dart';

class NoticeTag extends StatelessWidget {
  final String category;

  NoticeTag({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getCategoryColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    // Return different colors based on category
    switch (category) {
      case 'Clases':
        return Colors.blue;
      case 'Convocatorias':
        return Colors.purple;
      case 'Eventos':
        return Colors.orange;
      case 'Deportes':
        return Colors.green;
      case 'Comunidad':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class FileAttachmentIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
          ),
        ],
      ),
      child: Icon(
        Icons.attach_file,
        color: Colors.black54,
        size: 16,
      ),
    );
  }
}
