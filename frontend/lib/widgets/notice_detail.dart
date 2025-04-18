import 'package:flutter/material.dart';

/// Normalmente se muestra dentro de un Modal Bottom Sheet. Incluye el título,
/// autor, contenido completo y una vista previa del adjunto si existe.
/// Proporciona un método estático [show] para facilitar su visualización
class NoticeDetail extends StatelessWidget {
  // El mapa que contiene los datos del anuncio.
  final Map<String, dynamic> anuncio;

  const NoticeDetail({
    Key? key,
    required this.anuncio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildContent(context, ScrollController());
  }

  /// Método estático para mostrar este widget dentro de un DraggableScrollableSheet
  /// presentado como un Modal Bottom Sheet.
  ///
  /// Simplifica el proceso de mostrar los detalles desde cualquier parte de la app.
  ///
  /// [context]: El BuildContext actual.
  /// [anuncio]: El mapa de datos del anuncio a mostrar.
  static void show(BuildContext context, Map<String, dynamic> anuncio) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Permite que el sheet ocupe más altura si es necesario.
      backgroundColor: Colors
          .transparent, // Fondo transparente para que se vea el redondeo del Container interior.
      shape: RoundedRectangleBorder(
        // Define la forma (redondeo) del BottomSheet en sí.
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.0)),
      ),
      builder: (_) => DraggableScrollableSheet(
          // Controla el tamaño y comportamiento del sheet deslizable.
          initialChildSize:
              0.6, // Tamaño inicial (60% de la altura disponible).
          minChildSize: 0.3, // Tamaño mínimo al deslizar hacia abajo.
          maxChildSize: 0.95, // Tamaño máximo al deslizar hacia arriba.
          expand: false, // Evita que ocupe toda la pantalla inicialmente.
          builder: (context, scrollController) {
            // Construye el contenido del sheet, pasando el scrollController
            // para vincular el scroll del sheet con el del contenido.
            // Se crea una instancia de NoticeDetail y se llama a _buildContent internamente.
            return NoticeDetail(anuncio: anuncio)
                ._buildContent(context, scrollController);
          }),
    );
  }

  /// Construye la UI principal del detalle del anuncio.
  /// Este método es llamado internamente por `build` y por el `builder` del `DraggableScrollableSheet`.
  Widget _buildContent(
      BuildContext context, ScrollController scrollController) {
    // --- Extracción de Datos ---
    // Extrae los datos del mapa 'anuncio' con seguridad de nulos.
    final String title = anuncio['title'] ?? 'Detalle del Anuncio';
    final String authorName = anuncio['author_name'] ?? 'Autor Desconocido';
    final String content = anuncio['content'] ?? 'No hay contenido disponible.';
    final bool hasAttachment = anuncio['has_attachment'] ?? false;
    final String? attachmentUrl = anuncio['attachment_url']; // Puede ser null.
    // URL de imagen de respaldo si no hay adjunto o falla la carga.
    final String placeholderImageUrl =
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSdSYD20ZhA_YJ_ijTDssLT1Z-MtyGlMhQe5A&s';

    // --- Estructura del Contenido del Modal ---
    return Container(
      // Container envuelve todo para aplicar el color de fondo y los bordes redondeados.
      decoration: BoxDecoration(
        color: Theme.of(context)
            .canvasColor, // Usa el color de fondo por defecto del tema.
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.0)), // Redondeo solo en la parte superior.
      ),
      child: SingleChildScrollView(
        // Permite hacer scroll si el contenido excede la altura del sheet.
        controller:
            scrollController, // Vincula el scroll al DraggableScrollableSheet.
        child: Padding(
          // Padding general para el contenido.
          padding: EdgeInsets.all(16.0),
          child: Column(
            // Organiza los elementos verticalmente.
            crossAxisAlignment:
                CrossAxisAlignment.start, // Alinea el texto a la izquierda.
            mainAxisSize: MainAxisSize
                .min, // Hace que la columna ocupe solo el espacio vertical necesario.
            children: [
              // --- Indicador Visual para Arrastrar (Opcional) ---
              Center(
                // Pequeña barra gris para indicar que el sheet se puede arrastrar.
                child: Container(
                  width: 40,
                  height: 5,
                  margin: EdgeInsets.only(bottom: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // --- Cabecera: Botón de Retroceso + Título ---
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        size: 20), // Icono de flecha hacia atrás.
                    onPressed: () =>
                        Navigator.pop(context), // Cierra el modal al presionar.
                    tooltip: 'Volver', // Texto de ayuda al mantener presionado.
                  ),
                  SizedBox(width: 8), // Espacio.
                  Expanded(
                    // El título ocupa el espacio restante.
                    child: Text(
                      title,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold), // Estilo del título.
                      overflow: TextOverflow
                          .ellipsis, // Trunca con '...' si es muy largo.
                    ),
                  ),
                ],
              ),

              // --- Autor ---
              SizedBox(height: 8.0), // Espacio antes de la fila del autor.
              Row(
                // Muestra el autor y su icono.
                children: [
                  Text('Autor:',
                      style: TextStyle(
                          color: Colors.grey[700])), // Etiqueta "Autor".
                  SizedBox(width: 4),
                  Expanded(
                    // Nombre del autor.
                    child: Text(
                      authorName,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.person_outline,
                      size: 20.0, color: Colors.grey[700]), // Icono de persona.
                ],
              ),
              Divider(height: 20.0), // --- Divisor ---

              // --- Contenido Principal del Anuncio ---
              Text(
                content,
                style: TextStyle(
                    fontSize: 15.0,
                    height:
                        1.4), // Estilo del contenido, altura de línea para legibilidad.
              ),
              SizedBox(
                  height: 16.0), // Espacio antes de la sección de adjuntos.

              // --- Sección de Adjuntos (si existen) ---
              // Usa el operador 'spread' (...) para añadir condicionalmente los widgets de adjunto.
              if (hasAttachment) ...[
                Text('Attachment:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold)), // Título de la sección.
                SizedBox(height: 12.0), // Espacio.
                // Llama a la función auxiliar para construir el visor de adjuntos.
                _buildAttachmentViewer(
                    context, attachmentUrl, placeholderImageUrl),
                SizedBox(height: 16.0), // Espacio al final del modal.
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Widget auxiliar para construir la vista previa del adjunto.
  ///
  /// Muestra una imagen desde una URL (o una imagen de respaldo) y permite
  /// interacciones futuras (como descargar/abrir) a través de [GestureDetector].
  Widget _buildAttachmentViewer(
      BuildContext context, String? attachmentUrl, String placeholderImageUrl) {
    return GestureDetector(
      // GestureDetector detecta toques en la imagen.
      onTap: () {
        // TODO: Implementar la lógica real para abrir o descargar el archivo adjunto.
        // Se podría usar el paquete url_launcher u otro método según el tipo de archivo.
        print(
            'Intentando abrir/descargar: $attachmentUrl'); // Mensaje de depuración.
        // Muestra un mensaje temporal al usuario.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Funcionalidad de descarga no implementada.')),
        );
        // Ejemplo usando url_launcher (requiere añadir dependencia y permisos):
        // if (attachmentUrl != null) {
        //   final uri = Uri.tryParse(attachmentUrl);
        //   if (uri != null) {
        //     // try {
        //     //   await launchUrl(uri, mode: LaunchMode.externalApplication);
        //     // } catch (e) {
        //     //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo abrir el archivo: $e')));
        //     // }
        //   }
        // }
      },
      child: Center(
        // Centra la imagen/thumbnail.
        child: ClipRRect(
          // Aplica bordes redondeados a la imagen.
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            // Carga la imagen desde la red.
            // Usa la URL del adjunto si existe, si no, usa la URL de respaldo.
            attachmentUrl ?? placeholderImageUrl,
            height: 180, // Altura fija para la vista previa.
            fit: BoxFit
                .contain, // Asegura que se vea toda la imagen, ajustando el tamaño sin recortar.

            // --- Mejoras de Experiencia de Usuario (UX) para la carga ---
            // Muestra un indicador de progreso mientras la imagen carga.
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null)
                return child; // Si es null, la imagen ya cargó.
              return Container(
                height: 180, // Mismo tamaño que la imagen final.
                child: Center(
                  child: CircularProgressIndicator(
                    // Muestra el progreso si está disponible.
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null, // Progreso indeterminado si no se conoce el tamaño total.
                    color: Color(0xFFFCA311), // Color del indicador.
                  ),
                ),
              );
            },
            // Muestra un placeholder o mensaje de error si la imagen no se puede cargar.
            errorBuilder: (context, error, stackTrace) {
              print(
                  "Error cargando imagen: $error"); // Imprime el error en consola.
              return Container(
                height: 180, // Mismo tamaño.
                color: Colors.grey[200], // Fondo gris claro.
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image_outlined,
                        color: Colors.grey[500],
                        size: 40), // Icono de imagen rota.
                    SizedBox(height: 8),
                    Text("No se pudo cargar",
                        style: TextStyle(
                            color: Colors.grey[600])) // Mensaje de error.
                  ],
                )),
              );
            },
          ),
        ),
      ),
    );
  }
}
