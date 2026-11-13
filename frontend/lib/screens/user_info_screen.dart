import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../widgets/server_connection_card.dart';

class UserInfoScreen extends StatelessWidget {
  final User user;
  final VoidCallback onLogout;

  const UserInfoScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Copiado al portapapeles')));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final allInfo = [
      'Nombre: ${user.name}',
      if (user.controlNumber != null) 'No. control: ${user.controlNumber}',
      'Grupo: ${user.groupLabel}',
      if (user.semester != null) 'Semestre: ${user.semester}',
      'Email: ${user.email}',
      'Rol: ${user.roleLabel}',
    ].join('\n');

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
                            child: Icon(
                              user.isAdmin
                                  ? Icons.admin_panel_settings_outlined
                                  : Icons.person_rounded,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '@${user.username}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: user.isAdmin
                                  ? colorScheme.secondaryContainer
                                  : colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              user.roleLabel,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: user.isAdmin
                                        ? colorScheme.onSecondaryContainer
                                        : colorScheme.onPrimaryContainer,
                                  ),
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
                      if (user.controlNumber != null)
                        _buildInfoRow(
                          context,
                          'Número de control',
                          user.controlNumber!,
                        ),
                      _buildInfoRow(context, 'Grupo / perfil', user.groupLabel),
                      if (user.semester != null)
                        _buildInfoRow(
                          context,
                          'Semestre',
                          '${user.semester}',
                        ),
                      _buildInfoRow(
                        context,
                        'Correo electrónico',
                        user.email,
                      ),
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
              const SizedBox(height: 18),
              ServerConnectionCard(
                showDisconnect: true,
                onChanged: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Servidor actualizado. Inicia sesión de nuevo.',
                      ),
                    ),
                  );
                  onLogout();
                },
                onDisconnect: onLogout,
              ),
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: onLogout,
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
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
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
