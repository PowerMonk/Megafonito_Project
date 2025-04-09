// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'anuncios_screen.dart';
import 'register_screen.dart';

// Imagina que este es un cambio importante (solo se cambiaron archivos que no llegarán al repo remoto)

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String? username;
  String? password;
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Call auth service to login
        final user = await AuthService.login(context, username!);

        setState(() {
          _isLoading = false;
        });

        // Navigate to AnunciosScreen with the user role info
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AnunciosScreen(
              userName: user.name,
              // userName: widget.userName,
              userEmail: user.email,
              isSuperUser: AuthService.isAdmin,
            ),
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        // Error is already shown by the service
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Decorative dots at top-left
          Positioned(
            top: 40,
            left: 20,
            child: Row(
              children: [
                _buildDot(),
                SizedBox(width: 8),
                _buildDot(),
                SizedBox(width: 8),
                _buildDot(),
              ],
            ),
          ),

          // Decorative dots at top-right
          Positioned(
            top: 40,
            right: 20,
            child: Row(
              children: [
                _buildDot(),
                SizedBox(width: 8),
                _buildDot(),
                SizedBox(width: 8),
                _buildDot(),
              ],
            ),
          ),

          // Main content
          Column(
            children: [
              // Add space at the top to push content down
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              // Logo and welcome texts (top 3/5 of screen)
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/Megafonito.svg',
                      height: 130,
                      width: 130,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'MEGAFONITO',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w900,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    SizedBox(height: 25),
                    Text(
                      'Bienvenido',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w400,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    SizedBox(height: 40),
                    Text(
                      '"Enterate de eventos, cambios y avisos oficiales"',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 44, 43, 43),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Login container (bottom 2/5 of screen)
              Container(
                height: MediaQuery.of(context).size.height * 1 / 3,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 60),
                child: Column(
                  children: [
                    SizedBox(height: 24),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Inicia con tu correo institucional',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Google login implementation
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(240, 240, 240, 240),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Image.asset(
                        'assets/GoogleIcon.png', // Asegúrate de tener este logo en tus assets
                        height: 24,
                        width: 24,
                      ),
                      label: Text(
                        'Continuar con Google',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                    // SizedBox(height: 1),
                    TextButton(
                      onPressed: () {
                        // Password recovery action
                      },
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                    Spacer(), // Pushes the problems text to bottom
                    TextButton(
                      onPressed: () {
                        // Login issues action
                      },
                      child: Text(
                        '¿Problemas al iniciar sesión?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to create a decorative dot
  Widget _buildDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 0, 0, 0),
        shape: BoxShape.circle,
      ),
    );
  }
}
