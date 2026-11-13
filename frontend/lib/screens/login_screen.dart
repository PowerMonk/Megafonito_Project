import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/server_config.dart';
import '../theme/app_theme.dart';
import '../widgets/server_connection_card.dart';
import 'anuncios_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _error;

  static const List<_DemoAccount> _demoAccounts = [
    _DemoAccount('admin', 'admin123', 'Admin'),
    _DemoAccount('student1', '1234', 'Alumno 1'),
    _DemoAccount('student2', '1234', 'Alumno 2'),
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillAccount(_DemoAccount account) {
    setState(() {
      _usernameController.text = account.username;
      _passwordController.text = account.password;
      _error = null;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    if (!ServerConfig.isConfigured) {
      setState(() {
        _error = 'Primero conecta la app al servidor de la demo.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await _authService.login(
        _usernameController.text,
        _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AnunciosScreen(user: user)),
      );
    } on UnauthorizedException {
      if (!mounted) return;
      setState(() => _error = 'Usuario o contraseña incorrectos.');
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'No se pudo iniciar sesión. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppDesign.page,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1414213D),
                          blurRadius: 28,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: SvgPicture.asset('assets/Megafonito.svg'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Megafonito',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppDesign.navy,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Avisos oficiales en tiempo real, en tu red local.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 22),
                  ServerConnectionCard(
                    onChanged: () => setState(() => _error = null),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Iniciar sesión',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Usa una de las cuentas de demostración.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _usernameController,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              decoration: const InputDecoration(
                                labelText: 'Usuario',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'Escribe tu usuario'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _login(),
                              decoration: const InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Escribe tu contraseña'
                                  : null,
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      size: 19,
                                      color: colorScheme.onErrorContainer,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onErrorContainer,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            FilledButton.icon(
                              onPressed: _isLoading ? null : _login,
                              icon: _isLoading
                                  ? const SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.login_rounded),
                              label: Text(
                                _isLoading ? 'Ingresando…' : 'Entrar',
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Acceso rápido',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final account in _demoAccounts)
                                  ActionChip(
                                    avatar: Icon(
                                      account.username == 'admin'
                                          ? Icons.admin_panel_settings_outlined
                                          : Icons.school_outlined,
                                      size: 18,
                                    ),
                                    label: Text(account.label),
                                    onPressed: () => _fillAccount(account),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Demo local · los datos viven en la laptop del servidor.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoAccount {
  final String username;
  final String password;
  final String label;

  const _DemoAccount(this.username, this.password, this.label);
}
