import 'package:flutter/material.dart';

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
    // URL de una imagen de respaldo que se mostrará si no hay adjunto o si falla la carga del adjunto.
    final String placeholderImageUrl =
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSdSYD20ZhA_YJ_ijTDssLT1Z-MtyGlMhQe5A&s';
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
                      Text('Attachment:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 12.0),
                      // Llama a la función [_buildAttachmentViewer] para mostrar la vista previa del adjunto.
                      _buildAttachmentViewer(
                          context, attachmentUrl, placeholderImageUrl),
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

  /// Widget auxiliar [_buildAttachmentViewer] que construye la vista previa del adjunto (imagen).
  /// Recibe el [BuildContext], la [attachmentUrl] (puede ser null) y la [placeholderImageUrl].
  Widget _buildAttachmentViewer(
      BuildContext context, String? attachmentUrl, String placeholderImageUrl) {
    // [GestureDetector] detecta gestos táctiles. Aquí, se usa para implementar la funcionalidad de tocar el adjunto.
    return GestureDetector(
      // [onTap] es la función que se llama cuando se toca el widget.
      onTap: () {
        // [ScaffoldMessenger] se usa para mostrar [SnackBar]s (mensajes cortos en la parte inferior de la pantalla).
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Funcionalidad de descarga no implementada.')),
        );
      },
      // [child] es el widget que reacciona a los gestos. Aquí, es un [Center] que contiene la imagen.
      child: Center(
        // [ClipRRect] recorta su hijo con un [BorderRadius]. Aquí, redondea las esquinas de la imagen.
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          // [Image.network] muestra una imagen cargada desde una URL.
          child: Image.network(
            // Usa la [attachmentUrl] si no es null, de lo contrario, usa la [placeholderImageUrl].
            attachmentUrl ?? placeholderImageUrl,
            // [height] define la altura deseada de la imagen.
            height: 180,
            // [fit] define cómo debe ajustarse la imagen dentro de su contenedor.
            // [BoxFit.contain] escala la imagen para que quepa dentro del contenedor sin recortarla.
            fit: BoxFit.contain,
            // [loadingBuilder] es una función que se llama mientras la imagen está cargando.
            loadingBuilder: (context, child, loadingProgress) {
              // Si [loadingProgress] es null, significa que la imagen ya cargó, así que devuelve el [child] (la imagen).
              if (loadingProgress == null) return child;
              // Mientras la imagen está cargando, muestra un [Container] con un [CircularProgressIndicator].
              return Container(
                height: 180,
                child: Center(
                  child: CircularProgressIndicator(
                    // [value] del [CircularProgressIndicator] se basa en el progreso de la carga si está disponible.
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: Color(0xFFFCA311),
                  ),
                ),
              );
            },
            // [errorBuilder] es una función que se llama si ocurre un error al cargar la imagen.
            errorBuilder: (context, error, stackTrace) {
              // Muestra un [Container] con un fondo gris y un icono de imagen rota y un mensaje de error.
              return Container(
                height: 180,
                color: Colors.grey[200],
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image_outlined,
                        color: Colors.grey[500], size: 40),
                    SizedBox(height: 8),
                    Text("No se pudo cargar",
                        style: TextStyle(color: Colors.grey[600]))
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
