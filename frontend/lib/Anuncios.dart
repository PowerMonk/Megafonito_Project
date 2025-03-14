import 'package:flutter/material.dart';
import 'package:flutter_megafonito/Soporte.dart';
import 'CrearNuvAnuncio.dart'; // Asegúrate de que la ruta sea correcta
import 'ContactoEscolar.dart'; // Asegúrate de que la ruta sea correcta
import 'InfoUsuario.dart'; // Asegúrate de que la ruta sea correcta
import 'ProcesosEscolares.dart'; // Asegúrate de que la ruta sea correcta
import 'Beneficios.dart'; // Asegúrate de que la ruta sea correcta
import 'NoticesFilter.dart'; // Importar el filtro de anuncios de la parte superior
import "NoticesTags.dart"; // Importar los tags de los anuncios
import 'service.dart';

class AnunciosScreen extends StatefulWidget {
  final bool isSuperUser;
  final String userName; // Nombre del usuario
  final String userEmail; // Correo del usuario

  AnunciosScreen({
    this.isSuperUser = false,
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
  // String? _selectedImportance; // Filtro de importancia
  DateTime? _selectedDate; // Filtro de fecha
  // Filtros de categoría y orden de la parte superior
  String? _selectedCategory;
  String? _selectedSortOption;
  // Lista para las pantallas de la aplicación
  int _currentIndex = 0;
  // late List<Widget> _screens;

  final List<String> _screenTitles = [
    'Megafonito',
    'Contactos Escolares',
    'Becas',
    'Procesos Escolares',
    'Soporte Megafonito',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    // Valores para la lista de pantallas
    // Esta feature fue removida debido a que cargaba las pantallas de manera estática y no se actualizaban cuando habían nuevos anuncios
    // _screens = [
    //   _buildAnunciosContent(), // Current screen's content
    //   ContactosEscolaresScreen(),
    //   ProcesosEscolaresScreen(),
    //   SoporteMegafonitoScreen(),
    //   BeneficiosScreen(),
    // ];
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

// Update the navigateToCrearNuevoAnuncio method in Anuncios.dart
  void _navigateToCrearNuevoAnuncio() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearNuevoAnuncioScreen(
          onAnuncioCreado:
              (titulo, texto, color, categoria, tieneArchivos) async {
            try {
              // Send announcement to backend
              final response = await ApiService.authenticatedRequest(
                '/notices', // Update this to your actual endpoint
                'POST',
                body: {
                  'title': titulo,
                  'content': texto,
                  'userId': 1, // Temporary value until you fix auth
                  'category': categoria,
                  'hasFile': 0, // Changed from hasFiles to hasFile
                  'fileUrl': null,
                  'fileKey': null,
                },
              );

              if (response.statusCode == 201) {
                // If created successfully, add to local list and update UI
                setState(() {
                  _anuncios.add({
                    'titulo': titulo,
                    'texto': texto,
                    'color': color,
                    'categoria': categoria,
                    'tieneArchivos': tieneArchivos,
                    'fecha': DateTime.now(), // Add date for filtering
                  });
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Anuncio creado con éxito')),
                );
              } else {
                throw Exception('Error creating announcement');
              }
            } catch (e) {
              print('Error creating announcement: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al crear el anuncio')),
              );
            }
          },
        ),
      ),
    );
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

// FUNCIONES COMENTADAS PORQUE NO SE USAN POR AHORA Y PARA AHORRAR MEMORIA

  // void _navigateToContactosEscolares() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ContactosEscolaresScreen(),
  //     ),
  //   ).then((_) {
  //     if (_isMenuOpen) {
  //       _toggleMenu();
  //     }
  //   });
  // }

  //  void _navigateToProcesosEscolares() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ProcesosEscolaresScreen(),
  //     ),
  //   ).then((_) {
  //     if (_isMenuOpen) {
  //       _toggleMenu();
  //     }
  //   });
  // }

  // void _navigateToBeneficios() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => BeneficiosScreen(),
  //     ),
  //   ).then((_) {
  //     if (_isMenuOpen) {
  //       _toggleMenu();
  //     }
  //   });
  // }

  // void _navigateToSoporte() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => SoporteMegafonitoScreen(),
  //     ),
  //   ).then((_) {
  //     if (_isMenuOpen) {
  //       _toggleMenu();
  //     }
  //   });
  // }

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

// Update the _filterAnuncios method in Anuncios.dart
  void _filterAnuncios() {
    List<Map<String, dynamic>> filteredAnuncios = _anuncios.where((anuncio) {
      // Remove importance filter as we're not using it anymore
      bool matchesDate = _selectedDate == null ||
          (anuncio['fecha'] != null &&
              (anuncio['fecha'] as DateTime).isAtSameMomentAs(_selectedDate!));

      // Use the category from the new filter
      bool matchesCategory = _selectedCategory == null ||
          _selectedCategory == '' ||
          anuncio['categoria'] == _selectedCategory;

      return matchesDate && matchesCategory;
    }).toList();

    if (_selectedSortOption == 'Más recientes') {
      filteredAnuncios.sort(
          (a, b) => (b['fecha'] as DateTime).compareTo(a['fecha'] as DateTime));
    } else if (_selectedSortOption == 'Más antiguos') {
      filteredAnuncios.sort(
          (a, b) => (a['fecha'] as DateTime).compareTo(b['fecha'] as DateTime));
    } else if (_selectedSortOption == 'Con archivos') {
      filteredAnuncios = filteredAnuncios
          .where((anuncio) => anuncio['tieneArchivos'] == true)
          .toList();
    }

    setState(() {
      _anuncios = filteredAnuncios;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitles[_currentIndex],
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF14213D),
        actions: [
          IconButton(
              onPressed: () => _navigateToUserInfo(),
              icon: Icon(Icons.account_circle_outlined)),
        ],
      ),
      body: _currentIndex == 0
          ? _buildAnunciosContent() // Dynamically build announcements when selected
          // Ahora se actualizan cada que se agrega nuevo contenido
          : IndexedStack(
              index: _currentIndex - 1, // Adjust index
              children: [
                ContactosEscolaresScreen(),
                BeneficiosScreen(),
                ProcesosEscolaresScreen(),
                SoporteMegafonitoScreen(),
              ],
            ),
      floatingActionButton: _currentIndex == 0 && widget.isSuperUser
          ? FloatingActionButton(
              onPressed: _navigateToCrearNuevoAnuncio,
              backgroundColor: Color(0xFFFCA311),
              child: Icon(Icons.add, color: Colors.black),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Color(0xFF14213D),
        selectedItemColor: Color(0xFFFCA311),
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: 'Contactos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Becas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Procesos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support),
            label: 'Soporte',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildAnunciosContent() {
    return Container(
      color: Color(0xFFE5E5E5),
      child: Column(
        children: [
          NoticesFilter(
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
              _filterAnuncios();
            },
            onSortOptionSelected: (sortOption) {
              setState(() {
                _selectedSortOption = sortOption;
              });
              _filterAnuncios();
            },
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
                        // Row with title and icons/tags
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título with Expanded to take available space
                            Expanded(
                              child: Text(
                                anuncio['titulo'],
                                style: TextStyle(
                                    color: Color(0xFF000000), fontSize: 18),
                              ),
                            ),
                            // Category tag and file icon if exists
                            Row(
                              children: [
                                NoticeTag(category: anuncio['categoria'] ?? ''),
                                if (anuncio['tieneArchivos'] == true)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: FileAttachmentIcon(),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        // Expanded content
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
