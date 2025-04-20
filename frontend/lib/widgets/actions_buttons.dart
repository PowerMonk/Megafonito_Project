import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui'; // For ImageFilter

class ActionButtons extends StatelessWidget {
  final bool isSuperUser;
  final bool showExtraFabs;
  final VoidCallback onShowExtraFabs;
  final VoidCallback onCreateNotice;
  final VoidCallback onCreateMessage;
  final VoidCallback onCreateOpportunity;
  final VoidCallback onDismissBlur;

  const ActionButtons({
    Key? key,
    required this.isSuperUser,
    required this.showExtraFabs,
    required this.onShowExtraFabs,
    required this.onCreateNotice,
    required this.onCreateMessage,
    required this.onCreateOpportunity,
    required this.onDismissBlur,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Only build if superuser (first tab check is handled by parent)
    if (!isSuperUser) {
      return SizedBox.shrink();
    }

    return Stack(
      children: [
        // Blur and extra buttons layer (conditional)
        if (showExtraFabs)
          // Dismiss layer on tap
          GestureDetector(
            onTap: onDismissBlur,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.black.withOpacity(0.6), // Semi-transparent black
              ),
            ),
          ),

        // The two new FABs (conditional)
        if (showExtraFabs)
          Positioned(
            bottom: 22.0,
            right: 18.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Third option: Oportunidad nueva
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Text Label
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Text(
                        'Oportunidad nueva',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // Circular Button
                    FloatingActionButton(
                      onPressed: onCreateOpportunity,
                      backgroundColor: Colors.white,
                      heroTag: 'extraFab2',
                      tooltip: 'Crear Nueva Oportunidad',
                      elevation: 4.0,
                      mini: false,
                      shape: CircleBorder(),
                      child: SvgPicture.asset(
                        'assets/icons/newopp_icon.svg',
                        height: 35.0,
                        width: 35.0,
                        colorFilter: ColorFilter.mode(
                            Color(0xFFFCA311), BlendMode.srcIn),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                // Second Option: Nuevo Mensaje
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Text Label
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Text(
                        'Nuevo mensaje',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // Circular Button
                    FloatingActionButton(
                      onPressed: onCreateMessage,
                      backgroundColor: Colors.white,
                      heroTag: 'extraFab2',
                      tooltip: 'Crear Nuevo Mensaje',
                      elevation: 4.0,
                      mini: false,
                      shape: CircleBorder(),
                      child: SvgPicture.asset(
                        'assets/icons/nuevomensaje_icon.svg',
                        height: 24.0,
                        width: 24.0,
                        colorFilter: ColorFilter.mode(
                            Color(0xFFFCA311), BlendMode.srcIn),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),

                // First Option: Anuncio Nuevo
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Text Label
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Text(
                        'Anuncio nuevo',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // Circular Button
                    Transform.scale(
                      scale: 1.15,
                      child: FloatingActionButton(
                        onPressed: onCreateNotice,
                        backgroundColor: Color(0xFFFCA311),
                        heroTag: 'extraFab1',
                        tooltip: 'Crear Nuevo Anuncio',
                        elevation: 4.0,
                        mini: false,
                        shape: CircleBorder(),
                        child: SvgPicture.asset(
                          'assets/icons/nuevoanuncio_icon.svg',
                          height: 26.0,
                          width: 26.0,
                          colorFilter:
                              ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Segmented FAB (only if extra FABs are not shown)
        if (!showExtraFabs)
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: _buildSegmentedFab(context),
          ),
      ],
    );
  }

  Widget _buildSegmentedFab(BuildContext context) {
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
            onTap: onCreateNotice,
            borderRadius: BorderRadius.horizontal(left: Radius.circular(25)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/nuevoanuncio_icon.svg',
                    height: 20,
                    width: 20,
                    colorFilter: ColorFilter.mode(
                        Colors.white, BlendMode.srcIn), // White icon
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
            color: Colors.white, // White separator
          ),
          // Right Segment: Show Extra Options
          InkWell(
            onTap: onShowExtraFabs,
            borderRadius: BorderRadius.horizontal(right: Radius.circular(25)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: SvgPicture.asset(
                'assets/icons/opciones_icon.svg',
                height: 20,
                width: 20,
                colorFilter: ColorFilter.mode(
                    Colors.white, BlendMode.srcIn), // White icon
              ),
            ),
          ),
        ],
      ),
    );
  }
}
