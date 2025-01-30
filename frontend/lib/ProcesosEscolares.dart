import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ProcesosEscolaresScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Procesos Escolares',
          style: TextStyle(color: Colors.white), // Título en blanco
        ),
        backgroundColor: Color(0xFF14213D), // Color del AppBar
        iconTheme:
            IconThemeData(color: Colors.white), // Icono de regreso en blanco
      ),
      body: Container(
        color: Color(0xFFF0F0F0), // Fondo gris claro
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageScreen(
                        title: 'Proceso de Reinscripción',
                        imagePaths: [
                          'assets/Reins_1.png',
                          'assets/Reins_2.png',
                          'assets/Reins_3.png',
                        ],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFCA311), // Color del botón
                  padding: EdgeInsets.symmetric(
                      vertical: 16, horizontal: 30), // Aumentar padding
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Bordes redondeados
                  ),
                ),
                child: Text(
                  'Proceso de Reinscripción',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black), // Aumentar tamaño de texto
                ),
              ),
              SizedBox(height: 20), // Espacio entre botones
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageScreen(
                        title: 'Calendario de Reinscripción',
                        imagePaths: [
                          'assets/Imag1.png',
                          'assets/Imag2.png',
                        ],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFCA311), // Color del botón
                  padding: EdgeInsets.symmetric(
                      vertical: 16, horizontal: 30), // Aumentar padding
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Bordes redondeados
                  ),
                ),
                child: Text(
                  'Calendario de Reinscripción',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black), // Aumentar tamaño de texto
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageScreen extends StatelessWidget {
  final String title;
  final List<String> imagePaths;

  ImageScreen({required this.title, required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: Colors.white), // Título en blanco
        ),
        backgroundColor: Color(0xFF14213D),
        iconTheme:
            IconThemeData(color: Colors.white), // Icono de regreso en blanco
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFF1D1D1D), // Fondo oscuro para la sección de imágenes
          child: Column(
            children: imagePaths.map((imagePath) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PhotoViewScreen(imagePath: imagePath),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(
                      vertical: 10), // Espacio entre imágenes
                  decoration: BoxDecoration(
                    color:
                        Color(0xFF333333), // Fondo oscuro detrás de la imagen
                    borderRadius:
                        BorderRadius.circular(10), // Bordes redondeados
                    border: Border.all(
                        color: Color(0xFFFCA311), width: 2), // Borde dorado
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Center(
                      // Centrar la imagen
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover, // Ajuste para que cubra el espacio
                        width: double.infinity, // Ancho completo
                        height: 300, // Altura ajustada a 300
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class PhotoViewScreen extends StatelessWidget {
  final String imagePath;

  PhotoViewScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoView(
        imageProvider: AssetImage(imagePath),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
      ),
    );
  }
}
