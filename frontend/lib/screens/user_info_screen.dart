import 'package:flutter/material.dart';
import 'login_screen.dart';

class UserInfoScreen extends StatelessWidget {
  final String name;
  final String email;

  UserInfoScreen({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Fondo claro
      padding: EdgeInsets.all(16.0), // Espaciado
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nombre:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF14213D), // Color del texto
              ),
            ),
            SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              'Correo Electrónico:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF14213D), // Color del texto
              ),
            ),
            SizedBox(height: 10),
            Text(
              email,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Navegar de vuelta a la pantalla de inicio de sesión
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFCA311), // Color del botón
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Bordes redondeados
                ),
              ),
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
