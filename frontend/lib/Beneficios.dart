import 'package:flutter/material.dart';

class BeneficiosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text('Beneficios',
    //         style: TextStyle(color: Colors.white)), // Título en blanco
    //     backgroundColor: Color(0xFF14213D), // Azul oscuro
    //   ),
    // Return just the content without Scaffold or AppBar
    return Container(
      color: Colors.white, // Fondo blanco
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(context, 'Becas Escolares'),
            SizedBox(height: 20),
            _buildButton(context, 'Becas Alimenticias'),
            SizedBox(height: 20),
            _buildButton(context, 'Programas de Apoyo'), // Tercer ejemplo
          ],
        ),
      ),
    );
    // );
  }

  Widget _buildButton(BuildContext context, String title) {
    return ElevatedButton(
      onPressed: () {
        // Aquí puedes añadir la lógica que desees para cada botón
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navegando a $title')),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF14213D), // Azul oscuro
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        textStyle: TextStyle(fontSize: 18),
      ),
      child:
          Text(title, style: TextStyle(color: Colors.white)), // Texto en blanco
    );
  }
}
