import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A compact, accessible summary of one school announcement.
class NoticeCard extends StatelessWidget {
  final Map<String, dynamic> anuncio;
  final ValueChanged<Map<String, dynamic>> onTap;

  const NoticeCard({super.key, required this.anuncio, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authorName = anuncio['author_name']?.toString() ?? 'Autor escolar';
    final title = anuncio['title']?.toString() ?? 'Sin título';
    final category = anuncio['category']?.toString() ?? 'General';
    final hasAttachment =
        anuncio['has_attachment'] == true || anuncio['has_attachment'] == 1;
    final createdAt = _formatCreatedAt(anuncio['created_at']);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onTap(anuncio),
        borderRadius: BorderRadius.circular(AppDesign.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    child: const Icon(Icons.campaign_outlined, size: 21),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Anuncio escolar',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    createdAt,
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                  if (hasAttachment) ...[
                    const SizedBox(width: 10),
                    Tooltip(
                      message: 'Incluye un archivo adjunto',
                      child: Icon(
                        Icons.attach_file_rounded,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCreatedAt(dynamic value) {
    final DateTime? date = value is DateTime
        ? value
        : DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return 'Fecha pendiente';

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
    return '${date.day} ${months[date.month - 1]}';
  }
}

/// Reusable list presentation for callers that provide their own feed state.
class NoticesContent extends StatelessWidget {
  final List<Map<String, dynamic>> anuncios;
  final bool hasMoreData;
  final bool isLoading;
  final ValueChanged<Map<String, dynamic>> onNoticeTap;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  const NoticesContent({
    super.key,
    required this.anuncios,
    required this.hasMoreData,
    required this.isLoading,
    required this.onNoticeTap,
    required this.onRefresh,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDesign.pagePadding),
        itemCount: anuncios.length + (hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < anuncios.length) {
            return NoticeCard(anuncio: anuncios[index], onTap: onNoticeTap);
          }
          if (isLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: FilledButton.tonal(
                onPressed: onLoadMore,
                child: const Text('Cargar más anuncios'),
              ),
            ),
          );
        },
      ),
    );
  }
}
