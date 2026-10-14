import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class NuevoMensajeScreen extends StatefulWidget {
  final Function(String, String, String, bool, String?, String?)?
      onMensajeCreado;

  const NuevoMensajeScreen({super.key, this.onMensajeCreado});

  @override
  State<NuevoMensajeScreen> createState() => _NuevoMensajeScreenState();
}

class _NuevoMensajeScreenState extends State<NuevoMensajeScreen> {
  final TextEditingController _asuntoController = TextEditingController();
  final TextEditingController _textoController = TextEditingController();
  String _grupoSeleccionado = 'Ingeniería en Sistemas Computacionales';
  bool _tieneArchivos = false;
  bool _isUploading = false;

  // Store uploaded file details
  final List<Map<String, String?>> _archivosAdjuntos = [];

  @override
  void dispose() {
    _asuntoController.dispose();
    _textoController.dispose();
    super.dispose();
  }

  // Lista de grupos académicos
  final List<String> _grupos = [
    'Ingeniería en Sistemas Computacionales',
    'Ingeniería Civil',
    'Ingeniería Electrónica',
  ];

  void _enviarMensaje() {
    final String asunto = _asuntoController.text;
    final String texto = _textoController.text;

    if (asunto.isNotEmpty && texto.isNotEmpty) {
      if (widget.onMensajeCreado != null) {
        widget.onMensajeCreado!(
            asunto,
            texto,
            _grupoSeleccionado,
            _tieneArchivos,
            _archivosAdjuntos.isNotEmpty
                ? _archivosAdjuntos[0]['fileUrl']
                : null,
            _archivosAdjuntos.isNotEmpty
                ? _archivosAdjuntos[0]['fileKey']
                : null);
      }
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
    }
  }

  void _agregarArchivo() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final result = await StorageService.pickAndUploadFile(context);
      if (!mounted) return;

      if (result != null) {
        setState(() {
          _tieneArchivos = true;
          _archivosAdjuntos.add({
            'fileUrl': result['fileUrl'],
            'fileKey': result['fileKey'],
            'fileName': result['fileUrl']?.split('/').last,
          });
          _isUploading = false;
        });

        debugPrint(
            'File uploaded successfully: URL=${result['fileUrl']}, Key=${result['fileKey']}');
      } else {
        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir archivo: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar un mensaje'),
        actions: [
          IconButton(
            tooltip: 'Adjuntar archivo',
            icon: const Icon(Icons.attach_file_rounded),
            onPressed: _isUploading ? null : _agregarArchivo,
          ),
          IconButton(
            tooltip: 'Enviar mensaje',
            icon: const Icon(Icons.send_rounded),
            onPressed: _enviarMensaje,
          ),
          // Removed the more options icon and its functionality
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isUploading) const LinearProgressIndicator(),
                          if (_isUploading) const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                "Autor: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    fontSize: 16.0),
                              ),
                              Expanded(
                                child: Text(
                                  "mgfdev@itsuruapan.edu.mx",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14.0),
                                ),
                              ),
                              Icon(Icons.person_outline_outlined,
                                  color: Colors.black),
                            ],
                          ),
                          Divider(color: Colors.grey),
                          Row(
                            children: [
                              Text(
                                "Para: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    fontSize: 16),
                              ),
                              Expanded(
                                child: DropdownButton<String>(
                                  value: _grupoSeleccionado,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _grupoSeleccionado = newValue!;
                                    });
                                  },
                                  items: _grupos.map((String group) {
                                    return DropdownMenuItem<String>(
                                      value: group,
                                      child: Text(
                                        group,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    );
                                  }).toList(),
                                  isExpanded: true,
                                  underline: Container(height: 0),
                                  icon: Icon(Icons.arrow_drop_down,
                                      color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Divider(color: Colors.grey),
                          Row(
                            children: [
                              Text(
                                "Asunto: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    fontSize: 16),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _asuntoController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Escribe tu asunto",
                                    hintStyle: TextStyle(
                                        color: Colors.grey, fontSize: 15.0),
                                  ),
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14.5),
                                ),
                              ),
                            ],
                          ),
                          Divider(color: Colors.grey),
                          // "Categoría" section has been removed
                          TextField(
                            controller: _textoController,
                            decoration: InputDecoration(
                              hintText: "Redacta tu mensaje",
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 14.0),
                              border: InputBorder.none,
                            ),
                            style:
                                TextStyle(color: Colors.black, fontSize: 14.0),
                            maxLines:
                                null, // Permite que el TextField se expanda
                            keyboardType: TextInputType.multiline,
                          ),
                          if (_archivosAdjuntos.isNotEmpty)
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _archivosAdjuntos.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.network(
                                      _archivosAdjuntos[index]['fileUrl']!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
