import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/server_config.dart';
import '../theme/app_theme.dart';

class QrConnectScreen extends StatefulWidget {
  const QrConnectScreen({super.key});

  @override
  State<QrConnectScreen> createState() => _QrConnectScreenState();
}

class _QrConnectScreenState extends State<QrConnectScreen> {
  bool _busy = false;
  String? _message;

  Future<void> _handleCapture(BarcodeCapture capture) async {
    if (_busy) return;

    String? raw;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.trim().isNotEmpty) {
        raw = value;
        break;
      }
    }
    if (raw == null) return;

    await _tryConnect(raw);
  }

  Future<void> _tryConnect(String raw) async {
    final normalized = ServerConfig.normalize(raw);
    if (normalized == null) {
      setState(() {
        _busy = true;
        _message = 'Ese código no parece una dirección de servidor válida.';
      });
      await Future<void>.delayed(const Duration(milliseconds: 1600));
      if (mounted) setState(() => _busy = false);
      return;
    }

    setState(() {
      _busy = true;
      _message = 'Probando $normalized…';
    });

    final ok = await ServerConfig.probe(normalized);
    if (!mounted) return;

    if (!ok) {
      setState(() {
        _message =
            'El servidor no respondió en $normalized. Revisa el hotspot y el firewall.';
      });
      await Future<void>.delayed(const Duration(milliseconds: 1800));
      if (mounted) setState(() => _busy = false);
      return;
    }

    await ServerConfig.save(normalized);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _openManualDialog() async {
    final controller = TextEditingController(
      text: ServerConfig.baseUrl ?? 'http://192.168.137.1:8787',
    );

    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Escribir URL del servidor'),
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
    if (value == null || value.trim().isEmpty) return;
    await _tryConnect(value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppDesign.navy,
      appBar: AppBar(
        title: const Text('Conectar servidor'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            fit: BoxFit.cover,
            onDetect: _handleCapture,
            errorBuilder: (context, error) {
              return ColoredBox(
                color: AppDesign.navy,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.no_photography_outlined,
                          size: 52,
                          color: AppDesign.amber,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No se pudo abrir la cámara',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Puedes escribir la URL manualmente desde el botón de abajo.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.72),
                  ],
                  stops: const [0, 0.42, 1],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: AppDesign.amber, width: 3),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 28,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Apunta al QR del servidor',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Abre la landing del servidor en la laptop y escanea el código del hotspot.',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      if (_message != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _message!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (_busy) ...[
                        const SizedBox(height: 14),
                        const LinearProgressIndicator(),
                      ],
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _openManualDialog,
                        icon: const Icon(Icons.keyboard_rounded),
                        label: const Text('Escribir URL manualmente'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
