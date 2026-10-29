import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SoporteMegafonitoScreen extends StatelessWidget {
  const SoporteMegafonitoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Soporte')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(AppDesign.pagePadding),
            children: [
              Text(
                'Estamos para ayudarte',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Comparte un problema o una idea para mejorar Megafonito.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              _SupportTile(
                title: 'Reporta un bug',
                subtitle: 'Cuéntanos si algo no funciona como esperabas.',
                icon: Icons.bug_report_outlined,
                onTap: () => _showPlaceholder(context, 'Reportar bug'),
              ),
              const SizedBox(height: 12),
              _SupportTile(
                title: 'Haz una sugerencia',
                subtitle: '¿Cómo podemos hacer que Megafonito sea aún mejor?',
                icon: Icons.lightbulb_outline_rounded,
                onTap: () => _showPlaceholder(context, 'Hacer una sugerencia'),
              ),
              const SizedBox(height: 22),
              Card(
                color: colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.volunteer_activism_outlined,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Cada reporte y sugerencia nos ayuda a construir una mejor app para toda la comunidad estudiantil. ¡Gracias por ser parte del cambio!',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onPrimaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                '¿Prefieres escribirnos directamente?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _SupportTile(
                title: 'Conecta con el equipo',
                subtitle: 'Consulta las formas de contacto disponibles.',
                icon: Icons.groups_outlined,
                onTap: () =>
                    _showPlaceholder(context, 'Conectar con el equipo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlaceholder(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action: acción aún no implementada')),
    );
  }
}

class _SupportTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SupportTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        minVerticalPadding: 14,
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          child: Icon(icon),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleSmall),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
