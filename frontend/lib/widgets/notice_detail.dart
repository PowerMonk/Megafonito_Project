import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // ¡Asegúrate de añadir esta dependencia en tu pubspec.yaml!
import 'package:path/path.dart'
    as p; // ¡Asegúrate de añadir esta dependencia en tu pubspec.yaml!

/// Normalmente se muestra dentro de un Modal Bottom Sheet. Incluye el título,
/// autor, contenido completo y una vista previa del adjunto si existe.
/// Proporciona un método estático [show] para facilitar su visualización
class NoticeDetail extends StatelessWidget {
  /// [anuncio] es un mapa que contiene los datos del anuncio a mostrar.
  /// Se espera que contenga claves como 'title', 'author_name', 'content',
  /// 'has_attachment', 'attachment_url', y 'expiry_date'.
  final Map<String, dynamic> anuncio;

  /// Constructor para [NoticeDetail]. Recibe el mapa [anuncio] requerido.
  const NoticeDetail({
    Key? key,
    required this.anuncio,
  }) : super(key: key);

  /// El método [build] es el punto de entrada para construir la UI del widget.
  /// En este caso, simplemente llama a [_buildContent] para construir el contenido real.
  /// Se le pasa el [BuildContext] actual y un nuevo [ScrollController].
  @override
  Widget build(BuildContext context) {
    return _buildContent(context, ScrollController());
  }

  /// Método estático [show] que facilita la presentación de [NoticeDetail]
  /// como un [ModalBottomSheet] dentro de un [DraggableScrollableSheet].
  ///
  /// [context]: El [BuildContext] actual desde donde se llama a este método.
  /// [anuncio]: El mapa de datos del anuncio que se mostrará en el modal.
  static void show(BuildContext context, Map<String, dynamic> anuncio) {
    // Muestra un [ModalBottomSheet]. Este widget aparece desde la parte inferior de la pantalla.
    showModalBottomSheet(
      context: context,
      // [isScrollControlled] determina si el modal puede expandirse para ocupar toda la altura disponible.
      // Establecerlo en true permite que el [DraggableScrollableSheet] funcione correctamente.
      isScrollControlled: true,
      // [backgroundColor] establece el color de fondo del [ModalBottomSheet].
      // Usamos [Colors.transparent] para que se vea la forma redondeada del contenido interior.
      backgroundColor: Colors.transparent,
      // [shape] define la forma del [ModalBottomSheet], en este caso, con bordes redondeados en la parte superior.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.0)),
      ),
      // [builder] es una función que construye el contenido del [ModalBottomSheet].
      // Aquí, usamos un [DraggableScrollableSheet] para permitir que el usuario deslice el modal hacia arriba y hacia abajo.
      builder: (_) => DraggableScrollableSheet(
        // [initialChildSize] define la altura inicial del [DraggableScrollableSheet] como una fracción de la altura de la pantalla (60%).
        initialChildSize: 0.6,
        // [minChildSize] define la altura mínima a la que el [DraggableScrollableSheet] puede ser deslizado (30%).
        minChildSize: 0.3,
        // [maxChildSize] define la altura máxima a la que el [DraggableScrollableSheet] puede ser deslizado (95%).
        maxChildSize: 0.95,
        // [expand] determina si el [DraggableScrollableSheet] debe ocupar toda la pantalla inicialmente.
        // Lo establecemos en false para que comience con la [initialChildSize].
        expand: false,
        // El [builder] de [DraggableScrollableSheet] construye el widget que se mostrará dentro del sheet.
        // Recibe el [BuildContext] y un [ScrollController] que está vinculado al desplazamiento del sheet.
        builder: (context, scrollController) {
          // Creamos una instancia de [NoticeDetail] y llamamos a [_buildContent] para construir el contenido real,
          // pasando el [BuildContext] y el [ScrollController] del [DraggableScrollableSheet].
          return NoticeDetail(anuncio: anuncio)
              ._buildContent(context, scrollController);
        },
      ),
    );
  }

  /// Widget [_buildContent] que construye la UI principal del detalle del anuncio.
  /// Recibe el [BuildContext] actual y el [ScrollController] del [DraggableScrollableSheet].
  Widget _buildContent(
      BuildContext context, ScrollController scrollController) {
    // Extrae el título del mapa [anuncio]. Si la clave 'title' no existe, usa 'Detalle del Anuncio' como valor por defecto.
    final String title = anuncio['title'] ?? 'Detalle del Anuncio';
    // Extrae el nombre del autor del mapa [anuncio]. Si la clave 'author_name' no existe, usa 'Autor Desconocido' como valor por defecto.
    final String authorName = anuncio['author_name'] ?? 'Autor Desconocido';
    // Extrae el contenido del anuncio del mapa [anuncio]. Si la clave 'content' no existe, usa 'No hay contenido disponible.' como valor por defecto.
    final String content = anuncio['content'] ?? 'No hay contenido disponible.';
    // Extrae el valor booleano que indica si hay un adjunto del mapa [anuncio]. Si la clave 'has_attachment' no existe, asume false por defecto.
    final bool hasAttachment = anuncio['has_attachment'] ?? false;
    // Extrae la URL del adjunto del mapa [anuncio]. Puede ser null si no hay adjunto.
    final String? attachmentUrl = anuncio['attachment_url'];
    // Extrae la fecha de expiración del mapa [anuncio]. Si la clave 'expiry_date' no existe, usa '29 abr' como valor por defecto.
    final String expiryDate = anuncio['expiry_date'] ?? '29 abr';

    // Retorna un [Container] que envuelve todo el contenido del modal.
    return Container(
      // [decoration] define la apariencia visual del [Container], en este caso, el color de fondo y los bordes redondeados en la parte superior.
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.0)),
      ),
      // [child] contiene la estructura de la UI dentro del [Container].
      child: Column(
        // [crossAxisAlignment] define cómo se alinean los hijos a lo largo del eje transversal (horizontal en este caso).
        // [CrossAxisAlignment.stretch] hace que los hijos se estiren para llenar el ancho del padre.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        // [children] es una lista de widgets que se mostrarán en la columna.
        children: [
          // [Expanded] hace que un hijo de una [Row] o [Column] ocupe todo el espacio disponible a lo largo del eje principal.
          // Aquí, asegura que el [SingleChildScrollView] ocupe la mayor parte del espacio vertical disponible.
          Expanded(
            // [SingleChildScrollView] es un widget que permite desplazar su contenido si excede el espacio disponible.
            child: SingleChildScrollView(
              // [controller] vincula este [SingleChildScrollView] al [ScrollController] del [DraggableScrollableSheet],
              // permitiendo que el desplazamiento del contenido controle el desplazamiento del sheet.
              controller: scrollController,
              // [child] contiene el contenido desplazable, envuelto en un [Padding].
              child: Padding(
                // [padding] añade espacio alrededor del contenido interior.
                padding: EdgeInsets.all(16.0),
                // [child] es una [Column] que organiza los elementos verticalmente dentro del [Padding].
                child: Column(
                  // [crossAxisAlignment] alinea los hijos al inicio del eje transversal (izquierda).
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // [mainAxisSize] define cuánto espacio ocupa la columna a lo largo de su eje principal (vertical).
                  // [MainAxisSize.min] hace que la columna ocupe solo el espacio necesario para sus hijos.
                  mainAxisSize: MainAxisSize.min,
                  // [children] es la lista de widgets dentro de esta columna.
                  children: [
                    // [Center] centra su hijo dentro de sí mismo.
                    Center(
                      // Contenedor para el indicador visual de arrastre.
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
                    // [Row] organiza sus hijos en una fila horizontal.
                    Row(
                      children: [
                        // [IconButton] es un botón con un icono.
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_new, size: 20),
                          // [onPressed] es la función que se llama cuando se presiona el botón. Aquí, cierra el modal.
                          onPressed: () => Navigator.pop(context),
                          // [tooltip] proporciona una descripción breve del botón para accesibilidad.
                          tooltip: 'Volver',
                        ),
                        // [SizedBox] añade espacio con un ancho específico.
                        SizedBox(width: 8),
                        // [Expanded] hace que el [Text] ocupe todo el espacio horizontal disponible.
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        Text('Autor:',
                            style: TextStyle(color: Colors.grey[700])),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(authorName,
                              style: TextStyle(fontWeight: FontWeight.w500)),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.person_outline,
                            size: 20.0, color: Colors.grey[700]),
                      ],
                    ),
                    // [Divider] es una línea horizontal que separa visualmente el contenido.
                    Divider(height: 20.0),
                    // [Text] muestra texto en la pantalla.
                    Text(
                      content,
                      style: TextStyle(fontSize: 15.0, height: 1.4),
                    ),
                    SizedBox(height: 16.0),
                    // [if (hasAttachment) ...] es una forma condicional de añadir widgets a la lista.
                    // Si [hasAttachment] es true, los widgets dentro de los corchetes se añaden.
                    if (hasAttachment) ...[
                      Text('Archivo adjunto:', // Cambiado de 'Attachment:'
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 12.0),
                      // Llama a la función [_buildAttachmentDisplay] para mostrar el display del adjunto.
                      _buildAttachmentDisplay(context, attachmentUrl),
                      SizedBox(height: 16.0),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // [Padding] añade espacio alrededor del [Divider].
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(height: 1.0, thickness: 1.0),
          ),
          // [Padding] añade espacio alrededor del texto de la fecha de expiración.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            // [Text] que muestra la fecha de expiración.
            child: Text(
              'Fecha de expiración: $expiryDate',
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  /// Función auxiliar para obtener el icono basado en la extensión del archivo.
  IconData _getFileIcon(String? fileName) {
    if (fileName == null)
      return Icons.insert_drive_file; // Icono genérico por defecto

    final extension = p.extension(fileName).toLowerCase();
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.xls':
      case '.xlsx':
        return Icons.table_chart;
      case '.ppt':
      case '.pptx':
        return Icons.slideshow;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return Icons.image;
      case '.zip':
      case '.rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file; // Icono genérico para otros tipos
    }
  }

  /// Nuevo widget auxiliar [_buildAttachmentDisplay] que construye la visualización del adjunto.
  /// Recibe el [BuildContext] y la [attachmentUrl].
  Widget _buildAttachmentDisplay(BuildContext context, String? attachmentUrl) {
    // Si no hay URL de adjunto, aún así mostramos un placeholder con el nombre fijo.
    // Esto es diferente a OpportunitiesDetail donde no se mostraba nada si no había URL.
    final String displayFileName = 'Archivo_importante.pdf';
    final IconData fileIcon =
        _getFileIcon(displayFileName); // Usamos el nombre fijo para el icono

    return InkWell(
      onTap: () async {
        if (attachmentUrl == null || attachmentUrl.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('No hay URL de archivo adjunto para abrir.')),
          );
          return;
        }

        try {
          final uri = Uri.parse(attachmentUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'No se pudo abrir el archivo adjunto. Verifique la URL.')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al intentar abrir el adjunto: $e')),
          );
          print('Error al intentar abrir adjunto: $e'); // Para depuración
        }
      },
      child: Material(
        elevation: 2.0, // Puedes ajustar este valor
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey[
                100], // Cambié a un color más claro para que la sombra sea más visible
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Icon(fileIcon,
                  size: 30, color: Colors.blue[700]), // Icono representativo
              SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  displayFileName, // Usamos el nombre fijo aquí
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                  overflow:
                      TextOverflow.ellipsis, // Para manejar nombres largos
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey[600]), // Icono de flecha
            ],
          ),
        ),
      ),
    );
  }

  /// **Eliminado:** El widget _buildAttachmentViewer fue reemplazado por _buildAttachmentDisplay
  /// y su lógica se ha integrado para manejar la apertura de URLs de adjuntos.
  /// No necesitamos un visor de imágenes de respaldo si el objetivo es abrir un archivo.
}
