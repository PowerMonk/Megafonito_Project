import 'package:flutter/material.dart';

import '../services/notices_service.dart';
import '../theme/app_theme.dart';
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

  const AnunciosScreen({
    super.key,
    this.isSuperUser = false,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<AnunciosScreen> createState() => _AnunciosScreenState();
}

class _AnunciosScreenState extends State<AnunciosScreen> {
  List<Map<String, dynamic>> _anuncios = [];
  String? _selectedCategory;
  int _currentIndex = 0;

  // Pagination variables
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;

  static const List<String> _screenTitles = [
    'Megafonito',
    'Contactos Escolares',
    'Oportunidades',
    'Procesos Escolares',
    'Cuenta',
  ];

  static const List<Widget> _screens = [
    ContactosEscolaresScreen(),
    OpportunitiesScreen(),
    SchoolProcessesScreen(),
    UserInfoScreen(),
  ];

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

      if (!mounted) return;
      setState(() {
        _anuncios.addAll(
          notices.map((notice) {
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
          }).toList(),
        );

        final int currentPage = pagination['currentPage'] as int? ?? 1;
        final int totalPages = pagination['totalPages'] as int? ?? 1;
        _hasMoreData = currentPage < totalPages;

        if (_hasMoreData) {
          _currentPage++;
        }

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading notices: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar anuncios: ${e.toString()}')),
      );
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearNuevoAnuncioScreen(
          onAnuncioCreado:
              (
                titulo,
                texto,
                color,
                categoria,
                tieneArchivos,
                fileUrl,
                fileKey,
              ) async {
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
                } catch (e) {
                  debugPrint('Error creating announcement: $e');
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error al crear el anuncio: ${e.toString()}',
                      ),
                    ),
                  );
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

  // --- UI Building ---
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitles[_currentIndex]),
        actions: [
          IconButton(
            onPressed: _navigateToSupport,
            tooltip: 'Soporte',
            icon: const Icon(Icons.support_agent_outlined),
          ),
        ],
      ),
      body: Row(
        children: [
          if (isWide)
            AppNavigationRail(
              currentIndex: _currentIndex,
              onTap: _handleNavBarTap,
            ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: SizedBox(
                      width: double.infinity,
                      height: constraints.maxHeight,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildBody(),
                          if (_currentIndex == 0)
                            ActionButtons(
                              isSuperUser: widget.isSuperUser,
                              onCreateNotice: _navigateToCrearNuevoAnuncio,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : AppNavBar(currentIndex: _currentIndex, onTap: _handleNavBarTap),
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
            onSortOptionSelected: (_) {
              _filterAnuncios();
            },
          ),

          // NoticesContent fills the remaining space
          Expanded(child: _buildNoticesContent()),
        ],
      );
    } else {
      int stackIndex = _currentIndex - 1;
      if (stackIndex >= 0 && stackIndex < _screens.length) {
        return IndexedStack(index: stackIndex, children: _screens);
      } else {
        return const Center(child: Text('Pantalla no encontrada'));
      }
    }
  }

  // Helper method for building the notices content
  Widget _buildNoticesContent() {
    if (_isLoading && _anuncios.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_anuncios.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDesign.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.campaign_outlined,
                size: 44,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'No hay anuncios disponibles',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadNotices(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 104),
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
