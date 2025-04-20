import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importa la librería para interactuar con los assets del proyecto.
import 'dart:convert'; // Importa la librería para trabajar con la codificación y decodificación de JSON.
import 'oppscontent_screen.dart'; // Importa la pantalla de detalles 'OppsContentScreen'.

class OpportunitiesScreen extends StatefulWidget {
  // Define un StatefulWidget llamado 'OpportunitiesScreen'. Los StatefulWidget son widgets cuyo estado puede cambiar dinámicamente.
  @override
  _BeneficiosScreenState createState() => _BeneficiosScreenState();
  // Sobrescribe el método 'createState()' para crear la instancia del estado mutable asociado a este widget.
  // Notar que el nombre del estado es '_BeneficiosScreenState', aunque el widget se llama 'OpportunitiesScreen'.
  // Esto podría ser un error tipográfico y debería ser '_OpportunitiesScreenState' para mayor claridad.
}

class _BeneficiosScreenState extends State<OpportunitiesScreen> {
  // Define la clase de estado '_BeneficiosScreenState' que extiende de 'State<OpportunitiesScreen>'.
  List<Map<String, String>> careerLogos = [];
  // Declara una lista mutable llamada 'careerLogos'. Cada elemento de la lista es un mapa
  // que contendrá la ruta de la imagen ('image') y el título ('title') de un logo de carrera.

  @override
  void initState() {
    // Sobrescribe el método 'initState()', que se llama solo una vez cuando se inserta este objeto de estado.
    super
        .initState(); // Llama a la implementación de 'initState()' de la superclase.
    _loadAssetNames(); // Llama al método '_loadAssetNames()' para cargar la información de los logos al iniciar la pantalla.
  }

  Future<void> _loadAssetNames() async {
    // Define un método asíncrono llamado '_loadAssetNames()' que carga los nombres de los assets de las imágenes.
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    // Utiliza 'rootBundle' para cargar el contenido del archivo 'AssetManifest.json' como una cadena.
    // 'AssetManifest.json' es un archivo generado durante la compilación que lista todos los assets incluidos en la aplicación.
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // Decodifica la cadena JSON del manifiesto en un mapa donde las claves son las rutas de los assets
    // y los valores son información adicional (que en este caso no se utiliza directamente).

    final Map<String, String> titleMapping = {
      // Define un mapa que asocia los nombres base de los archivos de logo con títulos más amigables para el usuario.
      'itsu_logo': 'General',
      'ing_admin_logo': 'Ing. en Administración',
      'ing_agricola_logo': 'Ing. en Innovación Agrícola',
      'ing_alimentarias_logo': 'Ing. en Industrias Alimentarias',
      'ing_civil_logo': 'Ing. Civil',
      'ing_electronica_logo': 'Ing. Electrónica',
      'ing_industrial_logo': 'Ing. Industrial',
      'ing_mecanica_logo': 'Ing. Mecánica',
      'ing_mecatronica_logo': 'Ing. Mecatrónica',
      'ing_sistemas_logo': 'Ing. en Sistemas Computacionales',
    };

    List<String> imagePaths = manifestMap.keys
        .where((String key) => key.startsWith('assets/logos_carreras/'))
        .toList();
    // Filtra las claves del mapa del manifiesto para obtener solo las rutas de los assets
    // que comienzan con 'assets/logos_carreras/', que se asume es la carpeta donde están los logos de las carreras.
    // Convierte el resultado a una lista de strings.

    imagePaths.sort((a, b) {
      // Ordena la lista de rutas de imágenes.
      bool aIsItsu = a.contains('itsu_logo');
      bool bIsItsu = b.contains('itsu_logo');
      if (aIsItsu)
        return -1; // Si la ruta 'a' contiene 'itsu_logo', la coloca al principio.
      if (bIsItsu)
        return 1; // Si la ruta 'b' contiene 'itsu_logo', la coloca después de 'a' (si 'a' no es itsu).
      return a.compareTo(
          b); // Para las demás rutas, realiza una comparación alfabética.
    });

    careerLogos = imagePaths.map((path) {
      // Mapea cada ruta de imagen a un mapa que contiene la ruta ('image') y un título ('title').
      String filename =
          path.split('/').last; // Obtiene el nombre del archivo de la ruta.
      String filenameBase = filename.contains('.')
          ? filename.substring(0, filename.lastIndexOf('.'))
          : filename;
      // Obtiene el nombre base del archivo (sin la extensión).

      String title = titleMapping[filenameBase] ??
          filenameBase.replaceAll('_logo', '').replaceAll('_', ' ');
      // Busca un título en 'titleMapping' usando el nombre base del archivo.
      // Si no se encuentra, genera un título eliminando '_logo' y reemplazando '_' con espacios.

      return {
        'image': path,
        'title': title
      }; // Retorna un mapa con la ruta y el título.
    }).toList(); // Convierte el resultado del mapeo a una lista.

    if (mounted) {
      // Verifica si el widget está actualmente montado en el árbol.
      setState(
          () {}); // Llama a 'setState()' para notificar al framework que el estado interno ha cambiado,
      // lo que provocará una reconstrucción del widget con los nuevos datos de 'careerLogos'.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sobrescribe el método 'build()' que describe la parte de la interfaz de usuario representada por este widget.
    return Container(
      color:
          Colors.white, // Establece el color de fondo del contenedor a blanco.
      padding: const EdgeInsets.all(
          16.0), // Añade un padding de 16 píxeles en todos los lados del contenedor.
      child: Column(
        // Organiza los widgets hijos verticalmente.
        crossAxisAlignment: CrossAxisAlignment
            .start, // Alinea los hijos al inicio (izquierda) horizontalmente.
        children: [
          Text(
            // Widget para mostrar el título de la sección.
            'Categorías',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(
              height:
                  16), // Añade un espacio vertical de 16 píxeles entre el título y la lista.
          Expanded(
            // Expande el widget hijo para llenar el espacio disponible en la dirección del padre (vertical en este caso).
            child: careerLogos.isEmpty
                ? Center(
                    child: CircularProgressIndicator(color: Color(0xFFFCA311)))
                // Si la lista 'careerLogos' está vacía (mientras se cargan los datos),
                // muestra un indicador de carga circular en el centro.
                : _buildListView(),
            // Si 'careerLogos' no está vacía, llama al método '_buildListView()' para construir la lista de categorías.
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    // Método para construir la lista de logos de carreras como filas clickeables.
    final screenWidth =
        MediaQuery.of(context).size.width; // Obtiene el ancho de la pantalla.
    double containerSize = screenWidth *
        0.22; // Define un tamaño para el contenedor del logo basado en el ancho de la pantalla.
    containerSize = containerSize.clamp(80.0,
        120.0); // Asegura que el tamaño esté dentro de un rango mínimo y máximo.
    const double innerPadding =
        8.0; // Define un padding interno para el logo dentro de su contenedor.

    return ListView.builder(
      // Construye una lista desplazable de widgets bajo demanda.
      itemCount: careerLogos
          .length, // El número de elementos en la lista es igual al número de logos cargados.
      itemBuilder: (context, index) {
        // Función que se llama para construir cada elemento de la lista. 'index' es la posición del elemento actual.
        return InkWell(
          // Un widget que hace que su hijo sea receptivo a los toques y añade efectos visuales.
          // Make the entire row clickable (Comentario que indica que toda la fila será clickeable).
          onTap: () {
            // Define la acción que ocurre cuando se toca el elemento.
            // Navigate to detail screen with the selected title (Comentario que indica la navegación a la pantalla de detalles).
            Navigator.push(
              // Navega a una nueva ruta en la pila de navegadores.
              context,
              MaterialPageRoute(
                // Crea una ruta que construye un widget.
                builder: (context) => OpportunityContentScreen(
                  // El widget a construir es 'OpportunityContentScreen'.
                  title: careerLogos[index]['title']!,
                  // Pasa el título de la categoría seleccionada a la pantalla de detalles.
                ),
              ),
            );
          },
          child: Padding(
            // Añade un padding alrededor de la fila para espaciamiento visual.
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              // Organiza los widgets hijos horizontalmente.
              crossAxisAlignment: CrossAxisAlignment
                  .center, // Alinea los hijos verticalmente al centro.
              children: [
                Container(
                  // Contenedor para el logo de la carrera.
                  width: containerSize,
                  height: containerSize,
                  decoration: BoxDecoration(
                    // Define la decoración del contenedor (borde y radio de las esquinas).
                    border: Border.all(
                        color: const Color.fromARGB(255, 218, 215, 215)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    // Recorta su hijo usando un rectángulo redondeado.
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      // Añade un padding interno al widget 'Image.asset'.
                      padding: const EdgeInsets.all(innerPadding),
                      child: Image.asset(
                        // Widget para mostrar una imagen desde los assets.
                        careerLogos[index]['image']!,
                        fit: BoxFit
                            .contain, // Ajusta la imagen dentro del contenedor manteniendo su relación de aspecto.
                        errorBuilder: (context, error, stackTrace) {
                          // Función que se llama si ocurre un error al cargar la imagen.
                          print(
                              "Error cargando imagen: ${careerLogos[index]['image']!} - $error");
                          return Icon(Icons.image_not_supported,
                              color: Colors.grey);
                          // Muestra un icono de imagen no soportada en caso de error.
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                    width:
                        16), // Añade un espacio horizontal de 16 píxeles entre el logo y el título.
                Expanded(
                  // Expande el widget hijo para llenar el espacio disponible horizontalmente.
                  child: Text(
                    // Widget para mostrar el título de la carrera.
                    careerLogos[index]['title']!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
