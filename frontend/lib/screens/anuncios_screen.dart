import 'package:flutter/material.dart';
import '../widgets/notice_card.dart';
import '../services/notices_service.dart';
import '../services/api_service.dart';
import '../widgets/notices_filter.dart'; // Keep this for now, will refactor later
import '../widgets/notice_tags.dart';
import 'crear_anuncio_screen.dart'; // Will refactor later
import 'support_screen.dart';
import 'contact_screen.dart';
import 'school_processes_screen.dart';
import 'benefits_screen.dart';
import 'user_info_screen.dart';

class AnunciosScreen extends StatefulWidget {
  final bool isSuperUser;
  final String userName;
  final String userEmail;

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
  List<Map<String, dynamic>> _anuncios = [];
  Set<int> _expandedIndices = {};
  String? _selectedCategory;
  String? _selectedSortOption;
  int _currentIndex = 0;

  // Pagination variables
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;

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

    // Load notices when the screen initializes
    _loadNotices();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadNotices({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _currentPage = 1;
        _hasMoreData = true;
        _anuncios = [];
      }
    });

    try {
      final result = await NoticesService.loadNotices(
        page: _currentPage,
        limit: 5,
        category: _selectedCategory,
        hasFiles: _selectedSortOption == 'Con archivos' ? true : null,
      );

      print('API Response: $result');
      print('Data type: ${result['data'].runtimeType}');
      print('Pagination: ${result['pagination']}');

      final List<dynamic> notices = result['data'];
      final pagination = result['pagination'];
      final totalPages = pagination['totalPages'];

      setState(() {
        // Convert API response to match our local format
        _anuncios.addAll(notices
            .map((notice) => {
                  'titulo': notice['title'],
                  'texto': notice['content'],
                  'categoria': notice['category'] ?? 'Materias',
                  'tieneArchivos': notice['has_file'] == 1,
                  // Null-safe version
                  'fecha': notice['created_at'] != null
                      ? DateTime.tryParse(notice['created_at'])
                      : DateTime.now(),
                })
            .toList());

// VERSION ORIGINAL
        // _hasMoreData = pagination['currentPage'] < pagination['totalPages'];
        // _currentPage++;

        // DS Version
        final currentPage = pagination['currentPage'] as int? ?? 1;
        final totalPages = pagination['totalPages'] as int? ?? 1;
        _hasMoreData = currentPage < totalPages;

        _currentPage++;

        // null-safe version
        // _hasMoreData = pagination != null &&
        //     pagination['currentPage'] != null &&
        //     pagination['totalPages'] != null &&
        //     (pagination['currentPage'] as num) <
        //         (pagination['totalPages'] as num);

        _isLoading = false;
      });

      if (_selectedSortOption == 'Más recientes' ||
          _selectedSortOption == 'Más antiguos') {
        _anuncios = NoticesService.sortNotices(_anuncios, _selectedSortOption);
      }
    } catch (e) {
      print('Error loading notices: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar anuncios: $e')),
      );
    }
  }

  void _filterAnuncios() {
    _loadNotices(refresh: true);
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

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      _isMenuOpen ? _controller.forward() : _controller.reverse();
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

  void _navigateToCrearNuevoAnuncio() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearNuevoAnuncioScreen(
          onAnuncioCreado: (titulo, texto, color, categoria, tieneArchivos,
              fileUrl, fileKey) async {
            try {
              await NoticesService.createNotice(
                context,
                title: titulo,
                content: texto,
                category: categoria,
                hasFile: tieneArchivos,
                fileUrl: fileUrl,
                fileKey: fileKey,
              );

              // Refresh the notices list after creating a new one
              _loadNotices(refresh: true);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Anuncio creado con éxito')),
              );
            } catch (e) {
              print('Error creating announcement: $e');
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text('Error al crear el anuncio: $e')),
              // );
            }
          },
        ),
      ),
    );
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
            child: _isLoading && _anuncios.isEmpty
                ? Center(child: CircularProgressIndicator())
                : _anuncios.isEmpty
                    ? Center(child: Text('No hay anuncios disponibles'))
                    : RefreshIndicator(
                        onRefresh: () => _loadNotices(refresh: true),
                        child: ListView(
                          padding: EdgeInsets.all(16.0),
                          children: [
                            ..._anuncios.asMap().entries.map((entry) {
                              int index = entry.key;
                              Map<String, dynamic> anuncio = entry.value;
                              bool isExpanded =
                                  _expandedIndices.contains(index);

                              return NoticeCard(
                                notice: anuncio,
                                isExpanded: isExpanded,
                                onTap: () => _toggleExpansion(index),
                              );
                            }).toList(),

                            // Loading more indicator
                            if (_isLoading)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ),

                            // Load more button
                            if (!_isLoading && _hasMoreData)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: ElevatedButton(
                                    onPressed: _loadNotices,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFFCA311),
                                    ),
                                    child: Text('Cargar más anuncios'),
                                  ),
                                ),
                              ),
                          ],
                        ),
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
        color: Colors.white,
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
          Icon(icon, color: Color(0xFF14213D), size: 20),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF14213D),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
