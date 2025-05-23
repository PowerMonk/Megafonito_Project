import 'package:flutter/material.dart';
import '../widgets/opportunities_detail.dart'; // Importa el widget OpportunitiesDetail

class OpportunityContentScreen extends StatefulWidget {
  // Define un StatefulWidget llamado OpportunityContentScreen.
  // Los StatefulWidget son widgets cuyo estado puede cambiar dinámicamente.
  final String title;

  // Constructor para OpportunityContentScreen que requiere un título.
  // 'Key? key' es una convención para permitir que Flutter identifique de forma única los widgets.
  const OpportunityContentScreen({Key? key, required this.title})
      : super(key: key);

  @override
  _OpportunityContentScreenState createState() =>
      _OpportunityContentScreenState();
  // Sobrescribe el método createState() para crear la instancia del estado mutable
  // asociado a este widget.
}

class _OpportunityContentScreenState extends State<OpportunityContentScreen> {
  // Define la clase de estado _OpportunityContentScreenState que extiende de
  // State<OpportunityContentScreen>. Esta clase mantiene el estado de nuestro widget.

  // Datos de ejemplo para cada categoría - en una aplicación real, estos datos
  // provendrían de una API o una base de datos.
  final List<Map<String, String>> becasItems = List.generate(
    10,
    (index) => {
      'image': index % 2 == 0
          ? 'assets/test_images/Beca_movilidad.jpeg'
          : 'assets/test_images/Beca_santander.png',
      'title': 'Beca ${index + 1}',
    },
  );
  // Crea una lista de 10 mapas para simular elementos de becas. Cada mapa tiene
  // una clave 'image' con la ruta de una imagen y una clave 'title' con un título.

  final List<Map<String, String>> cursosItems = List.generate(
    8,
    (index) => {
      'image': index % 2 == 0
          ? 'assets/test_images/Python_logo.png'
          : 'assets/test_images/Cisco_logo.png',
      'title': 'Curso ${index + 1}',
    },
  );
  // Similar a becasItems, pero crea una lista de 8 elementos para cursos.

  final List<Map<String, String>> trabajosItems = List.generate(
    12,
    (index) => {
      'image': index % 2 == 0
          ? 'assets/test_images/BMW_logo.png'
          : 'assets/test_images/Supabase_logo.png',
      'title': 'Trabajo ${index + 1}',
    },
  );
  // Similar a las anteriores, pero crea una lista de 12 elementos para trabajos.

  @override
  Widget build(BuildContext context) {
    // Sobrescribe el método build() que describe la parte de la interfaz de usuario
    // representada por este widget. Se llama cada vez que es necesario reconstruir el widget.
    return Scaffold(
      // Scaffold proporciona la estructura visual básica para las pantallas de Material Design,
      // como AppBar, body, FloatingActionButton, etc.
      appBar: AppBar(
        // AppBar es una barra de herramientas que se muestra en la parte superior de la pantalla.
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        // Muestra el título de la pantalla, que se pasa a través del constructor del widget.
        // El estilo del texto se establece para que sea blanco.
        backgroundColor: Colors.black,
        // Establece el color de fondo del AppBar a negro.
        iconTheme: IconThemeData(color: Colors.white),
        // Define el estilo de los iconos dentro del AppBar para que sean blancos.
      ),
      body: Container(
        // Container es un widget de propósito general que puede contener otros widgets
        // y tiene propiedades para el padding, margenes, color de fondo, etc.
        color: Color.fromARGB(255, 250, 250, 250),
        // Establece el color de fondo del Container a blanco.
        child: Column(
          // Column organiza a sus hijos en una dirección vertical.
          children: [
            Expanded(
              // Expanded hace que un widget hijo de un Row o Column se expanda
              // para llenar el espacio disponible.
              child: SingleChildScrollView(
                // SingleChildScrollView permite desplazar su contenido si este excede
                // el tamaño de la pantalla.
                child: Padding(
                  // Padding añade un espacio alrededor de su widget hijo.
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    // Otra Column anidada para organizar las secciones de categorías verticalmente.
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // Alinea los hijos de esta columna al inicio (izquierda).
                    children: [
                      _buildCategorySection('Becas', becasItems, 'beca'),
                      // Llama al método _buildCategorySection para construir la sección de becas.
                      SizedBox(height: 24),
                      // SizedBox crea un espacio con una altura o ancho específico.
                      _buildCategorySection(
                          'Cursos y Certificaciones', cursosItems, 'curso'),
                      // Llama al método _buildCategorySection para construir la sección de cursos.
                      SizedBox(height: 24),
                      _buildCategorySection(
                          'Bolsa de Trabajo', trabajosItems, 'trabajo'),
                      // Llama al método _buildCategorySection para construir la sección de bolsa de trabajo.
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

  Widget _buildCategorySection(
      String title, List<Map<String, String>> items, String type) {
    // Método para construir una sección individual de categoría (Becas, Cursos, Trabajos).
    // Toma un título, una lista de items y un tipo como argumentos.
    return Column(
      // Column organiza a sus hijos en una dirección vertical.
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
            // ListView.builder construye una lista desplazable de widgets bajo demanda,
            // lo que es eficiente para listas grandes.
            scrollDirection: Axis.horizontal,
            // Establece la dirección de desplazamiento de la lista a horizontal.
            itemCount: items.length,
            // El número de items en la lista es igual a la longitud de la lista 'items' pasada.
            itemBuilder: (context, index) {
              // Función que se llama para construir cada item de la lista. 'index' es la posición del item.
              return GestureDetector(
                // GestureDetector detecta gestos táctiles. Aquí, se usa para hacer que cada item sea clickeable.
                onTap: () {
                  // Función que se llama cuando se toca un item de la lista.
                  // Crea el objeto de datos enriquecido para el modal
                  Map<String, dynamic> opportunityData = {
                    'title': items[index]['title'],
                    'author_name': 'Instituto Educativo',
                    'content': 'Esta es una descripción detallada sobre ${items[index]['title']}. '
                        'Aquí encontrarás toda la información relevante sobre esta oportunidad '
                        'incluyendo requisitos, beneficios y fechas importantes.',
                    'has_attachment': true,
                    'attachment_url': items[index]['image'],
                    'expiry_date': '30 jun 2025',
                  };

                  // Muestra el modal de detalles
                  OpportunitiesDetail.show(context, opportunityData);
                  // Llama al método estático show del widget OpportunitiesDetail para mostrar el modal.
                  // Pasa el contexto actual y el mapa de datos de la oportunidad seleccionada.
                },
                child: Container(
                  // Contenedor para cada item individual dentro de la lista horizontal.
                  width: 150,
                  margin: EdgeInsets.only(right: 16),
                  // Añade un margen a la derecha de cada item para separarlos.
                  child: Column(
                    // Column organiza los elementos dentro de cada item verticalmente (imagen y título).
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
                            // ClipRRect recorta su hijo (la imagen) usando un rectángulo redondeado.
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
