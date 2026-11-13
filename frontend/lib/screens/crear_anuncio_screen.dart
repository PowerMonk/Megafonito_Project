import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/notices_service.dart';
import '../theme/app_theme.dart';

class CrearNuevoAnuncioScreen extends StatefulWidget {
  final User author;
  final NoticesService noticesService;
  final Future<void> Function(AnnouncementDraft draft) onPublish;

  const CrearNuevoAnuncioScreen({
    super.key,
    required this.author,
    required this.noticesService,
    required this.onPublish,
  });

  @override
  State<CrearNuevoAnuncioScreen> createState() =>
      _CrearNuevoAnuncioScreenState();
}

class _CrearNuevoAnuncioScreenState extends State<CrearNuevoAnuncioScreen> {
  static const List<String> _fallbackGroups = [
    'Ingeniería en Sistemas Computacionales',
    'Ingeniería Mecánica',
  ];

  static const List<String> _categories = [
    'General',
    'Materias',
    'Convocatorias',
    'Eventos',
    'Deportivos',
    'Culturales',
    'Comunidad',
  ];

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _category = 'General';
  String _audience = 'all';
  List<String> _groups = _fallbackGroups;
  bool _publishing = false;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    try {
      final groups = await widget.noticesService.loadGroups();
      if (!mounted) return;
      if (groups.isNotEmpty) {
        setState(() => _groups = groups);
      }
    } catch (_) {
      // The fallback list matches the seeded demo groups.
    }
  }

  String get _audienceLabel {
    if (_audience == 'all') return 'Todos los estudiantes';
    return _audience;
  }

  Future<void> _publish() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un título y el contenido.')),
      );
      return;
    }

    setState(() => _publishing = true);
    try {
      await widget.onPublish(
        AnnouncementDraft(
          title: title,
          content: content,
          category: _category,
          audience: _audience == 'all' ? 'all' : 'groups',
          group: _audience == 'all' ? null : _audience,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on UnauthorizedException catch (error) {
      _showError(error.message);
    } on ApiException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('No se pudo publicar el anuncio. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo anuncio'),
        actions: [
          IconButton(
            tooltip: 'Publicar anuncio',
            onPressed: _publishing ? null : _publish,
            icon: _publishing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_publishing) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 21,
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                        child: const Icon(
                          Icons.campaign_outlined,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.author.name,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              widget.author.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                  const Divider(height: 28),
                  _DropdownRow<String>(
                    label: 'Para',
                    value: _audience,
                    items: [
                      const DropdownMenuItem(
                        value: 'all',
                        child: Text(
                          'Todos los estudiantes',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      for (final group in _groups)
                        DropdownMenuItem(
                          value: group,
                          child: Text(
                            group,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _audience = value);
                    },
                  ),
                  const Divider(height: 20),
                  _DropdownRow<String>(
                    label: 'Categoría',
                    value: _category,
                    items: [
                      for (final category in _categories)
                        DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _category = value);
                    },
                  ),
                  const Divider(height: 20),
                  TextField(
                    controller: _titleController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 160,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      hintText: 'Escribe un título breve',
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Divider(height: 20),
                  TextField(
                    controller: _contentController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Contenido',
                      hintText: 'Redacta el anuncio',
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                    minLines: 5,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.groups_2_outlined,
                          size: 20,
                          color: colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Este anuncio se enviará a: $_audienceLabel.\n'
                            'Los alumnos solo verán los anuncios de su grupo.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: colorScheme.onSecondaryContainer,
                                  height: 1.45,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _publishing ? null : _publish,
                      icon: const Icon(Icons.send_rounded),
                      label: Text(
                        _publishing ? 'Publicando…' : 'Publicar anuncio',
                      ),
                    ),
                  ),
                ],
              ),
            ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DropdownRow<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 86,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              borderRadius: BorderRadius.circular(AppDesign.controlRadius),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
