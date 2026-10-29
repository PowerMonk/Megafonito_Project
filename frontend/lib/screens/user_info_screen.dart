import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'login_screen.dart';

class UserInfoScreen extends StatelessWidget {
  const UserInfoScreen({super.key});

  // Development example data; this is not loaded from the active mock login.
  static const String _name = 'Karol Rubén Quiroz Mora';
  static const String _email = 'qumk051105@itsuruapan.edu.mx';
  static const String _controlNumber = '23040061';
  static const String _career = 'Ing. en Sistemas Computacionales';
  static const String _semester = '4';

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Copiado al portapapeles')));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final allInfo =
        'Nombre: $_name\nNo. control: $_controlNumber\nCarrera: $_career\nSemestre: $_semester\nEmail: $_email';

    return Container(
      color: AppDesign.page,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(AppDesign.pagePadding),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: colorScheme.primaryContainer,
                            foregroundColor: colorScheme.onPrimaryContainer,
                            child: const Icon(Icons.person_rounded, size: 30),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Información de usuario',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _copy(context, allInfo),
                          icon: const Icon(Icons.content_copy_rounded),
                          label: const Text('Copiar toda la información'),
                        ),
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        context,
                        'Número de control',
                        _controlNumber,
                      ),
                      _buildInfoRow(context, 'Carrera', _career),
                      _buildInfoRow(context, 'Semestre', _semester),
                      _buildInfoRow(context, 'Correo electrónico', _email),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text('Tu horario', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  minVerticalPadding: 16,
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.secondaryContainer,
                    foregroundColor: colorScheme.onSecondaryContainer,
                    child: const Icon(Icons.calendar_month_rounded),
                  ),
                  title: Text(
                    'Horario de clases',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  subtitle: const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('Tu horario estará disponible próximamente'),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Navegación a Horario no implementada'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Cerrar sesión'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
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
                const SizedBox(height: 3),
                SelectableText(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
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
