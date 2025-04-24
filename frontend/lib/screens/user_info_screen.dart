import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para Clipboard
import 'package:flutter_svg/flutter_svg.dart'; // Necesario para SvgPicture
import 'login_screen.dart'; // Necesario para la navegación al cerrar sesión

/// Pantalla que muestra la información del usuario actual.
///
/// Presenta datos como nombre, email, número de control, carrera y semestre
/// en una tarjeta, con opciones para copiar cada dato individualmente o todos juntos.
/// También incluye una sección para acceder al horario y un botón para cerrar sesión.
class UserInfoScreen extends StatelessWidget {
  // --- Datos del Usuario (Hardcoded) ---
  // En una aplicación real, estos datos probablemente vendrían de un servicio de autenticación,
  // una base de datos o un gestor de estado (provider, bloc, etc.) después del login.
  final String name = "Karol Rubén Quiroz Mora";
  final String email = "qumk051105@itsuruapan.edu.mx";
  final String controlNumber = "23040061";
  final String career = "Ing. en Sistemas Computacionales";
  final String semester = "4";

  /// Método auxiliar para construir un botón de copia [IconButton].
  ///
  /// [textToCopy]: El texto que se copiará al portapapeles al presionar el botón.
  Widget _buildCopyButton(BuildContext context, String textToCopy) {
    // Añadido context para ScaffoldMessenger
    return IconButton(
      icon: SvgPicture.asset(
        'assets/icons/copiar_icon.svg',
        height: 24.0,
        width: 24.0,
      ), // Icono de copiar.
      onPressed: () {
        // Usa el servicio Clipboard para copiar el texto proporcionado.
        Clipboard.setData(ClipboardData(text: textToCopy));
        // --- Notificación Opcional ---
        // Muestra un mensaje breve confirmando que el texto fue copiado.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$textToCopy" copiado al portapapeles'),
            duration: Duration(seconds: 2), // Duración corta del mensaje.
          ),
        );
      },
      splashRadius: 20, // Radio del efecto "ripple" al presionar.
      padding: EdgeInsets.zero, // Sin padding extra alrededor del icono.
      constraints:
          BoxConstraints(), // Restricciones mínimas para un tamaño compacto.
    );
  }

  /// Método auxiliar para construir una fila de información (etiqueta y valor)
  /// dentro de la tarjeta de usuario, incluyendo un botón para copiar el valor.
  ///
  /// [label]: El texto de la etiqueta (ej. "Nombre", "Email").
  /// [value]: El valor correspondiente a la etiqueta.
  /// [context]: El BuildContext necesario para el botón de copia.
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    // Añadido context
    return Row(
      mainAxisAlignment: MainAxisAlignment
          .spaceBetween, // Espacio entre la columna de texto y el botón.
      crossAxisAlignment: CrossAxisAlignment
          .start, // Alinea ambos elementos verticalmente al inicio.
      children: [
        // Columna para la etiqueta y el valor.
        Expanded(
          // Expanded permite que la columna ocupe el espacio necesario y el texto se ajuste.
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Alinea textos a la izquierda.
            children: [
              // Etiqueta (Label) - Ahora en negrita y negro.
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  // fontWeight: FontWeight.bold, // Aplicando negrita.
                  fontWeight: FontWeight.w700, // Equivalente a w700.
                  color: Colors.black, // Color negro para la etiqueta.
                ),
              ),
              SizedBox(
                  height:
                      4), // Pequeño espacio vertical entre etiqueta y valor.
              // Valor (Value) - Ahora en gris.
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w400, // Peso normal o semi-bold para el valor.
                  color: Colors.grey[700], // Color gris oscuro para el valor.
                ),
                // softWrap: true, // Permite que el texto largo (como carrera) se ajuste en varias líneas.
              ),
            ],
          ),
        ),
        // Botón para copiar el valor específico de esta fila.
        _buildCopyButton(context, value), // Pasa el context al helper.
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // El método build recibe el context.
    // --- Estructura Principal de la Pantalla ---
    return Container(
      // Color de fondo general de la pantalla (un gris muy claro).
      color: Color.fromARGB(255, 250, 250, 250),
      // Padding general para evitar que el contenido toque los bordes de la pantalla.
      padding: EdgeInsets.all(16.0),
      // SingleChildScrollView permite el desplazamiento si el contenido excede la altura.
      child: SingleChildScrollView(
        child: Column(
          // Organiza los elementos principales verticalmente.
          crossAxisAlignment:
              CrossAxisAlignment.start, // Alinea los hijos a la izquierda.
          children: [
            // --- Tarjeta 1: Información de Usuario ---
            Card(
              color: Colors.white, // Fondo blanco para la tarjeta.
              elevation: 2.5, // Sombra ligera para destacar la tarjeta.
              margin: EdgeInsets.only(
                  bottom:
                      16.0), // Margen inferior para separarla del siguiente elemento.
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Bordes redondeados.
              ),
              child: Padding(
                // Padding interno para el contenido de la tarjeta.
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Cabecera de la Tarjeta: Título y Botón "Copiar todo" ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Título a la izquierda, botón a la derecha.
                      children: [
                        // Título de la tarjeta.
                        Text(
                          'Información de usuario',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Botón para copiar toda la información del usuario.
                        TextButton.icon(
                          onPressed: () {
                            // Construye la cadena con toda la información.
                            final allInfo = """
Nombre: $name
No. control: $controlNumber
Carrera: $career
Semestre: $semester
Email: $email
"""
                                .trim(); // trim() elimina espacios extra al inicio/final.
                            // Copia la cadena completa al portapapeles.
                            Clipboard.setData(ClipboardData(text: allInfo));
                            // Muestra una notificación de confirmación.
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Información copiada al portapapeles'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: SvgPicture.asset(
                            'assets/icons/copiar_icon.svg',
                            height: 24.0,
                            width: 24.0,
                          ), // Icono de copiar, ahora negro.
                          label: Text('Copiar todo',
                              style: TextStyle(
                                  color: Colors
                                      .black)), // Texto del botón, ahora negro.
                          style: TextButton.styleFrom(
                            // Estilo del botón: color del texto/icono y padding mínimo.
                            foregroundColor: Colors
                                .black, // Aplica color negro a icono y texto.
                            padding: EdgeInsets.symmetric(
                                horizontal: 8), // Padding horizontal.
                            minimumSize: Size(
                                0, 0), // Tamaño mínimo para compactar el botón.
                            // splashFactory: NoSplash.splashFactory, // Opcional: quitar efecto ripple
                          ),
                        ),
                      ],
                    ),

                    Divider(), // Línea divisora horizontal.

                    // --- Detalles del Usuario (Filas de Información) ---
                    // Llama al método auxiliar _buildInfoRow para cada dato.
                    _buildInfoRow(context, 'Nombre', name), // Pasa el context.
                    SizedBox(height: 12), // Espacio vertical entre filas.
                    _buildInfoRow(context, 'No. control',
                        controlNumber), // Pasa el context.
                    SizedBox(height: 12),
                    _buildInfoRow(
                        context, 'Carrera', career), // Pasa el context.
                    SizedBox(height: 12),
                    _buildInfoRow(
                        context, 'Semestre', semester), // Pasa el context.
                    SizedBox(height: 12),
                    // --- Fila de Email Añadida ---
                    _buildInfoRow(context, 'Email', email), // Pasa el context.
                  ],
                ),
              ),
            ), // Fin de la Card de Información de Usuario

            // --- Sección del Horario ---
            Padding(
              // Padding para el título de la sección "Tu horario".
              padding: EdgeInsets.only(
                  left: 8.0,
                  bottom: 8.0,
                  top: 16.0), // Añadido padding superior
              child: Text(
                'Tu horario',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // --- Tarjeta 2: Acceso al Horario ---
            InkWell(
              // Hace que toda la tarjeta sea clickeable.
              onTap: () {
                // TODO: Implementar la navegación a la pantalla del horario.
                print('Navegar a la pantalla de horario');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Navegación a Horario no implementada')),
                );
              },
              // Aplica bordes redondeados al efecto InkWell.
              borderRadius: BorderRadius.circular(8.0),
              child: Card(
                color: Colors.white,
                elevation: 2.5,
                margin:
                    EdgeInsets.only(bottom: 16.0), // Margen inferior estándar.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  // Contenedor para darle tamaño y padding a la tarjeta del horario.
                  width: double.infinity, // Ocupa todo el ancho disponible.
                  height: 120, // Altura fija para esta tarjeta.
                  padding: EdgeInsets.all(16.0), // Padding interno.
                  child: Center(
                    // Centra el icono SVG dentro del contenedor.
                    child: SvgPicture.asset(
                      'assets/icons/horario_icon.svg', // Ruta al archivo SVG del icono.
                      height: 60, // Tamaño del icono.
                      width: 60,
                      // PlaceholderBuilder es útil si el SVG tarda en cargar o falla.
                      // placeholderBuilder: (BuildContext context) => Container(
                      //   padding: const EdgeInsets.all(30.0),
                      //   child: const CircularProgressIndicator(),
                      // ),
                    ),
                  ),
                ),
              ),
            ), // Fin de la Card de Horario

            // --- Botón de Cerrar Sesión ---
            Center(
              // Centra el botón horizontalmente.
              child: Padding(
                // Padding vertical alrededor del botón.
                padding: EdgeInsets.symmetric(
                    vertical: 24.0), // Aumentado el padding vertical
                child: ElevatedButton(
                  onPressed: () {
                    // --- Lógica de Logout ---
                    // Navega a LoginScreen y elimina todas las rutas anteriores del stack.
                    // Esto asegura que el usuario no pueda volver atrás a la pantalla de info.
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (Route<dynamic> route) =>
                          false, // Condición que siempre es falsa para eliminar todas las rutas.
                    );
                    // TODO: Aquí también deberías limpiar cualquier dato de sesión almacenado
                    // (ej. token, datos de usuario en SharedPreferences o gestor de estado).
                  },
                  // --- Estilo del Botón (Blanco y Negro) ---
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Fondo negro.
                    foregroundColor:
                        Colors.white, // Texto (y icono si hubiera) blanco.
                    padding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24), // Padding interno del botón.
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // Bordes redondeados.
                    ),
                    elevation: 4.0, // Sombra ligera para el botón.
                  ),
                  child: Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold), // Texto en negrita.
                  ),
                ),
              ),
            ), // Fin del Botón de Cerrar Sesión
          ],
        ),
      ),
    );
  }
}
