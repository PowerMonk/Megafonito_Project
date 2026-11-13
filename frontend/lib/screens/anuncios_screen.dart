import 'dart:async';

import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/notices_service.dart';
import '../services/realtime_service.dart';
import '../theme/app_theme.dart';
import '../widgets/actions_buttons.dart';
import '../widgets/navbar.dart';
import '../widgets/notice_card.dart';
import '../widgets/notice_detail.dart';
import '../widgets/notices_filter.dart';
import 'contact_screen.dart';
import 'crear_anuncio_screen.dart';
import 'login_screen.dart';
import 'opportunities_screen.dart';
import 'school_processes_screen.dart';
import 'support_screen.dart';
import 'user_info_screen.dart';

class AnunciosScreen extends StatefulWidget {
  final User user;
  final NoticesService? noticesService;
  final RealtimeService? realtimeService;

  const AnunciosScreen({
    super.key,
    required this.user,
    this.noticesService,
    this.realtimeService,
  });

  @override
  State<AnunciosScreen> createState() => _AnunciosScreenState();
}

class _AnunciosScreenState extends State<AnunciosScreen>
    with WidgetsBindingObserver {
  late final NoticesService _notices =
      widget.noticesService ?? NoticesService();
  late final RealtimeService _realtime =
      widget.realtimeService ?? RealtimeService();
  final AuthService _auth = AuthService();

  List<Map<String, dynamic>> _anuncios = [];
  String? _selectedCategory;
  String _sort = 'recent';
  int _currentIndex = 0;
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _loadGeneration = 0;

  StreamSubscription<RealtimeEvent>? _realtimeSubscription;

  static const List<String> _screenTitles = [
    'Megafonito',
    'Contactos Escolares',
    'Oportunidades',
    'Procesos Escolares',
    'Cuenta',
  ];

  List<Widget> get _screens => [
    const ContactosEscolaresScreen(),
    const OpportunitiesScreen(),
    const SchoolProcessesScreen(),
    UserInfoScreen(user: widget.user, onLogout: () => _logout()),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenRealtime();
    _loadNotices(refresh: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _realtimeSubscription?.cancel();
    _realtime.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _connectRealtime();
    _loadNotices(refresh: true);
  }

  void _listenRealtime() {
    _realtimeSubscription = _realtime.events.listen(_handleRealtimeEvent);
    _connectRealtime();
  }

  void _connectRealtime() {
    final token = ApiClient.token;
    if (token == null || token.isEmpty) return;
    _realtime.connect(token);
  }

  void _handleRealtimeEvent(RealtimeEvent event) {
    switch (event.type) {
      case 'connected':
      case 'announcement:new':
      case 'announcement:updated':
      case 'announcement:deleted':
      case 'demo:reset':
        _loadNotices(refresh: true);
        break;
      case 'reconnectFailed':
        _verifySession();
        break;
    }
  }

  Future<void> _verifySession() async {
    try {
      await ApiClient.get('/api/me');
    } on UnauthorizedException {
      await _logout(expired: true);
    } catch (_) {
      // A network failure will be retried by the realtime service.
    }
  }

  Future<void> _loadNotices({bool refresh = false}) async {
    if (!mounted) return;
    if (_isLoading && !refresh) return;

    final generation = ++_loadGeneration;
    final requestedPage = refresh ? 1 : _currentPage;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _currentPage = 1;
        _hasMoreData = true;
        _anuncios = [];
      }
    });

    try {
      final result = await _notices.loadNotices(
        page: requestedPage,
        limit: 5,
        category: _selectedCategory,
        sort: _sort,
      );

      if (!mounted || generation != _loadGeneration) return;

      final rawNotices = result['data'];
      final notices = rawNotices is List ? rawNotices : const <dynamic>[];
      final pagination = result['pagination'];
      final paginationMap = pagination is Map
          ? Map<String, dynamic>.from(pagination)
          : const <String, dynamic>{};

      final mapped = notices
          .whereType<Map>()
          .map((notice) => _mapNotice(Map<String, dynamic>.from(notice)))
          .toList();

      final currentPage =
          (paginationMap['currentPage'] as num?)?.toInt() ?? requestedPage;
      final totalPages =
          (paginationMap['totalPages'] as num?)?.toInt() ?? currentPage;

      setState(() {
        if (refresh) {
          _anuncios = mapped;
        } else {
          _anuncios.addAll(mapped);
        }
        _currentPage = currentPage + 1;
        _hasMoreData = currentPage < totalPages;
        _isLoading = false;
      });
    } on UnauthorizedException {
      await _logout(expired: true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar los anuncios: $error')),
      );
    }
  }

  Map<String, dynamic> _mapNotice(Map<String, dynamic> notice) {
    final hasAttachment =
        notice['has_attachment'] == true || notice['has_attachment'] == 1;

    return {
      'id': notice['id'],
      'title': notice['title'] ?? 'Sin título',
      'content': notice['content'] ?? '',
      'category': notice['category'] ?? 'General',
      'author_name': notice['author_name'] ?? 'Autor desconocido',
      'created_at':
          DateTime.tryParse(notice['created_at']?.toString() ?? '') ??
          DateTime.now(),
      'has_attachment': hasAttachment,
      'attachment_url': notice['attachment_url'],
      'attachment_key': notice['attachment_key'],
      'audience_label': notice['audience_label'],
      'target_groups': notice['target_groups'] ?? const <String>[],
    };
  }

  void _filterAnuncios() {
    _loadNotices(refresh: true);
  }

  void _navigateToSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SoporteMegafonitoScreen()),
    );
  }

  void _navigateToCrearNuevoAnuncio() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearNuevoAnuncioScreen(
          author: widget.user,
          noticesService: _notices,
          onPublish: (draft) async {
            await _notices.createNotice(draft);
            unawaited(_loadNotices(refresh: true));
          },
        ),
      ),
    );
  }

  void _handleNavBarTap(int index) {
    setState(() => _currentIndex = index);
  }

  Future<void> _logout({bool expired = false}) async {
    await _realtime.disconnect();
    await _auth.logout();
    if (!mounted) return;

    if (expired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu sesión expiró. Inicia sesión de nuevo.'),
        ),
      );
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

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
                              isSuperUser: widget.user.isAdmin,
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
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 0) {
      return Column(
        children: [
          NoticesFilter(
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category.isEmpty ? null : category;
              });
              _filterAnuncios();
            },
            onSortOptionSelected: (sort) {
              setState(() {
                _sort = sort == 'Más antiguos' ? 'oldest' : 'recent';
              });
              _filterAnuncios();
            },
          ),
          Expanded(child: _buildNoticesContent()),
        ],
      );
    }

    final stackIndex = _currentIndex - 1;
    if (stackIndex >= 0 && stackIndex < _screens.length) {
      return IndexedStack(index: stackIndex, children: _screens);
    }
    return const Center(child: Text('Pantalla no encontrada'));
  }

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
                'No hay anuncios para tu grupo todavía',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Cuando la administración publique uno, aparecerá aquí automáticamente.',
                style: Theme.of(context).textTheme.bodySmall,
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
          if (index == _anuncios.length && _hasMoreData) {
            Future.microtask(() => _loadNotices());
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (index < _anuncios.length) {
            final anuncio = _anuncios[index];
            return NoticeCard(
              anuncio: anuncio,
              onTap: (noticeData) => NoticeDetail.show(context, noticeData),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
