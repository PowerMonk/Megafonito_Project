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
                  height: 70,
                  child: Row(
                    children: [
                      for (var i = 0; i < _navigationItems.length; i++)
                        Expanded(
                          child: _NavDestinationItem(
                            item: _navigationItems[i],
                            selected: currentIndex == i,
                            onTap: () => onTap(i),
                          ),
                        ),
                    ],
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
              icon: _icon(item.asset, colorScheme.onSurfaceVariant, size: 24),
              selectedIcon: _icon(item.asset, AppDesign.navy, size: 24),
              label: Text(item.label),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavDestinationItem extends StatelessWidget {
  final _NavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavDestinationItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = selected ? AppDesign.navy : colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Tooltip(
        message: item.label,
        child: InkResponse(
          onTap: onTap,
          containedInkWell: true,
          highlightShape: BoxShape.rectangle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  width: 44,
                  height: 28,
                  decoration: BoxDecoration(
                    color: selected
                        ? colorScheme.secondaryContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: TweenAnimationBuilder<Color?>(
                      tween: ColorTween(end: color),
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOut,
                      builder: (context, animatedColor, _) {
                        return _icon(
                          item.asset,
                          animatedColor ?? color,
                          size: 21,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  height: 13,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item.label,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: item.label == 'Oportunidades' ? 9.5 : 10.5,
                        height: 1.1,
                        letterSpacing: -0.2,
                        color: color,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _icon(String asset, Color color, {double size = 21}) {
  return SvgPicture.asset(
    asset,
    height: size,
    width: size,
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
