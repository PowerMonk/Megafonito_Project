import 'package:flutter/material.dart';

import '../screens/qr_connect_screen.dart';
import '../services/server_config.dart';

class ServerConnectionCard extends StatefulWidget {
  final VoidCallback? onChanged;
  final VoidCallback? onDisconnect;
  final bool showDisconnect;

  const ServerConnectionCard({
    super.key,
    this.onChanged,
    this.onDisconnect,
    this.showDisconnect = false,
  });

  @override
  State<ServerConnectionCard> createState() => _ServerConnectionCardState();
}

class _ServerConnectionCardState extends State<ServerConnectionCard> {
  bool _checking = false;
  bool _online = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final url = ServerConfig.baseUrl;
    if (mounted) setState(() => _checking = true);

    final ok = url == null ? false : await ServerConfig.probe(url);
    if (!mounted) return;
    setState(() {
      _checking = false;
      _online = ok;
    });
  }

  Future<void> _scan() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const QrConnectScreen()),
    );
    if (changed != true || !mounted) return;
    await _refresh();
    widget.onChanged?.call();
  }

  Future<void> _manual() async {
    final controller = TextEditingController(
      text: ServerConfig.baseUrl ?? 'http://192.168.137.1:8787',
    );

    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('URL del servidor'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'http://192.168.137.1:8787',
              prefixIcon: Icon(Icons.link_rounded),
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Conectar'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    if (value == null || value.trim().isEmpty || !mounted) return;

    final normalized = ServerConfig.normalize(value);
    if (normalized == null) {
      _showError('La dirección no es válida.');
      return;
    }

    setState(() => _checking = true);
    final ok = await ServerConfig.probe(normalized);
    if (!mounted) return;

    if (!ok) {
      setState(() => _checking = false);
      _showError('No se pudo conectar con $normalized. Revisa la red.');
      return;
    }

    await ServerConfig.save(normalized);
    if (!mounted) return;
    await _refresh();
    widget.onChanged?.call();
  }

  Future<void> _disconnect() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Desconectar servidor'),
          content: const Text(
            'Se borrará la dirección guardada y volverás a la pantalla de inicio de sesión.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Desconectar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    await ServerConfig.clear();
    if (!mounted) return;
    setState(() {
      _online = false;
      _checking = false;
    });
    widget.onDisconnect?.call();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final url = ServerConfig.baseUrl;
    final connected = url != null && _online;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: connected
                      ? const Color(0xFFE3F7EC)
                      : colorScheme.primaryContainer,
                  foregroundColor: connected
                      ? const Color(0xFF16794A)
                      : colorScheme.onPrimaryContainer,
                  child: Icon(
                    connected
                        ? Icons.wifi_tethering_rounded
                        : Icons.dns_outlined,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Servidor de la demo',
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        url ?? 'Todavía no hay un servidor conectado',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Comprobar conexión',
                  onPressed: _checking ? null : _refresh,
                  icon: _checking
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: connected
                        ? const Color(0xFF1FA564)
                        : (url == null ? colorScheme.outline : colorScheme.error),
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  connected
                      ? 'Conectado y listo'
                      : (url == null
                            ? 'Sin configurar'
                            : 'Sin respuesta del servidor'),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: connected
                        ? const Color(0xFF16794A)
                        : (url == null
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.error),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: _checking ? null : _scan,
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 19),
                  label: const Text('Escanear QR'),
                ),
                OutlinedButton.icon(
                  onPressed: _checking ? null : _manual,
                  icon: const Icon(Icons.keyboard_rounded, size: 19),
                  label: const Text('Escribir URL'),
                ),
                if (widget.showDisconnect && url != null)
                  TextButton.icon(
                    onPressed: _checking ? null : _disconnect,
                    icon: Icon(
                      Icons.link_off_rounded,
                      size: 19,
                      color: colorScheme.error,
                    ),
                    label: Text(
                      'Desconectar',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'La dirección se guarda en este dispositivo. Si cambia la red, vuelve a escanear el QR.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
