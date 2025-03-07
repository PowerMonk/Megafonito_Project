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
      'website': 'www.escuela.edu/profesor-juan',
    },
    {
      'name': 'Administradora María López',
      'phone': '555-5678',
      'email': 'maria.lopez@escuela.edu',
      'website': 'www.escuela.edu/administradora-maria',
    },
    {
      'name': 'Profesor Carlos García',
      'phone': '555-8765',
      'email': 'carlos.garcia@escuela.edu',
      'website': 'www.escuela.edu/profesor-carlos',
    },
    {
      'name': 'Administrativa Ana Torres',
      'phone': '555-4321',
      'email': 'ana.torres@escuela.edu',
      'website': 'www.escuela.edu/administrativa-ana',
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
      color: Colors.white,
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
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
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
                        website: contacto['website']!,
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
    required String website,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 5, // Sombra más pronunciada
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Bordes redondeados
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
                color: Color(0xFF14213D), // Azul oscuro
              ),
            ),
            SizedBox(height: 8),
            Text('Teléfono: $phone',
                style: TextStyle(color: Color(0xFF333333))), // Gris oscuro
            Text('Correo: $email',
                style: TextStyle(color: Color(0xFF333333))), // Gris oscuro
            Text('Página Web: $website',
                style: TextStyle(color: Color(0xFF333333))), // Gris oscuro
          ],
        ),
      ),
    );
  }
}
