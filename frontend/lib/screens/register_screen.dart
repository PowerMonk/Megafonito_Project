import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _email;
  String? _password;
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await AuthService.register(context, _name!, _email!, _password!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado con éxito')),
      );
      Navigator.of(context).pop();
    } catch (_) {
      // AuthService displays the mock registration error.
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar usuario')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDesign.pagePadding),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Image.asset(
                          'assets/LogoMegafon_V2.png',
                          width: 48,
                          height: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Crea tu cuenta',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 22),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Por favor ingresa tu nombre'
                            : null,
                        onChanged: (value) => _name = value,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        validator: (value) => value == null || value.isEmpty
                            ? 'Por favor ingresa tu correo electrónico'
                            : null,
                        onChanged: (value) => _email = value,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock_outline_rounded),
                        ),
                        obscureText: true,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: (value) => value == null || value.isEmpty
                            ? 'Por favor ingresa tu contraseña'
                            : null,
                        onChanged: (value) => _password = value,
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: _isLoading ? null : _register,
                        icon: _isLoading
                            ? const SizedBox.square(
                                dimension: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.person_add_alt_1_rounded),
                        label: Text(_isLoading ? 'Registrando…' : 'Registrar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
