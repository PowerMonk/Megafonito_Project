import 'package:flutter/material.dart';

/// Un widget que representa una tarjeta individual para mostrar un resumen de un anuncio.
///
/// Esta tarjeta es interactiva (`InkWell`) y muestra información clave como
/// el autor, título, categoría y si tiene adjuntos. Al ser tocada, ejecuta
/// la función [onTap] proporcionada.
class NoticeCard extends StatelessWidget {
  /// El mapa que contiene los datos del anuncio a mostrar.
  /// Se espera que contenga claves como 'author_name', 'title', 'category', 'has_attachment'.
  final Map<String, dynamic> anuncio;

  /// La función callback que se ejecuta cuando la tarjeta es presionada.
  /// Recibe el mapa [anuncio] como argumento.
  final Function(Map<String, dynamic>) onTap;

  /// Constructor para [NoticeCard].
  ///
  /// Requiere el [anuncio] (mapa de datos) y la función [onTap].
  const NoticeCard({
    Key? key, // Clave opcional para el widget.
    required this.anuncio, // Datos del anuncio son obligatorios.
    required this.onTap, // Función a ejecutar al tocar es obligatoria.
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Extracción de Datos ---
    // Extrae los datos del mapa 'anuncio' usando el operador '??' para proporcionar
    // valores por defecto en caso de que la clave no exista o su valor sea nulo.
    // Esto asegura que la UI no falle si faltan datos.
    final String authorName = anuncio['author_name'] ??
        'mgfdev@itsuruapan.edu.mx'; // Nombre del autor o valor por defecto.
    final String title = anuncio['title'] ??
        'Sin Título'; // Título del anuncio o valor por defecto.
    final String category =
        anuncio['category'] ?? 'General'; // Categoría o valor por defecto.
    final bool hasAttachment = anuncio['has_attachment'] ??
        false; // Indica si hay adjunto (asume falso por defecto).
    final String createdAt = '14 abr'; // Simulación de fecha de creación.

    // --- Estructura de la Tarjeta ---
    return InkWell(
      // InkWell proporciona el efecto visual de "onda" al tocar y maneja el evento onTap.
      onTap: () => onTap(
          anuncio), // Llama a la función callback pasando los datos del anuncio actual.
      child: Card(
        color: Colors.white, // Color de fondo de la tarjeta
        // Card proporciona un contenedor con sombra y bordes redondeados.
        margin: EdgeInsets.symmetric(
            vertical: 11.0), // Margen vertical entre tarjetas.
        elevation: 2.0, // Elevación para la sombra.
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                12.0)), // Bordes redondeados más pronunciados.
        clipBehavior: Clip
            .antiAlias, // Asegura que el contenido respete los bordes redondeados.
        child: Padding(
          // Padding interno para el contenido de la tarjeta.
          padding: EdgeInsets.all(12.0),
          child: Column(
            // Organiza el contenido en una columna vertical.
            crossAxisAlignment:
                CrossAxisAlignment.start, // Alinea el contenido a la izquierda.
            children: [
              // --- Sección 1: Autor + Icono + Fecha ---
              Row(
                // Organiza el autor, icono y fecha en una fila horizontal.
                children: [
                  Text('Autor:',
                      style: TextStyle(
                          color: Colors.grey[700])), // Etiqueta "Autor".
                  SizedBox(width: 4), // Pequeño espacio horizontal.
                  Text(
                    authorName,
                    style: TextStyle(
                        fontWeight:
                            FontWeight.w500), // Estilo del nombre del autor.
                    overflow: TextOverflow
                        .ellipsis, // Añade '...' si el texto es muy largo.
                    maxLines: 1, // Limita a una sola línea.
                  ),
                  SizedBox(width: 4), // Espacio antes del icono.
                  Icon(Icons.person_outline,
                      size: 20.0, color: Colors.grey[700]), // Icono de persona.
                  Spacer(), // Empuja la fecha al extremo derecho.
                  Text(createdAt, // Fecha de creación simulada.
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
              Divider(height: 16.0, thickness: 1.0), // --- Divisor visual 1 ---

              // --- Sección 2: Título ---
              Text(
                title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold), // Estilo del título.
                maxLines: 2, // Limita el título a 2 líneas.
                overflow: TextOverflow.ellipsis, // Añade '...' si es muy largo.
              ),
              Divider(height: 16.0, thickness: 1.0), // --- Divisor visual 2 ---

              // --- Sección 3: Categoría, Adjunto + Estrella ---
              Row(
                // Organiza los elementos de la última sección en una fila.
                children: [
                  Icon(Icons.circle,
                      size: 10,
                      color: Colors
                          .blueAccent), // Icono de círculo para la categoría.
                  SizedBox(width: 6), // Espacio.
                  Text(category,
                      style:
                          TextStyle(fontSize: 13)), // Nombre de la categoría.
                  SizedBox(width: 4), // Espacio.
                  // Muestra el icono de clip solo si 'hasAttachment' es verdadero.
                  if (hasAttachment)
                    Icon(Icons.attach_file_outlined,
                        size: 18, color: Colors.grey[700]), // Icono de adjunto.
                  SizedBox(width: 4), // Espacio.
                  Spacer(), // Spacer ocupa todo el espacio disponible, empujando lo siguiente a la derecha.
                  // Text('Destacar',
                  //     style: TextStyle(
                  //         fontSize: 12,
                  //         color: Colors.orange)), // Texto "Destacar".
                  // SizedBox(width: 4), // Espacio.
                  Icon(Icons.star_border,
                      color: Colors.orangeAccent,
                      size: 18.0), // Icono de estrella (borde).
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un widget que muestra una lista de anuncios [NoticeCard] con soporte para
/// "pull-to-refresh" y carga bajo demanda ("load more").
///
/// Este widget es `StatelessWidget` porque delega la gestión del estado (la lista
/// de anuncios, el estado de carga, etc.) al widget padre a través de callbacks.
class NoticesContent extends StatelessWidget {
  /// La lista actual de anuncios a mostrar. Cada elemento es un mapa.
  final List<Map<String, dynamic>> anuncios;

  /// Indica si hay más páginas de anuncios por cargar.
  final bool hasMoreData;

  /// Indica si actualmente se está cargando la siguiente página de anuncios.
  final bool isLoading;

  /// Callback que se ejecuta cuando se toca una [NoticeCard].
  final Function(Map<String, dynamic>) onNoticeTap;

  /// Callback asíncrono que se ejecuta cuando el usuario hace "pull-to-refresh".
  final Future<void> Function() onRefresh;

  /// Callback que se ejecuta cuando el usuario llega al final de la lista y presiona "Cargar más".
  final Function() onLoadMore;

  /// Constructor para [NoticesContent].
  const NoticesContent({
    Key? key,
    required this.anuncios, // Lista de anuncios obligatoria.
    required this.hasMoreData, // Estado de paginación obligatorio.
    required this.isLoading, // Estado de carga obligatorio.
    required this.onNoticeTap, // Callback para tocar anuncio obligatorio.
    required this.onRefresh, // Callback para refrescar obligatorio.
    required this.onLoadMore, // Callback para cargar más obligatorio.
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // RefreshIndicator envuelve la lista para habilitar "pull-to-refresh".
    return RefreshIndicator(
      onRefresh: onRefresh, // Llama a la función de refresco proporcionada.
      color: Color(0xFFFCA311), // Color del indicador de progreso circular.
      child: ListView.builder(
        // ListView.builder es eficiente para listas largas, ya que solo construye
        // los elementos que son visibles en pantalla.
        padding: EdgeInsets.all(16.0), // Padding alrededor de toda la lista.
        // El número total de ítems es la cantidad de anuncios más 1 si hay
        // más datos por cargar (para mostrar el botón/indicador de "Cargar más").
        itemCount: anuncios.length + (hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          // --- Lógica para construir cada ítem de la lista ---

          // Si el índice actual es menor que la cantidad de anuncios,
          // significa que debemos mostrar una tarjeta de anuncio.
          if (index < anuncios.length) {
            return NoticeCard(
              anuncio:
                  anuncios[index], // Pasa los datos del anuncio específico.
              onTap:
                  onNoticeTap, // Pasa la función callback para el evento onTap.
            );
          }
          // Si el índice es igual o mayor y 'hasMoreData' es verdadero,
          // significa que hemos llegado al final de los anuncios actuales
          // y debemos mostrar el widget para cargar más.
          else if (hasMoreData) {
            return _buildLoadMoreWidget(); // Llama a la función auxiliar.
          }
          // Si no estamos en un índice de anuncio y 'hasMoreData' es falso,
          // significa que hemos llegado al final de todos los anuncios.
          else {
            // Muestra un mensaje indicando que no hay más anuncios.
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Text(
                  "No hay más anuncios",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  /// Widget auxiliar para mostrar el indicador de carga o el botón "Cargar más".
  ///
  /// Se muestra al final de la lista si [hasMoreData] es verdadero.
  Widget _buildLoadMoreWidget() {
    // Si 'isLoading' es verdadero, muestra un indicador de progreso.
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child:
            Center(child: CircularProgressIndicator(color: Color(0xFFFCA311))),
      );
    }
    // Si no está cargando, muestra el botón para cargar más anuncios.
    else {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: ElevatedButton(
            onPressed:
                onLoadMore, // Llama a la función de cargar más al presionar.
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFCA311), // Color de fondo del botón.
              foregroundColor: Colors.black, // Color del texto del botón.
            ),
            child: Text('Cargar más anuncios'),
          ),
        ),
      );
    }
  }
}
