import 'package:flutter/material.dart';

class SoporteMegafonitoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- AppBar ---
      appBar: AppBar(
        title: Text(
          'Soporte',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold), // Título en blanco y negrita
        ),
        backgroundColor: Colors.black, // Color de fondo del AppBar
        elevation: 0, // Sin sombra debajo del AppBar
        // Ignoramos el icono de bug que aparecía en la imagen de diseño.
      ),
      // --- Body ---
      // Usamos un Container con color de fondo blanco.
      body: Container(
        color: Color.fromARGB(255, 250, 250, 250),
        // Para que el contenido ocupe todo el espacio vertical disponible,
        // el widget hijo directo del Scaffold (o del Container si es el hijo del Scaffold)
        // debe ser un widget que pueda expandirse, como Column o ListView
        // dentro de un Expanded.

        // En este caso, SingleChildScrollView ya permite que el contenido
        // se expanda verticalmente según su necesidad, pero para asegurar
        // que el fondo blanco cubra toda la pantalla incluso cuando el
        // contenido no es suficiente, podemos usar un Column como hijo
        // del Container y luego el SingleChildScrollView dentro de un Expanded.
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                // Padding general para todo el contenido.
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  // Organiza los elementos verticalmente.
                  crossAxisAlignment: CrossAxisAlignment
                      .start, // Alinea los textos a la izquierda.
                  children: [
                    // --- Opción 1: Reportar Bug ---
                    _buildSupportOptionTile(
                      context: context,
                      title: 'Reporta un bug',
                      subtitle: 'Dínos si algo no funciona como esperaba',
                      onTap: () {
                        // TODO: Implementar navegación o acción para reportar bug.
                        print('Reportar Bug presionado');
                      },
                    ),
                    SizedBox(height: 12), // Espacio entre las opciones.

                    // --- Opción 2: Haz una sugerencia ---
                    _buildSupportOptionTile(
                      context: context,
                      title: 'Haz una sugerencia',
                      subtitle:
                          '¿Cómo podemos hacer que Megafonito sea aún mejor?',
                      onTap: () {
                        // TODO: Implementar navegación o acción para hacer sugerencia.
                        print('Haz una sugerencia presionado');
                      },
                    ),
                    SizedBox(
                        height:
                            30), // Espacio mayor antes del texto informativo.

                    // --- Texto Informativo ---
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0), // Padding horizontal ligero
                      child: Text(
                        'Cada reporte de error y cada sugerencia que recibimos nos ayuda a construir una mejor app para ti y toda la comunidad estudiantil. ¡Gracias por ser parte del cambio!',
                        textAlign: TextAlign
                            .start, // Texto alineado a la izquierda como en la imagen.
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700], // Color gris oscuro.
                          height:
                              1.4, // Altura de línea para mejor legibilidad.
                        ),
                      ),
                    ),
                    SizedBox(height: 30), // Espacio mayor antes del subtítulo.

                    // --- Subtítulo: Escribir directamente ---
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, bottom: 12.0), // Padding izquierdo y abajo
                      child: Text(
                        '¿Prefieres escribirnos directamente?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold, // Texto en negrita.
                          color: Colors.black,
                        ),
                      ),
                    ),

                    // --- Opción 3: Conecta con el equipo ---
                    _buildSupportOptionTile(
                      context: context,
                      title: 'Conecta con el equipo',
                      subtitle:
                          'Aquí puedes ver todas nuestras formas de contacto',
                      onTap: () {
                        // TODO: Implementar navegación o acción para ver formas de contacto.
                        print('Conecta con el equipo presionado');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Método auxiliar para construir cada opción clickeable del menú de soporte.
  ///
  /// [context]: El BuildContext.
  /// [title]: El texto principal de la opción.
  /// [subtitle]: El texto secundario descriptivo.
  /// [onTap]: La función a ejecutar cuando se presiona el tile.
  Widget _buildSupportOptionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      // Material proporciona la elevación y el color de fondo base
      color: Colors.white, // Fondo gris muy claro como en la imagen
      elevation: 3.0,
      borderRadius: BorderRadius.circular(12.0), // Bordes redondeados
      child: InkWell(
        // InkWell maneja el efecto visual al tocar (ripple) y la acción onTap.
        onTap: onTap, // Ejecuta la acción proporcionada.
        borderRadius: BorderRadius.circular(
            12.0), // Asegura que el ripple respete los bordes.
        child: Container(
          // Container sólo para padding interno, el color y forma lo da Material.
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            // Organiza el contenido (textos y flecha) en una fila.
            children: [
              // Columna para los textos (título y subtítulo).
              Expanded(
                // Expanded asegura que la columna ocupe el espacio disponible.
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Alinea textos a la izquierda.
                  children: [
                    // Título de la opción.
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold, // Título en negrita.
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                        height: 4), // Pequeño espacio entre título y subtítulo.
                    // Subtítulo de la opción.
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600], // Subtítulo en gris.
                      ),
                    ),
                  ],
                ),
              ),
              // Icono de flecha a la derecha (chevron).
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400], // Flecha en color gris claro.
              ),
            ],
          ),
        ),
      ),
    );
  }
}
