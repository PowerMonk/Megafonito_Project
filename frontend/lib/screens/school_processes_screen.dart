import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

class SchoolProcessesScreen extends StatelessWidget {
  const SchoolProcessesScreen({super.key});

  static const List<String> _questions = [
    '¿Cómo puedo solicitar una revisión de calificación?',
    '¿Cuál es el proceso para dar de baja una materia?',
    '¿Cómo puedo solicitar una constancia de estudios?',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: AppDesign.page,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(AppDesign.pagePadding),
            children: [
              Text(
                'Procesos escolares',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Consulta fechas importantes y respuestas rápidas.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 20),
              Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _showPlaceholder(
                    context,
                    'Navegación al calendario no implementada',
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/calendario-escolar_icon.svg',
                            height: 36,
                            width: 36,
                            colorFilter: ColorFilter.mode(
                              colorScheme.onPrimaryContainer,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Calendario escolar',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Revisa periodos y fechas clave',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            color: colorScheme.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'Preguntas frecuentes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ..._questions.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
                      minVerticalPadding: 14,
                      leading: Icon(
                        Icons.help_outline_rounded,
                        color: colorScheme.primary,
                      ),
                      title: Text(
                        entry.value,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _showPlaceholder(
                        context,
                        'Pregunta ${entry.key + 1} seleccionada',
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  minVerticalPadding: 16,
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.secondaryContainer,
                    foregroundColor: colorScheme.onSecondaryContainer,
                    child: const Icon(Icons.assignment_outlined),
                  ),
                  title: Text(
                    'Proceso de inscripción',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  subtitle: const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('Ver requisitos y pasos a seguir'),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showPlaceholder(
                    context,
                    'Proceso de inscripción seleccionado',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlaceholder(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
