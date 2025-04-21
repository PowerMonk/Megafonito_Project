import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/storage_service.dart';

class NuevoMensajeScreen extends StatefulWidget {
  final Function(String, String, String, bool, String?, String?)?
      onMensajeCreado;

  NuevoMensajeScreen({this.onMensajeCreado});

  @override
  _NuevoMensajeScreenState createState() => _NuevoMensajeScreenState();
}

class _NuevoMensajeScreenState extends State<NuevoMensajeScreen> {
  final TextEditingController _asuntoController = TextEditingController();
  final TextEditingController _textoController = TextEditingController();
  String _grupoSeleccionado = 'Ingeniería en Sistemas Computacionales';
  bool _tieneArchivos = false;
  bool _isUploading = false;

  // Store uploaded file details
  List<Map<String, String?>> _archivosAdjuntos = [];

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

        print(
            'File uploaded successfully: URL=${result['fileUrl']}, Key=${result['fileKey']}');
      } else {
        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
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
        title: Text(
          "Envia un mensaje",
          style: TextStyle(
              fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color.fromARGB(255, 250, 250, 250),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.attach_file, color: Colors.black),
            onPressed: _agregarArchivo,
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.black),
            onPressed: _enviarMensaje,
          ),
          // Removed the more options icon and its functionality
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Container(
                color: Color.fromARGB(255, 250, 250, 250),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        style: TextStyle(color: Colors.black, fontSize: 14.0),
                        maxLines: null, // Permite que el TextField se expanda
                        keyboardType: TextInputType.multiline,
                      ),
                      if (_archivosAdjuntos.isNotEmpty)
                        Container(
                          height:
                              200, // Altura para la vista previa de los archivos
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
          );
        },
      ),
    );
  }
}
