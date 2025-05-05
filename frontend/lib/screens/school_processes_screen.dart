import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_view/photo_view.dart';

class SchoolProcessesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Light gray background color matching other screens
      color: Color.fromARGB(255, 250, 250, 250),
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Calendar Title with Underline Effect (Centered) ---
            Center(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.0, top: 16.0),
                    child: Text(
                      'Calendario escolar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Divider acting as an underline (centered under text)
                  Container(
                    width: 240.0, // Width to match the text approximately
                    child: Divider(
                      color: Colors.black,
                      thickness: 2.0,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0), // Spacing after title

            // --- Calendar Icon Box (clickable) ---
            InkWell(
              onTap: () {
                // TODO: Implement navigation to calendar screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Navegación al calendario no implementada')),
                );
              },
              borderRadius: BorderRadius.circular(8.0),
              child: Card(
                color: Colors.white,
                elevation: 2.5,
                margin: EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: double.infinity, // Takes full width
                  height: 120, // Fixed height
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/calendario-escolar_icon.svg',
                      height: 60,
                      width: 60,
                    ),
                  ),
                ),
              ),
            ),

            // --- FAQ Section ---
            Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 8.0, top: 24.0),
              child: Text(
                'Preguntas frecuentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // FAQ Questions (clickable text items)
            _buildFaqQuestion(
              context: context,
              question: '¿Cómo puedo solicitar una revisión de calificación?',
              onTap: () {
                // TODO: Implement navigation or action for this FAQ
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pregunta 1 clickeada')),
                );
              },
            ),
            SizedBox(height: 12),

            _buildFaqQuestion(
              context: context,
              question: '¿Cuál es el proceso para dar de baja una materia?',
              onTap: () {
                // TODO: Implement navigation or action for this FAQ
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pregunta 2 clickeada')),
                );
              },
            ),
            SizedBox(height: 12),

            _buildFaqQuestion(
              context: context,
              question: '¿Cómo puedo solicitar una constancia de estudios?',
              onTap: () {
                // TODO: Implement navigation or action for this FAQ
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pregunta 3 clickeada')),
                );
              },
            ),
            SizedBox(height: 24),

            // --- Enrollment Process Button ---
            _buildProcessButton(
              context: context,
              title: 'Proceso de inscripción',
              subtitle: 'Ver requisitos y pasos a seguir',
              onTap: () {
                // TODO: Implement navigation or action for enrollment process
                print('Enrollment process button clicked');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build FAQ question items as clickable text
  Widget _buildFaqQuestion({
    required BuildContext context,
    required String question,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bullet point
            Padding(
              padding: EdgeInsets.only(top: 10.0, right: 8.0),
              child: Icon(Icons.circle,
                  size: 8, color: const Color.fromARGB(255, 36, 35, 35)),
            ),
            // Question text
            Expanded(
              child: Text(
                question,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.deepPurple[600],
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.deepPurple[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build process button (like in support screen)
  Widget _buildProcessButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      elevation: 3.0,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              // Column for title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
