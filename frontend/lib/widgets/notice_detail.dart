import 'package:flutter/material.dart';

/// Full announcement content shown inside a draggable modal bottom sheet.
class NoticeDetail extends StatelessWidget {
  final Map<String, dynamic> anuncio;

  const NoticeDetail({super.key, required this.anuncio});

  @override
  Widget build(BuildContext context) {
    return _buildContent(context, ScrollController());
  }

  static void show(BuildContext context, Map<String, dynamic> anuncio) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.66,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return NoticeDetail(
            anuncio: anuncio,
          )._buildContent(context, scrollController);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ScrollController scrollController,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = anuncio['title']?.toString() ?? 'Detalle del anuncio';
    final authorName =
        anuncio['author_name']?.toString() ?? 'Autor desconocido';
    final content =
        anuncio['content']?.toString() ?? 'No hay contenido disponible.';
    final category = anuncio['category']?.toString() ?? 'General';
    final audience =
        anuncio['audience_label']?.toString() ?? 'Todos los estudiantes';
    final createdAt = _parseDate(anuncio['created_at']);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          tooltip: 'Cerrar',
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: colorScheme.primaryContainer,
                          foregroundColor: colorScheme.onPrimaryContainer,
                          child: const Icon(
                            Icons.campaign_outlined,
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authorName,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                'Publicado por',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Pill(
                          icon: Icons.sell_outlined,
                          label: category,
                          background: colorScheme.secondaryContainer,
                          foreground: colorScheme.onSecondaryContainer,
                        ),
                        _Pill(
                          icon: Icons.groups_2_outlined,
                          label: 'Para: $audience',
                          background: colorScheme.primaryContainer,
                          foreground: colorScheme.onPrimaryContainer,
                        ),
                      ],
                    ),
                    if (createdAt != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Publicado el ${_formatDate(createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const Divider(height: 28),
                    SelectableText(
                      content,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '');
  }

  String _formatDate(DateTime date) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    final local = date.toLocal();
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  const _Pill({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foreground),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
