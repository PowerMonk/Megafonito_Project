import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui'; // Import for ImageFilter
import '../services/notices_service.dart';
import '../widgets/notice_card.dart';
import '../widgets/notice_detail.dart';
import '../widgets/notices_filter.dart'; // Add this import
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
    'Soporte Megafonito',
  ];

  final List<Widget> _screens = [
    ContactosEscolaresScreen(),
    BeneficiosScreen(),
    ProcesosEscolaresScreen(),
    SoporteMegafonitoScreen(),
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
  void _navigateToUserInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserInfoScreen(
          name: widget.userName,
          email: widget.userEmail,
        ),
      ),
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

  // --- UI Building ---
  // header
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Text(_screenTitles[_currentIndex],
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
              onPressed: _navigateToUserInfo,
              icon: Icon(Icons.account_circle_outlined)),
        ],
      ),
      // Wrap body in a Stack to allow layering
      body: Stack(
        children: [
          // Main content
          _buildBody(),

          // Blur and extra buttons layer (conditional)
          if (_showExtraFabs)
            // Dismiss layer on tap
            GestureDetector(
              onTap: () => setState(() => _showExtraFabs = false),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                child: Container(
                  color:
                      Colors.black.withOpacity(0.25), // Semi-transparent black
                ),
              ),
            ),

          // The two new FABs (conditional) - Now as circular buttons with text labels outside
          if (_showExtraFabs)
            Positioned(
              bottom: 22.0, // Adjust position as needed
              right: 18.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.end, // Align items to the right
                children: [
                  // Second Option: Nuevo Mensaje
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Text Label
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 12.0), // Space between text and button
                        child: Text(
                          'Nuevo mensaje',
                          style: TextStyle(
                            color: Colors.black, // Adjust text color if needed
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      // Circular Button
                      FloatingActionButton(
                        onPressed: () {
                          // TODO: Implement action for "Nuevo Mensaje"
                          print("Nuevo Mensaje tapped");
                          setState(() => _showExtraFabs = false);
                        },
                        backgroundColor: Colors.white, // White background
                        heroTag: 'extraFab2',
                        tooltip: 'Crear Nuevo Mensaje',
                        elevation: 4.0,
                        mini: false,
                        shape: CircleBorder(),
                        child: SvgPicture.asset(
                          'assets/icons/nuevomensaje_icon.svg',
                          height: 24.0, // Adjust icon size
                          width: 24.0,
                          colorFilter: ColorFilter.mode(Color(0xFFFCA311),
                              BlendMode.srcIn), // Orange icon
                        ), // Ensure standard size unless specifically needed smaller
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0), // Spacing between options

                  // --- First Option: Anuncio Nuevo ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Text Label
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 12.0), // Space between text and button
                        child: Text(
                          'Anuncio nuevo',
                          style: TextStyle(
                            color: Colors.black, // Adjust text color if needed
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      // Circular Button
                      Transform.scale(
                        scale: 1.15, // Adjust scale to make the button larger
                        child: FloatingActionButton(
                          onPressed: _navigateToCrearNuevoAnuncio,
                          backgroundColor:
                              Color(0xFFFCA311), // Orange background
                          heroTag: 'extraFab1',
                          tooltip: 'Crear Nuevo Anuncio',
                          elevation: 4.0,
                          mini: false,
                          shape: CircleBorder(),
                          child: SvgPicture.asset(
                            'assets/icons/nuevoanuncio_icon.svg',
                            height: 26.0, // Adjust icon size
                            width: 26.0,
                            colorFilter: ColorFilter.mode(
                                Colors.white, BlendMode.srcIn), // White icon
                          ), // Ensure standard size
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
      // Use the new builder for the floating action button area
      floatingActionButton: _buildSegmentedFab(),
      // Prevent the main FAB from overlapping the BottomNavBar
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // navbar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Color(0xFFFCA311),
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        iconSize: 24.0,
        selectedLabelStyle: TextStyle(fontSize: 12.0, letterSpacing: -0.2),
        unselectedLabelStyle: TextStyle(fontSize: 12.0, letterSpacing: -0.2),
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/inicio_icon.svg',
              height: 24.0,
              width: 24.0,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/inicio_icon.svg',
              height: 24.0,
              width: 24.0,
              colorFilter:
                  const ColorFilter.mode(Color(0xFFFCA311), BlendMode.srcIn),
            ),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/contactos_icon.svg',
              height: 24.0,
              width: 24.0,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/contactos_icon.svg',
              height: 24.0,
              width: 24.0,
              colorFilter:
                  const ColorFilter.mode(Color(0xFFFCA311), BlendMode.srcIn),
            ),
            label: 'Contactos',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/oportunidades_icon.svg',
              height: 24.0,
              width: 24.0,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/oportunidades_icon.svg',
              height: 24.0,
              width: 24.0,
              colorFilter:
                  const ColorFilter.mode(Color(0xFFFCA311), BlendMode.srcIn),
            ),
            label: 'Oportunidades',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/procesos_icon.svg',
              height: 24.0,
              width: 24.0,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/procesos_icon.svg',
              height: 24.0,
              width: 24.0,
              colorFilter:
                  const ColorFilter.mode(Color(0xFFFCA311), BlendMode.srcIn),
            ),
            label: 'Procesos',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/soporte_icon.svg',
              height: 24.0,
              width: 24.0,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            activeIcon: SvgPicture.asset(
              'assets/icons/soporte_icon.svg',
              height: 24.0,
              width: 24.0,
              colorFilter:
                  const ColorFilter.mode(Color(0xFFFCA311), BlendMode.srcIn),
            ),
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

  // Builder method for the segmented FAB
  Widget? _buildSegmentedFab() {
    // Only show if on the first tab, user is superuser, AND extra FABs are NOT shown
    if (_currentIndex == 0 && widget.isSuperUser && !_showExtraFabs) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xFFFCA311),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Left Segment: Create Notice
            InkWell(
              onTap: _navigateToCrearNuevoAnuncio,
              borderRadius: BorderRadius.horizontal(left: Radius.circular(25)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      // Use SVG icon
                      'assets/icons/nuevoanuncio_icon.svg',
                      height: 20,
                      width: 20,
                      colorFilter: ColorFilter.mode(
                          Colors.white, BlendMode.srcIn), // Black icon
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Anuncio nuevo',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            // Separator
            Container(
              width: 1,
              height: 30,
              color: Colors.white,
            ),
            // Right Segment: Show Extra Options
            InkWell(
              onTap: () {
                setState(() {
                  // Toggle the visibility of extra FABs
                  _showExtraFabs = true; // Always set to true to show options
                });
              },
              borderRadius: BorderRadius.horizontal(right: Radius.circular(25)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: SvgPicture.asset(
                  // Use SVG icon
                  'assets/icons/opciones_icon.svg',
                  height: 20,
                  width: 20,
                  colorFilter: ColorFilter.mode(
                      Colors.white, BlendMode.srcIn), // Black icon
                ),
              ),
            ),
          ],
        ),
      );
    }
    // Return null if the conditions are not met
    return null;
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
            child: NoticesContent(
              anuncios: _anuncios,
              hasMoreData: _hasMoreData,
              isLoading: _isLoading,
              onNoticeTap: (anuncio) => NoticeDetail.show(context, anuncio),
              onRefresh: () => _loadNotices(refresh: true),
              onLoadMore: _loadNotices,
            ),
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
}
