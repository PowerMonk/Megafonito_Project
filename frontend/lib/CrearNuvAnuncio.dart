import 'package:flutter/material.dart';

class CrearNuevoAnuncioScreen extends StatefulWidget {
  final Function(String, String, Color) onAnuncioCreado;

  CrearNuevoAnuncioScreen({required this.onAnuncioCreado});

  @override
  _CrearNuevoAnuncioScreenState createState() =>
      _CrearNuevoAnuncioScreenState();
}

class _CrearNuevoAnuncioScreenState extends State<CrearNuevoAnuncioScreen> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _textoController = TextEditingController();
  String? _importanciaSeleccionada = 'Normal';
  final Map<String, Color> _importanciaColores = {
    'Normal': Colors.blue,
    'Medio Importante': Colors.yellow,
    'Importante': Colors.red,
  };

  void _crearAnuncio() {
    final String titulo = _tituloController.text;
    final String texto = _textoController.text;
    final Color color = _importanciaColores[_importanciaSeleccionada!]!;

    if (titulo.isNotEmpty && texto.isNotEmpty) {
      widget.onAnuncioCreado(titulo, texto, color);
      Navigator.pop(context); // Regresar a la pantalla anterior
    } else {
      // Muestra un mensaje de error si el título o texto están vacíos
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crear Nuevo Anuncio',
          style: TextStyle(color: Colors.white), // Texto claro en el encabezado
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              Navigator.pop(context), // Regresar a la pantalla anterior
        ),
        backgroundColor: Color(0xFF14213D), // Azul oscuro
      ),
      body: Container(
        color: Color(0xFFE5E5E5), // Fondo gris claro
        padding: const EdgeInsets.all(16.0),
        child: Center(
          // Centrar el contenido
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ajustar el tamaño del contenido
              children: [
                _buildTextField(_tituloController, 'Título'),
                SizedBox(height: 16),
                _buildTextField(_textoController, 'Texto', maxLines: 4),
                SizedBox(height: 16),
                _buildDropdown(),
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
        labelStyle:
            TextStyle(color: Color(0xFF000000)), // Texto negro para la etiqueta
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFF14213D)), // Azul oscuro
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFFFCA311)), // Naranja
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFF14213D)),
      ),
      child: DropdownButton<String>(
        value: _importanciaSeleccionada,
        onChanged: (String? newValue) {
          setState(() {
            _importanciaSeleccionada = newValue;
          });
        },
        items: _importanciaColores.keys.map((String key) {
          return DropdownMenuItem<String>(
            value: key,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(key,
                  style: TextStyle(color: Color(0xFF000000))), // Texto negro
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
        backgroundColor: Color(0xFFFCA311), // Naranja
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
      child: Text(
        label,
        style: TextStyle(color: Color(0xFF000000)), // Texto negro
      ),
    );
  }
}
