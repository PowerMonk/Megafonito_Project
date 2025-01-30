import 'package:flutter/material.dart';
import 'dart:async';
import 'Anuncios.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Eliminar el banner de debug
      title: 'Login Demo',
      theme: ThemeData(
        primaryColor: Color(0xFF14213D), // Azul oscuro
        scaffoldBackgroundColor: Color(0xFF14213D), // Fondo azul oscuro
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Color(0xFF000000)), // Negro
        ),
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double progress = 0;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        progress += 0.1;
      });

      if (progress >= 1) {
        timer.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF14213D), // Fondo azul oscuro
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/LogoMegafon_V2.png',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 20),
            Text(
              'Cargando...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFCA311), // Naranja
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 300,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 20,
                backgroundColor: Color(0xFFE5E5E5), // Gris claro
                valueColor:
                    AlwaysStoppedAnimation<Color>(Color(0xFFFCA311)), // Naranja
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class User {
  String name;
  String email;
  String password;

  User({required this.name, required this.email, required this.password});
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;

  // Lista para almacenar los usuarios registrados
  List<User> registeredUsers = [
    User(
        name: 'Super Usuario',
        email: 'superusuario@example.com',
        password: '123456'),
    User(
        name: 'Usuario Alumno',
        email: 'alumno@example.com',
        password: '123456'),
  ];

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Validar credenciales
      User? foundUser = registeredUsers.firstWhere(
        (user) => user.email == email && user.password == password,
        orElse: () => User(name: '', email: '', password: ''),
      );

      if (foundUser.email.isNotEmpty) {
        // Redirigir a la pantalla de anuncios
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AnunciosScreen(
              isSuperUser: foundUser.name ==
                  'Super Usuario', // Determinar si es super usuario
              userName: foundUser.name, // Pasar el nombre del usuario
              userEmail:
                  foundUser.email, // Pasar el correo electrónico del usuario
            ),
          ),
        );
      } else {
        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Credenciales incorrectas')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/LogoMegafon_V2.png', // Cambia el nombre de la imagen
                width: 150, // Tamaño aumentado
                height: 150,
              ),
              SizedBox(height: 20),
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF14213D), // Azul oscuro
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Correo Electrónico',
                            labelStyle: TextStyle(
                                color: Color(0xFF14213D)), // Azul oscuro
                            filled: true,
                            fillColor: Color(0xFFE5E5E5), // Gris claro
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: Color(0xFF14213D)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu correo electrónico';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            email = value;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            labelStyle: TextStyle(
                                color: Color(0xFF14213D)), // Azul oscuro
                            filled: true,
                            fillColor: Color(0xFFE5E5E5), // Gris claro
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: Color(0xFF14213D)),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu contraseña';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            password = value;
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFCA311), // Naranja
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Iniciar Sesión',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            // Acción para olvidar contraseña
                          },
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                                color: Color(0xFF14213D)), // Azul oscuro
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navegar a la pantalla de registro
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RegisterScreen(
                                  onUserRegistered: (User user) {
                                    setState(() {
                                      registeredUsers.add(user);
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                          child: Text(
                            '¿Quieres registrarte?',
                            style: TextStyle(
                                color: Color(0xFF14213D)), // Azul oscuro
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  final Function(User) onUserRegistered;

  RegisterScreen({required this.onUserRegistered});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? email;
  String? password;

  void _register() {
    if (_formKey.currentState!.validate()) {
      // Crear un nuevo usuario
      User newUser = User(name: name!, email: email!, password: password!);
      widget.onUserRegistered(newUser); // Llamar al callback

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario registrado con éxito')),
      );
      Navigator.of(context).pop(); // Volver a la pantalla de inicio de sesión
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Usuario'),
        backgroundColor: Color(0xFF14213D), // Azul oscuro
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/LogoMegafon_V2.png', // Cambia el nombre de la imagen
                width: 150,
                height: 150,
              ),
              SizedBox(height: 20),
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Registrar Usuario',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF14213D), // Azul oscuro
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Nombre',
                            labelStyle: TextStyle(
                                color: Color(0xFF14213D)), // Azul oscuro
                            filled: true,
                            fillColor: Color(0xFFE5E5E5), // Gris claro
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: Color(0xFF14213D)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu nombre';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            name = value;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Correo Electrónico',
                            labelStyle: TextStyle(
                                color: Color(0xFF14213D)), // Azul oscuro
                            filled: true,
                            fillColor: Color(0xFFE5E5E5), // Gris claro
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: Color(0xFF14213D)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu correo electrónico';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            email = value;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            labelStyle: TextStyle(
                                color: Color(0xFF14213D)), // Azul oscuro
                            filled: true,
                            fillColor: Color(0xFFE5E5E5), // Gris claro
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: Color(0xFF14213D)),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu contraseña';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            password = value;
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFCA311), // Naranja
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Registrar',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
