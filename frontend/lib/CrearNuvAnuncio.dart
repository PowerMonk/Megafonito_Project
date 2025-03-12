import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Add this import
import 'dart:io'; // For File operations

class CrearNuevoAnuncioScreen extends StatefulWidget {
  final Function(String, String, Color, String, bool) onAnuncioCreado;

  CrearNuevoAnuncioScreen({required this.onAnuncioCreado});

  @override
  _CrearNuevoAnuncioScreenState createState() =>
      _CrearNuevoAnuncioScreenState();
}

class _CrearNuevoAnuncioScreenState extends State<CrearNuevoAnuncioScreen> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _textoController = TextEditingController();
  String _categoriaSeleccionada = 'Materias';
  bool _tieneArchivos = false;

  // Lista de categorías (misma que en NoticesFilter)
  final List<String> _categorias = [
    'Materias',
    'Convocatorias',
    'Eventos',
    'Deportivos',
    'Culturales',
    'Comunidad',
  ];

  void _crearAnuncio() {
    final String titulo = _tituloController.text;
    final String texto = _textoController.text;
    final Color color = Color(0xFFFFFFFF); // Color blanco por defecto

    if (titulo.isNotEmpty && texto.isNotEmpty) {
      widget.onAnuncioCreado(
          titulo, texto, color, _categoriaSeleccionada, _tieneArchivos);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
    }
  }

  void _agregarArchivo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        // File was picked
        File file = File(result.files.single.path!);

        setState(() {
          _tieneArchivos = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Archivo "${result.files.single.name}" adjuntado correctamente')),
        );
      } else {
        // User canceled the picker
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se seleccionó ningún archivo')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al seleccionar archivo: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crear Nuevo Anuncio',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Color(0xFF14213D),
      ),
      body: Container(
        color: Color(0xFFE5E5E5),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_tituloController, 'Título'),
                SizedBox(height: 16),
                _buildTextField(_textoController, 'Texto', maxLines: 4),
                SizedBox(height: 16),

                // Botón para adjuntar archivos centrado
                ElevatedButton.icon(
                  onPressed: _agregarArchivo,
                  icon: Icon(Icons.attach_file, color: Colors.black),
                  label: Text(
                    'Agregar archivo',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFCA311),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                // Botón para adjuntar archivos del lado izquierdo
                // Align(
                //   alignment: Alignment.centerLeft, // Lo alinea a la izquierda
                //   child: ElevatedButton.icon(
                //     onPressed: _agregarArchivo,
                //     icon: Icon(Icons.attach_file, color: Colors.black),
                //     label: Text(
                //       'Agregar archivo',
                //       style: TextStyle(color: Colors.black),
                //     ),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Color(0xFFFCA311),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(15),
                //       ),
                //     ),
                //   ),
                // ),

                SizedBox(height: 16),
                _buildCategoryDropdown(),
                SizedBox(height: 20),
                _buildElevatedButton('Crear Anuncio', _crearAnuncio),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF000000)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFF14213D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFFFCA311)),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFF14213D)),
      ),
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(category, style: TextStyle(color: Color(0xFF000000))),
            ),
          );
        }).toList(),
        isExpanded: true,
        underline: SizedBox(), // Eliminar la línea subrayada
      ),
    );
  }

  Widget _buildElevatedButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFCA311),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
      child: Text(
        label,
        style: TextStyle(color: Color(0xFF000000)),
      ),
    );
  }
}
