import 'package:flutter/material.dart';
import 'notice_tags.dart';

class NoticeCard extends StatelessWidget {
  final Map<String, dynamic> notice;
  final bool isExpanded;
  final VoidCallback onTap;

  const NoticeCard({
    Key? key,
    required this.notice,
    required this.isExpanded,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 105, 104, 104),
              blurRadius: 1,
              offset: const Offset(-2, 3),
              spreadRadius: 0.5,
              blurStyle: BlurStyle.inner,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    notice['titulo'],
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 18,
                    ),
                  ),
                ),
                Row(
                  children: [
                    NoticeTag(category: notice['categoria'] ?? ''),
                    if (notice['tieneArchivos'] == true)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(Icons.attach_file, size: 18),
                      ),
                  ],
                ),
              ],
            ),
            if (isExpanded) ...[
              SizedBox(height: 8),
              Text(
                notice['texto'],
                style: TextStyle(color: Color(0xFF000000)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
