# Guion de demo · Megafonito local

Este guion asume que el servidor ya está instalado (`cd server && bun install`).

## Antes de salir de casa

- [ ] Instalar dependencias del servidor: `cd server && bun install`.
- [ ] Compilar la app una vez:
      `cd frontend && flutter build apk --release`
      El APK queda en `frontend/build/app/outputs/flutter-apk/app-release.apk`.
- [ ] Instalar el APK en la tablet y en el teléfono (desde la raíz del repo):
      `adb -s <dispositivo> install -r frontend/build/app/outputs/flutter-apk/app-release.apk`
- [ ] Probar el guion completo en casa.
- [ ] Llevar el cable USB o tener `adb` inalámbrico disponible por si hay que
      reinstalar.
- [ ] Llevar cargadores.

## Montaje en el salón

1. Conecta la laptop al Wi-Fi de la escuela.
2. Activa el hotspot de Windows y comparte el Wi-Fi.
3. Conecta la tablet y el teléfono al hotspot.
4. Abre una terminal:

```powershell
cd Megafonito\server
bun run start
```

5. Abre `http://localhost:8787` en el navegador de la laptop.
6. Deja la landing visible: ahí están los QR y las cuentas.
7. Escanea el QR **Hotspot de Windows** desde la app de la tablet y del teléfono.
   - Si la cámara falla, usa **Escribir URL** con la dirección que aparece en la
     landing.

## Guion principal

1. **Tablet:** inicia sesión como `admin` / `admin123`.
2. **Teléfono:** inicia sesión como `student1` / `1234`.
3. **Tablet:** abre **Anuncio nuevo**, elige:
   - Para: **Ingeniería en Sistemas Computacionales**
   - Categoría: **Eventos**
   - Título: “Práctica de laboratorio de Sistemas”
   - Contenido: el texto que quieras.
4. Publica. El teléfono debe mostrar el anuncio **sin refrescar**.
5. **Teléfono:** cierra sesión y entra como `student2` / `1234`.
   - La bandeja debe quedar sin el anuncio de Sistemas.
6. **Tablet:** publica otro anuncio para **Ingeniería Mecánica**.
7. **Teléfono (student2):** debe aparecer al instante.
8. **Teléfono:** cierra sesión y vuelve a `student1`.
   - Solo debe ver el anuncio de Sistemas.

## Puntos que conviene decir en voz alta

- La app no usa Supabase, Firebase ni internet: todo vive en SQLite dentro de la
  laptop.
- El QR evita escribir IPs; la URL queda guardada en cada dispositivo.
- El WebSocket entrega los anuncios solo a los alumnos del grupo destino.
- El servidor imprime cada conexión y cada anuncio en la terminal, por si algo
  no se ve en pantalla.

## Plan B

- **Un dispositivo no conecta:** revisa firewall, mismo hotspot y que el QR sea
  el de “Hotspot de Windows”. También puedes escribir la URL manualmente.
- **Se reinició el servidor:** las sesiones se pierden; vuelve a iniciar sesión.
- **Quieres empezar limpio:** botón **Reiniciar datos demo** en la landing.
- **El QR de la terminal no se lee:** usa el QR grande de la landing.
- **La app muestra “Sin respuesta”:** abre `/api/health` en la laptop; si responde,
  vuelve a escanear desde la app.

## Después de la demo

- Detén el servidor con `Ctrl+C`.
- Si quieres dejar la base limpia para la próxima:
  `cd server && bun run reset`.
