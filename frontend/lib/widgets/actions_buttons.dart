import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../screens/createopps_screen.dart';
import '../screens/newmsg_screen.dart';
import '../theme/app_theme.dart';

class ActionButtons extends StatefulWidget {
  final bool isSuperUser;
  final VoidCallback onCreateNotice;

  const ActionButtons({
    super.key,
    required this.isSuperUser,
    required this.onCreateNotice,
  });

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  bool _showExtraFabs = false;

  void _toggleExtraActions() {
    setState(() => _showExtraFabs = !_showExtraFabs);
  }

  void _dismissExtraActions() {
    if (_showExtraFabs) setState(() => _showExtraFabs = false);
  }

  void _createNotice() {
    if (!_showExtraFabs) {
      widget.onCreateNotice();
      return;
    }

    _dismissExtraActions();
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (mounted) widget.onCreateNotice();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isSuperUser) return const SizedBox.shrink();

    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            opacity: _showExtraFabs ? 1 : 0,
            child: IgnorePointer(
              ignoring: !_showExtraFabs,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _dismissExtraActions,
                child: const ColoredBox(color: Color(0x990B1426)),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 18,
          right: 18,
          child: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final slide = Tween<Offset>(
                  begin: const Offset(0, 0.12),
                  end: Offset.zero,
                ).animate(animation);

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: slide, child: child),
                );
              },
              layoutBuilder: (currentChild, previousChildren) => Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              ),
              child: RepaintBoundary(
                key: ValueKey(_showExtraFabs),
                child: _showExtraFabs
                    ? _buildExtraActions(context)
                    : _buildSegmentedFab(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExtraActions(BuildContext context) {
    return Column(
      key: const ValueKey('expanded-create-actions'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildExtraAction(
          context,
          label: 'Oportunidad nueva',
          tooltip: 'Crear nueva oportunidad',
          heroTag: 'megafonito-create-opportunity',
          icon: Icons.school_outlined,
          onPressed: () {
            _dismissExtraActions();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CrearNuevaOportunidadScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildExtraAction(
          context,
          label: 'Nuevo mensaje',
          tooltip: 'Crear nuevo mensaje',
          heroTag: 'megafonito-create-message',
          icon: Icons.mail_outline_rounded,
          onPressed: () {
            _dismissExtraActions();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NuevoMensajeScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildExtraAction(
          context,
          label: 'Anuncio nuevo',
          tooltip: 'Crear nuevo anuncio',
          heroTag: 'megafonito-create-notice-expanded',
          icon: Icons.campaign_outlined,
          emphasized: true,
          onPressed: _createNotice,
        ),
      ],
    );
  }

  Widget _buildExtraAction(
    BuildContext context, {
    required String label,
    required String tooltip,
    required String heroTag,
    required IconData icon,
    required VoidCallback onPressed,
    bool emphasized = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    const foreground = AppDesign.navy;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 220),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton(
          onPressed: onPressed,
          heroTag: heroTag,
          tooltip: tooltip,
          backgroundColor: emphasized ? AppDesign.amber : colorScheme.surface,
          foregroundColor: foreground,
          child: Icon(icon, size: 25, color: foreground),
        ),
      ],
    );
  }

  Widget _buildSegmentedFab(BuildContext context) {
    return Material(
      color: AppDesign.amber,
      elevation: 5,
      shadowColor: const Color(0x3814213D),
      borderRadius: BorderRadius.circular(28),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            label: 'Crear un anuncio nuevo',
            child: InkWell(
              onTap: _createNotice,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/nuevoanuncio_icon.svg',
                      height: 20,
                      width: 20,
                      colorFilter: const ColorFilter.mode(
                        AppDesign.navy,
                        BlendMode.srcIn,
                      ),
                      excludeFromSemantics: true,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Anuncio nuevo',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppDesign.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(width: 1, height: 30, color: const Color(0x7314213D)),
          Semantics(
            button: true,
            label: 'Más acciones de creación',
            child: InkWell(
              onTap: _toggleExtraActions,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                child: SvgPicture.asset(
                  'assets/icons/opciones_icon.svg',
                  height: 20,
                  width: 20,
                  colorFilter: const ColorFilter.mode(
                    AppDesign.navy,
                    BlendMode.srcIn,
                  ),
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
