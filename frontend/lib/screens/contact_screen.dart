import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para Clipboard
import 'package:flutter_svg/flutter_svg.dart'; // Necesario para SvgPicture

class ContactosEscolaresScreen extends StatefulWidget {
  @override
  _ContactosEscolaresScreenState createState() =>
      _ContactosEscolaresScreenState();
}

class _ContactosEscolaresScreenState extends State<ContactosEscolaresScreen> {
  // Lista de contactos (datos de ejemplo)
  final List<Map<String, String>> contactos = [
    {
      'name': 'Profesor Juan Pérez',
      'phone': '555-1234',
      'email': 'juan.perez@escuela.edu',
      'location': 'Edificio A, Oficina 101', // Ejemplo más largo
    },
    {
      'name': 'Administradora María López',
      'phone': '555-5678',
      'email': 'maria.lopez@escuela.edu',
      'location': 'Edificio F, Planta Baja',
    },
    {
      'name': 'Profesor Carlos García',
      'phone': '555-8765',
      'email': 'carlos.garcia@escuela.edu',
      'location': 'Edificio D, Cubículo 5',
    },
    {
      'name': 'Administrativa Ana Torres',
      'phone': '555-4321',
      'email': 'ana.torres@escuela.edu',
      'location': 'Edificio H, Ventanilla 3',
    },
    {
      'name': 'Biblioteca Central',
      'phone': '555-9900',
      'email': 'biblioteca.central@escuela.edu',
      'location': 'Edificio Principal, 2do Piso',
    },
  ];

  // Estado para almacenar el texto de búsqueda.
  String query = '';

  // --- Métodos Auxiliares (Adaptados de UserInfoScreen) ---

  /// Método auxiliar para construir un botón de copia [IconButton] con icono SVG.
  ///
  /// [textToCopy]: El texto que se copiará al portapapeles.
  /// [context]: El BuildContext para mostrar el SnackBar.
  Widget _buildCopyButton(BuildContext context, String textToCopy) {
    return IconButton(
      // Usa el icono SVG personalizado para copiar.
      icon: SvgPicture.asset(
        'assets/icons/copiar_icon.svg', // Asegúrate que esta ruta sea correcta.
        height: 22.0, // Ajusta tamaño si es necesario.
        width: 22.0,
        colorFilter: ColorFilter.mode(const Color.fromARGB(255, 45, 45, 45),
            BlendMode.srcIn), // Tono gris para el icono
      ),
      tooltip: 'Copiar', // Tooltip para accesibilidad.
      onPressed: () {
        // Copia el texto al portapapeles.
        Clipboard.setData(ClipboardData(text: textToCopy));
        // Muestra una notificación (SnackBar).
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$textToCopy" copiado al portapapeles'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      splashRadius: 20, // Radio del efecto ripple.
      padding: EdgeInsets.zero, // Sin padding extra.
      constraints: BoxConstraints(), // Tamaño compacto.
    );
  }

  /// Método auxiliar para construir una fila de información de contacto (etiqueta y valor).
  /// Incluye el estilo de texto solicitado y un botón para copiar el valor.
  ///
  /// [label]: El texto de la etiqueta (ej. "Teléfono").
  /// [value]: El valor correspondiente (ej. "555-1234").
  /// [context]: El BuildContext necesario para el botón de copia.
  Widget _buildContactInfoRow(
      BuildContext context, String label, String value) {
    // Si el valor está vacío o es nulo, no muestra la fila.
    if (value.isEmpty) {
      return SizedBox.shrink(); // Retorna un widget vacío.
    }
    return Padding(
      // Añade un padding vertical ligero a cada fila para separación.
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna para etiqueta y valor, expandida para ocupar espacio.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Etiqueta (Label) - En negrita (w700) y negro.
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700, // Negrita.
                    color: Colors.black, // Color negro.
                  ),
                ),
                SizedBox(height: 4), // Espacio entre etiqueta y valor.
                // Valor (Value) - En gris.
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400, // Peso normal.
                    color: Colors.grey[700], // Color gris oscuro.
                  ),
                  softWrap: true, // Permite que el texto largo se ajuste.
                ),
              ],
            ),
          ),
          // Botón para copiar el valor específico.
          _buildCopyButton(context, value),
        ],
      ),
    );
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    // Filtra la lista de contactos basándose en la consulta de búsqueda (query).
    // Compara en minúsculas para una búsqueda insensible a mayúsculas/minúsculas.
    final List<Map<String, String>> filteredContactos = contactos
        .where((contacto) =>
            contacto['name']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    // Retorna el contenido principal de la pantalla.
    return Container(
      color: Color.fromARGB(255, 250, 250, 250), // Color de fondo gris claro.
      padding: EdgeInsets.all(16.0), // Padding general.
      child: Column(
        children: [
          // --- Barra de Búsqueda ---
          TextField(
            onChanged: (value) {
              // Actualiza el estado 'query' cada vez que el texto cambia.
              setState(() {
                query = value;
              });
            },
            textAlign:
                TextAlign.start, // Centra el texto de entrada y el hintText.
            decoration: InputDecoration(
                // Texto de sugerencia que aparece cuando el campo está vacío.
                hintText: 'Buscar',
                hintStyle:
                    TextStyle(color: Colors.grey[500]), // Estilo del hintText.
                // Icono personalizado SVG a la izquierda.
                prefixIcon: Padding(
                  // Ajusta el padding para centrar el icono verticalmente.
                  padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 12.0,
                      top: 10.0,
                      bottom: 10.0), // Modificado top y bottom
                  child: SvgPicture.asset(
                    'assets/icons/search-contacts_icon.svg', // Ruta al icono de búsqueda. Asegúrate que exista.
                    height: 20, // Tamaño del icono.
                    width: 20,
                    colorFilter: ColorFilter.mode(
                        Colors.grey[600]!, BlendMode.srcIn), // Color del icono.
                  ),
                ),

                // Estilos del borde del TextField.
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide
                      .none, // Sin borde por defecto (usaremos fillColor).
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(
                      color: Colors.grey[500]!,
                      width: 1.0), // Borde gris sutil cuando no tiene foco.
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  // Borde más grueso y de color oscuro cuando el campo tiene foco.
                  borderSide: BorderSide(
                    color: Color(0xFF14213D), // Azul oscuro (puedes ajustar).
                    width: 1.5,
                  ),
                ),
                filled: true, // Indica que el fondo debe rellenarse.
                fillColor: Colors.white, // Fondo blanco para el TextField.
                contentPadding: EdgeInsets.symmetric(
                    vertical:
                        14.0) // Ajusta el padding vertical si es necesario
                ),
          ),
          SizedBox(
              height: 16), // Espacio entre la barra de búsqueda y la lista.

          // --- Lista de Contactos ---
          Expanded(
              // Expanded permite que la ListView ocupe el espacio vertical restante.
              child: ListView.builder(
            // Usa ListView.builder para eficiencia si la lista es larga.
            itemCount:
                filteredContactos.length, // Número de contactos filtrados.
            itemBuilder: (context, index) {
              // Construye una tarjeta para cada contacto filtrado.
              final contacto = filteredContactos[index];
              return _buildContactCard(
                context:
                    context, // Pasa el context necesario para los botones de copia.
                name: contacto['name']!,
                phone: contacto['phone']!,
                email: contacto['email']!,
                location: contacto['location']!,
              );
            },
          )),
        ],
      ),
    );
  }

  /// Construye la tarjeta individual para cada contacto.
  /// Adopta la estructura de la tarjeta de UserInfoScreen.
  Widget _buildContactCard({
    required BuildContext context, // Necesario para los helpers de copia.
    required String name,
    required String phone,
    required String email,
    required String location,
  }) {
    return Card(
      color: Colors.white, // Fondo blanco de la tarjeta.
      elevation: 2.5, // Sombra ligera.
      margin: EdgeInsets.only(bottom: 16.0), // Margen inferior entre tarjetas.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Bordes redondeados.
        // Opcional: añadir un borde ligero si se desea.
        // side: BorderSide(color: Colors.grey[300]!, width: 0.5),
      ),
      child: Padding(
        // Padding interno del contenido de la tarjeta.
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Cabecera de la Tarjeta: Nombre y Botón "Copiar todo" ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment
                  .start, // Alinea el botón con la parte superior del nombre.
              children: [
                // Nombre del contacto (ocupa el espacio disponible).
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Botón para copiar toda la información del contacto.
                TextButton.icon(
                  onPressed: () {
                    // Construye la cadena con todos los datos del contacto.
                    final allInfo = """
Nombre: $name
Teléfono: $phone
Correo: $email
Ubicación: $location
"""
                        .trim();
                    // Copia al portapapeles.
                    Clipboard.setData(ClipboardData(text: allInfo));
                    // Muestra notificación.
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Contacto copiado al portapapeles'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  // Icono SVG de copiar.
                  icon: SvgPicture.asset(
                    'assets/icons/copiar_icon.svg',
                    height:
                        18.0, // Icono ligeramente más pequeño para este botón.
                    width: 18.0,
                    colorFilter:
                        ColorFilter.mode(Colors.black, BlendMode.srcIn),
                  ),
                  // Texto del botón.
                  label: Text(
                    'Copiar todo',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12), // Texto más pequeño.
                  ),
                  // Estilo del botón para hacerlo compacto.
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize
                        .shrinkWrap, // Reduce el área de toque.
                  ),
                ),
              ],
            ),

            Divider(height: 16.0), // Línea divisora después de la cabecera.

            // --- Filas de Información de Contacto ---
            // Llama al método auxiliar para cada dato, pasando el contexto.
            _buildContactInfoRow(context, 'Teléfono', phone),
            _buildContactInfoRow(context, 'Correo', email),
            _buildContactInfoRow(context, 'Ubicación', location),
            // Añade más filas si tienes otros datos (ej. 'Página Web' como en la imagen)
            // _buildContactInfoRow(context, 'Página Web', contacto['website'] ?? ''),
          ],
        ),
      ),
    );
  }
}
