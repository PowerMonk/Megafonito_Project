import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../screens/createopps_screen.dart';
import '../screens/newmsg_screen.dart';
import '../theme/app_theme.dart';

class ActionButtons extends StatelessWidget {
  final bool isSuperUser;
  final bool showExtraFabs;
  final VoidCallback onShowExtraFabs;
  final VoidCallback onCreateNotice;
  final VoidCallback onDismissBlur;

  const ActionButtons({
    super.key,
    required this.isSuperUser,
    required this.showExtraFabs,
    required this.onShowExtraFabs,
    required this.onCreateNotice,
    required this.onDismissBlur,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSuperUser) return const SizedBox.shrink();

    return Stack(
      children: [
        if (showExtraFabs)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDismissBlur,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(color: const Color(0x990B1426)),
              ),
            ),
          ),
        if (showExtraFabs)
          Positioned(
            bottom: 24,
            right: 20,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildExtraAction(
                    context,
                    label: 'Oportunidad nueva',
                    tooltip: 'Crear nueva oportunidad',
                    heroTag: 'megafonito-create-opportunity',
                    asset: 'assets/icons/newopp_icon.svg',
                    onPressed: () {
                      onDismissBlur();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CrearNuevaOportunidadScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildExtraAction(
                    context,
                    label: 'Nuevo mensaje',
                    tooltip: 'Crear nuevo mensaje',
                    heroTag: 'megafonito-create-message',
                    asset: 'assets/icons/nuevomensaje_icon.svg',
                    onPressed: () {
                      onDismissBlur();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NuevoMensajeScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildExtraAction(
                    context,
                    label: 'Anuncio nuevo',
                    tooltip: 'Crear nuevo anuncio',
                    heroTag: 'megafonito-create-notice-expanded',
                    asset: 'assets/icons/nuevoanuncio_icon.svg',
                    emphasized: true,
                    onPressed: onCreateNotice,
                  ),
                ],
              ),
            ),
          ),
        if (!showExtraFabs)
          Positioned(
            bottom: 18,
            right: 18,
            child: SafeArea(child: _buildSegmentedFab(context)),
          ),
      ],
    );
  }

  Widget _buildExtraAction(
    BuildContext context, {
    required String label,
    required String tooltip,
    required String heroTag,
    required String asset,
    required VoidCallback onPressed,
    bool emphasized = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = colorScheme.primary;

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
          child: SvgPicture.asset(
            asset,
            height: 25,
            width: 25,
            colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
            excludeFromSemantics: true,
          ),
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
              onTap: onCreateNotice,
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(28)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          Container(
            width: 1,
            height: 30,
            color: const Color(0x7314213D),
          ),
          Semantics(
            button: true,
            label: 'Más acciones de creación',
            child: InkWell(
              onTap: onShowExtraFabs,
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(28)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
