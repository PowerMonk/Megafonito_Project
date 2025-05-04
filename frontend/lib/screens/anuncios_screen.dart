import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui'; // Import for ImageFilter
import '../services/notices_service.dart';
import '../widgets/notice_card.dart';
import '../widgets/notice_detail.dart';
import '../widgets/notices_filter.dart'; // Add this import
import '../widgets/navbar.dart'; // Import the modularized navbar
import '../widgets/actions_buttons.dart'; // Import the modularized action buttons
import 'crear_anuncio_screen.dart';
import 'support_screen.dart';
import 'contact_screen.dart';
import 'school_processes_screen.dart';
import 'opportunities_screen.dart';
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
  List<Map<String, dynamic>> _anuncios = [];
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
    'Oportunidades',
    'Procesos Escolares',
    'Cuenta',
  ];

  final List<Widget> _screens = [
    ContactosEscolaresScreen(),
    OpportunitiesScreen(),
    SchoolProcessesScreen(),
    UserInfoScreen(
        // name: "OnsaDev",
        // email: "OnsaDev@mgf.com",
        )
    // SoporteMegafonitoScreen(),
  ];

  bool _showExtraFabs = false; // State for extra buttons visibility

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  // --- Data Loading ---
  Future<void> _loadNotices({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

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
      );

      final List<dynamic> notices = result['data'];
      final pagination = result['pagination'];

      setState(() {
        _anuncios.addAll(notices.map((notice) {
          bool hasAttachment = false;
          if (notice['has_attachment'] is bool) {
            hasAttachment = notice['has_attachment'];
          } else if (notice['has_attachment'] is int) {
            hasAttachment = notice['has_attachment'] == 1;
          }

          return {
            'id': notice['id'],
            'title': notice['title'] ?? 'Sin Título',
            'content': notice['content'] ?? '',
            'category': notice['category'] ?? 'General',
            'author_name': notice['author_name'] ?? 'Autor Desconocido',
            'created_at': notice['created_at'] != null
                ? DateTime.tryParse(notice['created_at']) ?? DateTime.now()
                : DateTime.now(),
            'has_attachment': hasAttachment,
            'attachment_url': notice['attachment_url'],
            'attachment_key': notice['attachment_key'],
          };
        }).toList());

        final int currentPage = pagination['currentPage'] as int? ?? 1;
        final int totalPages = pagination['totalPages'] as int? ?? 1;
        _hasMoreData = currentPage < totalPages;

        if (_hasMoreData) {
          _currentPage++;
        }

        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notices: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar anuncios: ${e.toString()}')),
        );
      }
    }
  }

  void _filterAnuncios() {
    _loadNotices(refresh: true);
  }

  // --- Navigation ---
  void _navigateToSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SoporteMegafonitoScreen()),
    );
  }

  void _navigateToCrearNuevoAnuncio() {
    // Close extra FABs if open before navigating
    if (_showExtraFabs) {
      setState(() {
        _showExtraFabs = false;
      });
      // Add a small delay to allow the FABs to animate out before navigating
      Future.delayed(Duration(milliseconds: 100), () {
        _pushCrearAnuncioScreen();
      });
    } else {
      _pushCrearAnuncioScreen();
    }
  }

  // Helper method to avoid duplication
  void _pushCrearAnuncioScreen() {
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

              _loadNotices(refresh: true);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Anuncio creado con éxito')),
                );
              }
            } catch (e) {
              print('Error creating announcement: $e');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Error al crear el anuncio: ${e.toString()}')),
                );
              }
            }
          },
        ),
      ),
    );
  }

  void _handleNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _handleShowExtraFabs() {
    setState(() {
      _showExtraFabs = true;
    });
  }

  void _handleDismissBlur() {
    setState(() {
      _showExtraFabs = false;
    });
  }

  void _handleCreateMessage() {
    // TODO: Implement action for "Nuevo Mensaje"
    print("Nuevo Mensaje tapped");
    setState(() => _showExtraFabs = false);
  }

  void _handleCreateOpportunity() {
    // TODO: Implement action for "Nuevo Mensaje"
    print("Oportunidad nueva tapped");
    setState(() => _showExtraFabs = false);
  }

  // --- UI Building ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        title: Text(_screenTitles[_currentIndex],
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _navigateToSupport,
            icon: SvgPicture.asset(
              'assets/icons/bug_icon.svg',
              height: 24.0,
              width: 24.0,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          _buildBody(),

          // Action Buttons - use the modular component
          if (_currentIndex == 0)
            ActionButtons(
              isSuperUser: widget.isSuperUser,
              showExtraFabs: _showExtraFabs,
              onShowExtraFabs: _handleShowExtraFabs,
              onCreateNotice: _navigateToCrearNuevoAnuncio,
              onCreateMessage: _handleCreateMessage,
              onCreateOpportunity: _handleCreateOpportunity,
              onDismissBlur: _handleDismissBlur,
            ),
        ],
      ),
      // Use the modularized navbar
      bottomNavigationBar: AppNavBar(
        currentIndex: _currentIndex,
        onTap: _handleNavBarTap,
      ),
      // We don't need floatingActionButton here anymore as it's part of ActionButtons
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 0) {
      // Return a Column with both the filter and NoticesContent
      return Column(
        children: [
          // Add the filters at the top
          NoticesFilter(
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category.isEmpty ? null : category;
              });
              _filterAnuncios();
            },
            onSortOptionSelected: (sortOption) {
              setState(() {
                _selectedSortOption = sortOption.isEmpty ? null : sortOption;
              });
              _filterAnuncios();
            },
          ),

          // NoticesContent fills the remaining space
          Expanded(
            child: _buildNoticesContent(),
          ),
        ],
      );
    } else {
      int stackIndex = _currentIndex - 1;
      if (stackIndex >= 0 && stackIndex < _screens.length) {
        return IndexedStack(
          index: stackIndex,
          children: _screens,
        );
      } else {
        return Center(child: Text("Pantalla no encontrada"));
      }
    }
  }

  // Helper method for building the notices content
  Widget _buildNoticesContent() {
    if (_isLoading && _anuncios.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    if (_anuncios.isEmpty) {
      return Center(child: Text('No hay anuncios disponibles.'));
    }

    return RefreshIndicator(
      onRefresh: () => _loadNotices(refresh: true),
      child: ListView.builder(
        // Add proper padding all around the content
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0,
            80.0), // Left, top, right, bottom (extra at bottom for FAB)
        itemCount: _anuncios.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          // If we're at the end and have more data, show loading indicator
          if (index == _anuncios.length && _hasMoreData) {
            // Use Future.microtask to schedule the setState() call after the build is complete
            Future.microtask(() => _loadNotices());

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Otherwise, build the notice card
          if (index < _anuncios.length) {
            final anuncio = _anuncios[index];
            return NoticeCard(
              anuncio: anuncio,
              // Fix the function signature mismatch - NoticeCard expects a function that takes the anuncio as a parameter
              onTap: (noticeData) => NoticeDetail.show(context, noticeData),
            );
          }

          return SizedBox.shrink();
        },
      ),
    );
  }
}
