import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class CrearNuevaOportunidadScreen extends StatefulWidget {
  final Function(String, String, Color, String, bool, String?, String?)?
  onOportunidadCreada;

  const CrearNuevaOportunidadScreen({super.key, this.onOportunidadCreada});

  @override
  State<CrearNuevaOportunidadScreen> createState() =>
      _CrearNuevaOportunidadScreenState();
}

class _CrearNuevaOportunidadScreenState
    extends State<CrearNuevaOportunidadScreen> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _textoController = TextEditingController();
  String _categoriaSeleccionada = 'Becas';
  String _grupoSeleccionado = 'Ingeniería en Sistemas Computacionales';
  bool _tieneArchivos = false;
  bool _isUploading = false;

  // Store uploaded file details
  final List<Map<String, String?>> _archivosAdjuntos = [];

  @override
  void dispose() {
    _tituloController.dispose();
    _textoController.dispose();
    super.dispose();
  }

  // Lista de categorías para oportunidades
  final List<String> _categorias = [
    'Becas',
    'Cursos y Certificaciones',
    'Bolsa de trabajo',
  ];

  // Lista de grupos académicos
  final List<String> _grupos = [
    'Ingeniería en Sistemas Computacionales',
    'Ingeniería Civil',
    'Ingeniería Electrónica',
  ];

  void _crearOportunidad() {
    final String titulo = _tituloController.text;
    final String texto = _textoController.text;
    final Color color = Colors.white; // Color blanco por defecto

    if (titulo.isNotEmpty && texto.isNotEmpty) {
      if (widget.onOportunidadCreada != null) {
        widget.onOportunidadCreada!(
          titulo,
          texto,
          color,
          _categoriaSeleccionada,
          _tieneArchivos,
          _archivosAdjuntos.isNotEmpty ? _archivosAdjuntos[0]['fileUrl'] : null,
          _archivosAdjuntos.isNotEmpty ? _archivosAdjuntos[0]['fileKey'] : null,
        );
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
          'File uploaded successfully: URL=${result['fileUrl']}, Key=${result['fileKey']}',
        );
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

  void _mostrarMenuOpciones(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.schedule),
              title: Text('Programar envío'),
              onTap: () {
                Navigator.pop(context);
                // Implementar la lógica para programar el envío
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_sweep),
              title: Text('Eliminar archivos adjuntos'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _archivosAdjuntos.clear();
                  _tieneArchivos = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva oportunidad'),
        actions: [
          IconButton(
            tooltip: 'Adjuntar archivo',
            icon: const Icon(Icons.attach_file_rounded),
            onPressed: _isUploading ? null : _agregarArchivo,
          ),
          IconButton(
            tooltip: 'Publicar oportunidad',
            icon: const Icon(Icons.send_rounded),
            onPressed: _crearOportunidad,
          ),
          IconButton(
            tooltip: 'Más opciones',
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () => _mostrarMenuOpciones(context),
          ),
        ],
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
            filled: false,
            fillColor: Colors.transparent,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight - 32,
                ),
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
                            fontSize: 16.0,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "mgfdev@itsuruapan.edu.mx",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.person_outline_outlined,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Text(
                          "Para: ",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 16,
                          ),
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
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              );
                            }).toList(),
                            isExpanded: true,
                            underline: Container(height: 0),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Text(
                          "Categoría: ",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _categoriaSeleccionada,
                            onChanged: (String? newValue) {
                              setState(() {
                                _categoriaSeleccionada = newValue!;
                              });
                            },
                            items: _categorias.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              );
                            }).toList(),
                            isExpanded: true,
                            underline: Container(height: 0),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Text(
                          "Título: ",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _tituloController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Escribe un título",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                              ),
                            ),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Text(
                          "Link: ",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _tituloController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Agrega un enlace (opcional)",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                              ),
                            ),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    TextField(
                      controller: _textoController,
                      decoration: InputDecoration(
                        hintText: "Describe la oportunidad",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14.0,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: Colors.black, fontSize: 14.0),
                      maxLines: null, // Permite que el TextField se expanda
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
            );
          },
        ),
      ),
    );
  }
}
