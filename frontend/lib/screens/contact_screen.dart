import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class ContactosEscolaresScreen extends StatefulWidget {
  const ContactosEscolaresScreen({super.key});

  @override
  State<ContactosEscolaresScreen> createState() =>
      _ContactosEscolaresScreenState();
}

class _ContactosEscolaresScreenState extends State<ContactosEscolaresScreen> {
  static const List<Map<String, String>> _contactos = [
    {
      'name': 'Profesor Juan Pérez',
      'phone': '555-1234',
      'email': 'juan.perez@escuela.edu',
      'location': 'Edificio A, Oficina 101',
    },
    {
      'name': 'Administradora María López',
      'phone': '555-5678',
      'email': 'maria.lopez@escuela.edu',
      'location': 'Edificio F, Planta Baja',
    },
    {
      'name': 'Profesor Carlos García',
      'phone': '555-8765',
      'email': 'carlos.garcia@escuela.edu',
      'location': 'Edificio D, Cubículo 5',
    },
    {
      'name': 'Administrativa Ana Torres',
      'phone': '555-4321',
      'email': 'ana.torres@escuela.edu',
      'location': 'Edificio H, Ventanilla 3',
    },
    {
      'name': 'Biblioteca Central',
      'phone': '555-9900',
      'email': 'biblioteca.central@escuela.edu',
      'location': 'Edificio Principal, 2do Piso',
    },
  ];

  String _query = '';

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Copiado al portapapeles')));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredContacts = _contactos
        .where(
          (contact) =>
              contact['name']!.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

    return Container(
      color: AppDesign.page,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(AppDesign.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Directorio escolar',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                // const SizedBox(height: 6),
                // Text(
                //   'Encuentra y comparte la información de contacto.',
                //   style: Theme.of(context).textTheme.bodyMedium
                //       ?.copyWith(color: colorScheme.onSurfaceVariant),
                // ),
                const SizedBox(height: 18),
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpiar búsqueda',
                            onPressed: () => setState(() => _query = ''),
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filteredContacts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_search_outlined,
                                size: 42,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'No se encontraron contactos',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount: filteredContacts.length,
                          itemBuilder: (context, index) {
                            final contact = filteredContacts[index];
                            return _buildContactCard(context, contact);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, Map<String, String> contact) {
    final name = contact['name']!;
    final phone = contact['phone']!;
    final email = contact['email']!;
    final location = contact['location']!;
    final allInfo =
        'Nombre: $name\nTeléfono: $phone\nCorreo: $email\nUbicación: $location';
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  child: const Icon(Icons.person_outline_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Copiar contacto completo',
                  onPressed: () => _copy(context, allInfo),
                  icon: const Icon(Icons.content_copy_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _buildContactInfoRow(context, 'Teléfono', phone),
            _buildContactInfoRow(context, 'Correo', email),
            _buildContactInfoRow(context, 'Ubicación', location),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoRow(
    BuildContext context,
    String label,
    String value,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Copiar $label',
            onPressed: () => _copy(context, value),
            icon: const Icon(Icons.content_copy_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}
