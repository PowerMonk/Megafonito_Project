import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importa la librería para interactuar con los assets del proyecto.
import 'dart:convert'; // Importa la librería para trabajar con la codificación y decodificación de JSON.
import 'oppscontent_screen.dart'; // Importa la pantalla de detalles 'OppsContentScreen'.
import '../theme/app_theme.dart';

class OpportunitiesScreen extends StatefulWidget {
  // Define un StatefulWidget llamado 'OpportunitiesScreen'. Los StatefulWidget son widgets cuyo estado puede cambiar dinámicamente.
  const OpportunitiesScreen({super.key});

  @override
  State<OpportunitiesScreen> createState() => _BeneficiosScreenState();
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
      if (aIsItsu) {
        return -1; // Si la ruta 'a' contiene 'itsu_logo', la coloca al principio.
      }
      if (bIsItsu) {
        return 1; // Si la ruta 'b' contiene 'itsu_logo', la coloca después de 'a' (si 'a' no es itsu).
      }
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: AppDesign.page,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(AppDesign.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Explora oportunidades',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 6),
                Text(
                  'Recursos organizados por área académica.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: careerLogos.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : _buildListView(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    // Método para construir la lista de logos de carreras como filas clickeables.
    return ListView.separated(
      // Construye una lista desplazable de widgets bajo demanda.
      itemCount: careerLogos
          .length, // El número de elementos en la lista es igual al número de logos cargados.
      padding: EdgeInsets.zero,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = careerLogos[index];
        return Card(
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Image.asset(
                item['image']!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported_outlined,
                ),
              ),
            ),
            title: Text(
              item['title']!,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OpportunityContentScreen(title: item['title']!),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
