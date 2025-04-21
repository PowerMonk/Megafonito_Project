import 'package:flutter/material.dart';

class ContactosEscolaresScreen extends StatefulWidget {
  @override
  _ContactosEscolaresScreenState createState() =>
      _ContactosEscolaresScreenState();
}

class _ContactosEscolaresScreenState extends State<ContactosEscolaresScreen> {
  final List<Map<String, String>> contactos = [
    {
      'name': 'Profesor Juan Pérez',
      'phone': '555-1234',
      'email': 'juan.perez@escuela.edu',
      'location': 'Edificio A',
    },
    {
      'name': 'Administradora María López',
      'phone': '555-5678',
      'email': 'maria.lopez@escuela.edu',
      'location': 'Edificio F',
    },
    {
      'name': 'Profesor Carlos García',
      'phone': '555-8765',
      'email': 'carlos.garcia@escuela.edu',
      'location': 'Edificio D',
    },
    {
      'name': 'Administrativa Ana Torres',
      'phone': '555-4321',
      'email': 'ana.torres@escuela.edu',
      'location': 'Edificio H',
    },
  ];

  String query = '';

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text('Contactos Escolares',
    //         style: TextStyle(color: Colors.white)), // Título en blanco
    //     backgroundColor: Color(0xFF14213D), // Azul oscuro
    //   ),
    // Return just the content without Scaffold or AppBar
    return Container(
      color: Color.fromARGB(255, 250, 250, 250),
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                query = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              labelText: 'Buscar por nombre',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide(
                  color: Color(0xFF14213D), // Same blue as the commented AppBar
                  width: 2.0,
                ),
              ),
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: contactos
                  .where((contacto) =>
                      contacto['name']!.toLowerCase().contains(query))
                  .map((contacto) => _buildContactCard(
                        name: contacto['name']!,
                        phone: contacto['phone']!,
                        email: contacto['email']!,
                        location: contacto['location']!,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required String name,
    required String phone,
    required String email,
    required String location,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2.2, // Sombra más pronunciada
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Bordes redondeados
        side: BorderSide(
            color:
                const Color.fromARGB(100, 160, 158, 158), // 100 is ~39% opacity
            width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Azul oscuro
              ),
            ),
            SizedBox(height: 8),
            Text('Teléfono: $phone',
                style: TextStyle(color: Colors.black)), // Gris oscuro
            Text('Correo: $email',
                style: TextStyle(color: Colors.black)), // Gris oscuro
            Text('Ubicación: $location',
                style: TextStyle(color: Colors.black)), // Gris oscuro
          ],
        ),
      ),
    );
  }
}
