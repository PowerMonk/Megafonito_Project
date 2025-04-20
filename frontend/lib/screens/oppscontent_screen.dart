import 'package:flutter/material.dart';

class OpportunityContentScreen extends StatefulWidget {
  // Define un StatefulWidget llamado 'OpportunityContentScreen'.
  // Los StatefulWidget son widgets cuyo estado puede cambiar con el tiempo.
  final String title;

  // Constructor para 'OpportunityContentScreen' que requiere un título.
  // 'Key? key' es una convención para permitir que Flutter identifique de forma única los widgets.
  const OpportunityContentScreen({Key? key, required this.title})
      : super(key: key);

  @override
  _OpportunityContentScreenState createState() =>
      _OpportunityContentScreenState();
  // Sobrescribe el método 'createState()' para crear la instancia del estado mutable
  // asociado a este widget.
}

class _OpportunityContentScreenState extends State<OpportunityContentScreen> {
  // Define la clase de estado '_OpportunityContentScreenState' que extiende de
  // 'State<OpportunityContentScreen>'. Esta clase mantiene el estado de nuestro widget.

  // Demo data for each category - in a real app, this would come from an API or database.

  final List<Map<String, String>> becasItems = List.generate(
    10,
    (index) => {
      'image': 'assets/test_images/Dela_Ousi.jpg', // Using the provided image
      'title': 'Beca ${index + 1}',
    },
  );
  // Crea una lista de 10 mapas para simular elementos de becas. Cada mapa tiene una clave 'image'
  // con la ruta de una imagen de prueba y una clave 'title' con un título genérico.

  final List<Map<String, String>> cursosItems = List.generate(
    8,
    (index) => {
      'image': 'assets/test_images/Dela_Ousi.jpg',
      'title': 'Curso ${index + 1}',
    },
  );
  // Similar a 'becasItems', pero crea una lista de 8 elementos para cursos.

  final List<Map<String, String>> trabajosItems = List.generate(
    12,
    (index) => {
      'image': 'assets/test_images/Dela_Ousi.jpg',
      'title': 'Trabajo ${index + 1}',
    },
  );
  // Similar a las anteriores, pero crea una lista de 12 elementos para trabajos.

  @override
  Widget build(BuildContext context) {
    // Sobrescribe el método 'build()' que describe la parte de la interfaz de usuario
    // representada por este widget. Se llama cada vez que es necesario reconstruir el widget.
    return Scaffold(
      // 'Scaffold' proporciona la estructura visual básica para las pantallas de Material Design,
      // como AppBar, body, FloatingActionButton, etc.
      appBar: AppBar(
        // 'AppBar' es una barra de herramientas que se muestra en la parte superior de la pantalla.
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        // Muestra el título de la pantalla, que se pasa a través del constructor del widget.
        // El estilo del texto se establece para que sea blanco.
        backgroundColor: Colors.black,
        // Establece el color de fondo del AppBar a negro.
        iconTheme: IconThemeData(color: Colors.white),
        // Define el estilo de los iconos dentro del AppBar para que sean blancos.
      ),
      body: Container(
        // 'Container' es un widget de propósito general que puede contener otros widgets
        // y tiene propiedades para el padding, margenes, color de fondo, etc.
        color: Colors.white,
        // Establece el color de fondo del Container a blanco. Este será el fondo principal de la pantalla.
        child: Column(
          // 'Column' organiza a sus hijos en una dirección vertical.
          // Usamos una Columna como hijo directo del Container
          children: [
            Expanded(
              // 'Expanded' hace que un widget hijo de un Row o Column se expanda
              // para llenar el espacio disponible.
              // El SingleChildScrollView ahora está dentro de un Expanded
              child: SingleChildScrollView(
                // 'SingleChildScrollView' permite desplazar su contenido si este excede
                // el tamaño de la pantalla.
                child: Padding(
                  // 'Padding' añade un espacio alrededor de su widget hijo.
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    // Otra 'Column' anidada para organizar las secciones de categorías verticalmente.
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // Alinea los hijos de esta columna al inicio (izquierda).
                    children: [
                      _buildCategorySection('Becas', becasItems),
                      // Llama al método '_buildCategorySection' para construir la sección de becas.
                      SizedBox(height: 24),
                      // 'SizedBox' crea un espacio con una altura o ancho específico (aquí, un espacio vertical de 24 píxeles).
                      _buildCategorySection(
                          'Cursos y Certificaciones', cursosItems),
                      // Llama al método '_buildCategorySection' para construir la sección de cursos.
                      SizedBox(height: 24),
                      _buildCategorySection('Bolsa de Trabajo', trabajosItems),
                      // Llama al método '_buildCategorySection' para construir la sección de bolsa de trabajo.
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(String title, List<Map<String, String>> items) {
    // Método para construir una sección individual de categoría (Becas, Cursos, Trabajos).
    // Toma un título y una lista de items como argumentos.
    return Column(
      // Organiza los widgets hijos verticalmente dentro de cada sección.
      crossAxisAlignment: CrossAxisAlignment.start,
      // Alinea los hijos de esta columna al inicio (izquierda).
      children: [
        Text(
          // Widget para mostrar el título de la categoría.
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12),
        // Espacio vertical entre el título de la categoría y la lista de items.
        Container(
          // Contenedor para la lista horizontal de items.
          height: 180,
          child: ListView.builder(
            // 'ListView.builder' construye una lista desplazable de widgets bajo demanda,
            // lo que es eficiente para listas grandes.
            scrollDirection: Axis.horizontal,
            // Establece la dirección de desplazamiento de la lista a horizontal.
            itemCount: items.length,
            // El número de items en la lista es igual a la longitud de la lista 'items' pasada.
            itemBuilder: (context, index) {
              // Función que se llama para construir cada item de la lista. 'index' es la posición del item.
              return Container(
                // Contenedor para cada item individual dentro de la lista horizontal.
                width: 150,
                margin: EdgeInsets.only(right: 16),
                // Añade un margen a la derecha de cada item para separarlos.
                child: Column(
                  // Organiza los elementos dentro de cada item verticalmente (imagen y título).
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      // Permite que el contenedor de la imagen ocupe el espacio vertical disponible.
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color.fromARGB(255, 218, 215, 215),
                          ),
                        ),
                        child: ClipRRect(
                          // Recorta su hijo (la imagen) usando un rectángulo redondeado.
                          borderRadius: BorderRadius.circular(11),
                          child: Image.asset(
                            // Widget para mostrar una imagen desde los assets.
                            items[index]['image']!,
                            fit: BoxFit.cover,
                            // Ajusta la imagen para cubrir el contenedor manteniendo su relación de aspecto.
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              // Función que se llama si ocurre un error al cargar la imagen.
                              return Container(
                                color: Colors.grey.shade200,
                                child: Center(
                                  child: Icon(Icons.image_not_supported,
                                      color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Espacio vertical entre la imagen y el título del item.
                    Text(
                      // Widget para mostrar el título del item.
                      items[index]['title']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      // Limita el título a un máximo de 2 líneas.
                      overflow: TextOverflow.ellipsis,
                      // Si el texto excede el límite de líneas, muestra puntos suspensivos.
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
