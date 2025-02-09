import 'package:flutter/material.dart';
import 'CrearNuvAnuncio.dart'; // Asegúrate de que la ruta sea correcta
import 'ContactoEscolar.dart'; // Asegúrate de que la ruta sea correcta
import 'InfoUsuario.dart'; // Asegúrate de que la ruta sea correcta
import 'ProcesosEscolares.dart'; // Asegúrate de que la ruta sea correcta
import 'Beneficios.dart'; // Asegúrate de que la ruta sea correcta

class AnunciosScreen extends StatefulWidget {
  final bool isSuperUser;
  final String userName; // Nombre del usuario
  final String userEmail; // Correo del usuario

  AnunciosScreen({
    required this.isSuperUser,
    required this.userName,
    required this.userEmail,
  });

  @override
  _AnunciosScreenState createState() => _AnunciosScreenState();
}

class _AnunciosScreenState extends State<AnunciosScreen>
    with SingleTickerProviderStateMixin {
  bool _isMenuOpen = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Map<String, dynamic>> _anuncios = []; // Lista para almacenar anuncios
  Set<int> _expandedIndices = {}; // Para rastrear índices expandidos
  String? _selectedImportance; // Filtro de importancia
  DateTime? _selectedDate; // Filtro de fecha

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      _isMenuOpen ? _controller.forward() : _controller.reverse();
    });
  }

  void _navigateToCrearNuevoAnuncio() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearNuevoAnuncioScreen(
          onAnuncioCreado: (titulo, texto, color) {
            setState(() {
              _anuncios.add({
                'titulo': titulo,
                'texto': texto,
                'color': color,
                'importancia': _selectedImportance, // Añadir importancia
              });
            });
            _filterAnuncios(); // Filtrar después de añadir un nuevo anuncio
          },
        ),
      ),
    ).then((_) {
      if (_isMenuOpen) {
        _toggleMenu();
      }
    });
  }

  void _navigateToContactosEscolares() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactosEscolaresScreen(),
      ),
    ).then((_) {
      if (_isMenuOpen) {
        _toggleMenu();
      }
    });
  }

  void _navigateToUserInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserInfoScreen(
          name: widget.userName,
          email: widget.userEmail,
        ),
      ),
    ).then((_) {
      if (_isMenuOpen) {
        _toggleMenu();
      }
    });
  }

  void _navigateToProcesosEscolares() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProcesosEscolaresScreen(),
      ),
    ).then((_) {
      if (_isMenuOpen) {
        _toggleMenu();
      }
    });
  }

  void _navigateToBeneficios() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BeneficiosScreen(),
      ),
    ).then((_) {
      if (_isMenuOpen) {
        _toggleMenu();
      }
    });
  }

  void _toggleExpansion(int index) {
    setState(() {
      if (_expandedIndices.contains(index)) {
        _expandedIndices.remove(index);
      } else {
        _expandedIndices.add(index);
      }
      if (_isMenuOpen) {
        _toggleMenu();
      }
    });
  }

  void _filterAnuncios() {
    print(
        'Filtrar por importancia: $_selectedImportance, fecha: $_selectedDate');
    List<Map<String, dynamic>> filteredAnuncios = _anuncios.where((anuncio) {
      bool matchesImportance = _selectedImportance == null ||
          anuncio['importancia'] == _selectedImportance;
      bool matchesDate = _selectedDate == null ||
          (anuncio['fecha'] != null &&
              (anuncio['fecha'] as DateTime).isAtSameMomentAs(_selectedDate!));
      return matchesImportance && matchesDate;
    }).toList();
    setState(() {
      _anuncios = filteredAnuncios;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Anuncios',
          style: TextStyle(color: Colors.white), // Título en blanco
        ),
        backgroundColor: Color(0xFF14213D), // Azul oscuro
      ),
      body: Container(
        color: Color(0xFFE5E5E5), // Fondo gris claro
        child: Column(
          children: [
            // Filtros
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    hint: Text('Importancia'),
                    value: _selectedImportance,
                    items: ['Normal', 'Medio Importante', 'Importante']
                        .map((importance) => DropdownMenuItem(
                              value: importance,
                              child: Text(importance),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedImportance = value;
                      });
                      _filterAnuncios();
                    },
                  ),
                  TextButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                        _filterAnuncios();
                      }
                    },
                    child: Text(
                      _selectedDate == null
                          ? 'Seleccionar Fecha'
                          : 'Fecha: ${_selectedDate!.toLocal()}'.split(' ')[0],
                      style: TextStyle(color: Color(0xFF14213D)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: _anuncios.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> anuncio = entry.value;
                  bool isExpanded = _expandedIndices.contains(index);

                  return GestureDetector(
                    onTap: () => _toggleExpansion(index),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: anuncio['color'] ?? Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            anuncio['titulo'],
                            style: TextStyle(
                                color: Color(0xFF000000), fontSize: 18),
                          ),
                          if (isExpanded) ...[
                            SizedBox(height: 8),
                            Text(
                              anuncio['texto'],
                              style: TextStyle(color: Color(0xFF000000)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleMenu,
        backgroundColor: Color(0xFFFCA311), // Naranja
        child: Icon(_isMenuOpen ? Icons.close : Icons.menu,
            color: Color(0xFF000000)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _isMenuOpen
          ? FadeTransition(
              opacity: _animation,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF14213D), Color(0xFFFCA311)], // Gradiente
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isSuperUser)
                      GestureDetector(
                        onTap: _navigateToCrearNuevoAnuncio,
                        child:
                            _buildMenuOption(Icons.add, 'Crear nuevo anuncio'),
                      ),
                    GestureDetector(
                      onTap: _navigateToContactosEscolares,
                      child: _buildMenuOption(
                          Icons.contact_mail, 'Contacto Escolar'),
                    ),
                    GestureDetector(
                      onTap:
                          _navigateToUserInfo, // Navegar a Información de usuario
                      child: _buildMenuOption(
                          Icons.info, 'Información de usuario'),
                    ),
                    GestureDetector(
                      onTap:
                          _navigateToProcesosEscolares, // Navegar a Procesos Escolares
                      child: _buildMenuOption(Icons.school, 'Procesos Escolar'),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Lógica para "Soporte"
                      },
                      child: _buildMenuOption(Icons.support, 'Soporte'),
                    ),
                    // Botón para navegar a la pantalla de beneficios
                    GestureDetector(
                      onTap: _navigateToBeneficios,
                      child: _buildMenuOption(Icons.star, 'Beneficios'),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildMenuOption(IconData icon, String label) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, // Fondo blanco
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Color(0xFF14213D), size: 20), // Azul oscuro
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF14213D), // Azul oscuro
              fontSize: 16,
              fontWeight: FontWeight.bold, // Texto en negrita
            ),
          ),
        ],
      ),
    );
  }
}
