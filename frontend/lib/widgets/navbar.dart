import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

class AppNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: 78 + bottomInset,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Material(
                color: colorScheme.surface,
                elevation: 2,
                shadowColor: AppDesign.navy.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDesign.pillRadius),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: double.infinity,
                  child: NavigationBar(
                    selectedIndex: currentIndex,
                    onDestinationSelected: onTap,
                    destinations: _navigationItems.map((item) {
                      return NavigationDestination(
                        icon: _icon(item.asset, colorScheme.onSurfaceVariant),
                        selectedIcon: _icon(item.asset, AppDesign.navy),
                        label: item.label,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppNavigationRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppNavigationRail({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      child: Material(
        color: colorScheme.surface,
        elevation: 1,
        shadowColor: AppDesign.navy.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: NavigationRail(
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          labelType: NavigationRailLabelType.all,
          groupAlignment: 0,
          destinations: _navigationItems.map((item) {
            return NavigationRailDestination(
              icon: _icon(item.asset, colorScheme.onSurfaceVariant),
              selectedIcon: _icon(item.asset, AppDesign.navy),
              label: Text(item.label),
            );
          }).toList(),
        ),
      ),
    );
  }
}

Widget _icon(String asset, Color color) {
  return SvgPicture.asset(
    asset,
    height: 24,
    width: 24,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    excludeFromSemantics: true,
  );
}

class _NavigationItem {
  final String label;
  final String asset;

  const _NavigationItem(this.label, this.asset);
}

const List<_NavigationItem> _navigationItems = [
  _NavigationItem('Inicio', 'assets/icons/inicio_icon.svg'),
  _NavigationItem('Contactos', 'assets/icons/contactov2_icon.svg'),
  _NavigationItem('Oportunidades', 'assets/icons/oportunidades_icon.svg'),
  _NavigationItem('Procesos', 'assets/icons/procesos_icon.svg'),
  _NavigationItem('Cuenta', 'assets/icons/cuenta_icon.svg'),
];
