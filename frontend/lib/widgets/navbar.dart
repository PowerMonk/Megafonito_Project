import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
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
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
            'assets/icons/contactov2_icon.svg',
            height: 24.0,
            width: 24.0,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          activeIcon: SvgPicture.asset(
            'assets/icons/contactov2_icon.svg',
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
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
            'assets/icons/cuenta_icon.svg',
            height: 24.0,
            width: 24.0,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          activeIcon: SvgPicture.asset(
            'assets/icons/cuenta_icon.svg',
            height: 24.0,
            width: 24.0,
            colorFilter:
                const ColorFilter.mode(Color(0xFFFCA311), BlendMode.srcIn),
          ),
          label: 'Cuenta',
        ),
      ],
      onTap: onTap,
    );
  }
}
