import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/storage_service.dart';

// Random comment for pipeline testing

class CrearNuevoAnuncioScreen extends StatefulWidget {
  final Function(String, String, Color, String, bool, String?, String?)
      onAnuncioCreado;

  CrearNuevoAnuncioScreen({required this.onAnuncioCreado});

  @override
  _CrearNuevoAnuncioScreenState createState() =>
      _CrearNuevoAnuncioScreenState();
}

class _CrearNuevoAnuncioScreenState extends State<CrearNuevoAnuncioScreen> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _textoController = TextEditingController();
  String _categoriaSeleccionada = 'Materias';
  String _grupoSeleccionado = 'Ingeniería en Sistemas Computacionales';
  bool _tieneArchivos = false;
  bool _isUploading = false;

  // Store uploaded file details
  List<Map<String, String?>> _archivosAdjuntos = [];

  // Lista de categorías (misma que en NoticesFilter)
  final List<String> _categorias = [
    'Materias',
    'Convocatorias',
    'Eventos',
    'Deportivos',
    'Culturales',
    'Comunidad',
  ];

  // Lista de grupos académicos
  final List<String> _grupos = [
    'Ingeniería en Sistemas Computacionales',
    'Ingeniería Civil',
    'Ingeniería Electrónica',
  ];

  void _crearAnuncio() {
    final String titulo = _tituloController.text;
    final String texto = _textoController.text;
    final Color color = Color(0xFFFFFFFF); // Color blanco por defecto

    if (titulo.isNotEmpty && texto.isNotEmpty) {
      widget.onAnuncioCreado(
          titulo,
          texto,
          color,
          _categoriaSeleccionada,
          _tieneArchivos,
          _archivosAdjuntos.isNotEmpty ? _archivosAdjuntos[0]['fileUrl'] : null,
          _archivosAdjuntos.isNotEmpty
              ? _archivosAdjuntos[0]['fileKey']
              : null);
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

  void _mostrarMenuOpciones(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
              leading: Icon(Icons.poll),
              title: Text('Agregar encuesta'),
              onTap: () {
                Navigator.pop(context);
                // Implementar la lógica para agregar una encuesta
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
            ListTile(
              leading: Icon(Icons.save),
              title: Text('Guardar borrador'),
              onTap: () {
                Navigator.pop(context);
                // Implementar la lógica para guardar el borrador
              },
            ),
          ],
        );
      },
    );
  }

  // void _mostrarMenuOpciones(BuildContext context) {
  //   showMenu(
  //     context: context,
  //     position: RelativeRect.fromLTRB(MediaQuery.of(context).size.width - 100,
  //         56, 10, 0), // Ajusta la posición según sea necesario
  //     items: [
  //       PopupMenuItem(
  //         value: 'programar_envio',
  //         child: ListTile(
  //           leading: Icon(Icons.schedule_outlined),
  //           contentPadding: EdgeInsetsDirectional.only(start: 5),
  //           title: Text('Programar envío'),
  //         ),
  //       ),
  //       PopupMenuItem(
  //         value: 'agregar_encuesta',
  //         child: ListTile(
  //           leading: Icon(Icons.poll_outlined),
  //           contentPadding: EdgeInsetsDirectional.only(start: 5),
  //           title: Text('Agregar encuesta'),
  //         ),
  //       ),
  //       PopupMenuItem(
  //         value: 'eliminar_archivos',
  //         child: ListTile(
  //           leading: Icon(Icons.delete_sweep_outlined),
  //           contentPadding: EdgeInsetsDirectional.only(start: 5),
  //           title: Text('Eliminar archivos adjuntos'),
  //         ),
  //       ),
  //       PopupMenuItem(
  //         value: 'guardar_borrador',
  //         child: ListTile(
  //           leading: Icon(Icons.save_outlined),
  //           contentPadding: EdgeInsetsDirectional.only(start: 5),
  //           title: Text('Guardar borrador'),
  //         ),
  //       ),
  //     ],
  //   ).then((value) {
  //     if (value != null) {
  //       switch (value) {
  //         case 'programar_envio':
  //           // Implementar la lógica para programar el envío
  //           break;
  //         case 'agregar_encuesta':
  //           // Implementar la lógica para agregar una encuesta
  //           break;
  //         case 'eliminar_archivos':
  //           setState(() {
  //             _archivosAdjuntos.clear();
  //             _tieneArchivos = false;
  //           });
  //           break;
  //         case 'guardar_borrador':
  //           // Implementar la lógica para guardar el borrador
  //           break;
  //       }
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
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
            onPressed: _crearAnuncio,
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () => _mostrarMenuOpciones(context),
          ),
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
                color: Color.fromARGB(255, 245, 245, 245),
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
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 18.0),
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
                                fontWeight: FontWeight.bold,
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
                            "Título: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _tituloController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Escribe un título",
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
                      Row(
                        children: [
                          Text(
                            "Categoría: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16),
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
                                        fontSize: 14.5,
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
                      TextField(
                        controller: _textoController,
                        decoration: InputDecoration(
                          hintText: "Redactar un anuncio",
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
