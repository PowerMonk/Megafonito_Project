# Megafonito · Servidor de demostración

Servidor local para la demo académica. Corre en la laptop, guarda todo en SQLite y
entrega los anuncios en tiempo real por WebSocket. No usa Supabase, Firebase ni
ningún servicio en la nube.

- **Runtime:** Bun
- **Base de datos:** SQLite (`bun:sqlite`)
- **Tiempo real:** WebSocket nativo de Bun
- **Landing / QR:** Astro estático, servido por el mismo proceso
- **Puerto por defecto:** `8787`

---

## Requisitos

- [Bun](https://bun.sh/) 1.3 o superior
- Windows, macOS o Linux
- La laptop y los dispositivos en la misma red (ideal: hotspot de la laptop)

---

## Arranque rápido

```bash
cd server
bun install
bun run start
```

`bun run start` compila la landing de Astro y luego levanta el servidor.

Al iniciar verás:

- todas las direcciones LAN detectadas
- un QR en la terminal para la dirección principal
- las cuentas demo
- la ruta de la base de datos SQLite

Abre la landing en la laptop:

```text
http://localhost:8787
```

Ahí hay un QR grande para cada dirección LAN y el botón para reiniciar los datos
de la demo.

---

## Hotspot de Windows (recomendado para la escuela)

1. Conecta la laptop al Wi-Fi de la escuela.
2. Activa **Configuración → Red e Internet → Zona con cobertura inalámbrica móvil**.
3. Comparte la conexión Wi-Fi.
4. Conecta la tablet y el teléfono al hotspot.
5. En la landing, usa el QR marcado como **Hotspot de Windows** (normalmente
   `192.168.137.1`).

Si el hotspot no aparece, el servidor también imprime la IP de Wi-Fi normal.
La app valida la conexión antes de guardar la URL, así que un QR equivocado
muestra un error claro en lugar de fallar en silencio.

### Firewall de Windows

Acepta el aviso de Windows Firewall cuando Bun pida acceso a redes privadas.
Si no aparece o bloqueaste el puerto, ejecuta PowerShell como administrador:

```powershell
New-NetFirewallRule -DisplayName "Megafonito demo" -Direction Inbound -LocalPort 8787 -Protocol TCP -Action Allow
```

---

## Cuentas demo

| Usuario | Contraseña | Rol | Grupo |
| --- | --- | --- | --- |
| `admin` | `admin123` | admin | Coordinación Académica |
| `student1` | `1234` | alumno | Ingeniería en Sistemas Computacionales |
| `student2` | `1234` | alumno | Ingeniería Mecánica |

La app tiene botones de acceso rápido en la pantalla de inicio de sesión.

---

## Guion de la demo

1. Enciende el hotspot y conecta la tablet y el teléfono.
2. Ejecuta `bun run start` en la laptop.
3. Abre `http://localhost:8787` y escanea el QR principal desde la app de cada
   dispositivo (**Inicio de sesión → Escanear QR**).
4. En la tablet entra como `admin`.
5. En el teléfono entra como `student1`.
6. En la tablet publica un anuncio con **Para: Ingeniería en Sistemas**.
7. El teléfono lo muestra al instante, sin refrescar.
8. En el teléfono cierra sesión y entra como `student2`.
9. El anuncio de Sistemas no aparece.
10. En la tablet publica otro anuncio con **Para: Ingeniería Mecánica**.
11. El teléfono lo muestra al instante.
12. Vuelve a entrar como `student1`: solo ve el anuncio de Sistemas.

### Reiniciar para el siguiente ensayo

- Desde la landing: botón **Reiniciar datos demo**.
- O desde la terminal, con el servidor detenido:

```bash
bun run reset
```

El reinicio borra anuncios y conserva las cuentas.

---

## Variables de entorno

| Variable | Default | Uso |
| --- | --- | --- |
| `PORT` | `8787` | Puerto HTTP/WebSocket |
| `LAN_IP` | autodetectada | Fuerza la IP que se muestra en el QR principal |
| `DB_PATH` | `server/data/megafonito.db` | Ruta del archivo SQLite |

Ejemplo:

```powershell
$env:LAN_IP = "192.168.137.1"
bun run start
```

---

## API

Todas las rutas devuelven JSON. Las rutas protegidas usan
`Authorization: Bearer <token>`.

| Método | Ruta | Acceso | Descripción |
| --- | --- | --- | --- |
| GET | `/api/health` | público | Comprobar que el servidor responde |
| GET | `/api/server-info` | público | URLs LAN, QR y cuentas demo |
| POST | `/api/login` | público | Iniciar sesión |
| POST | `/api/logout` | token | Cerrar sesión |
| GET | `/api/me` | token | Usuario actual |
| GET | `/api/groups` | token | Grupos de alumnos |
| GET | `/api/announcements` | token | Listado filtrado por grupo |
| POST | `/api/announcements` | admin | Crear y emitir por WebSocket |
| PUT | `/api/announcements/:id` | admin | Editar y emitir |
| DELETE | `/api/announcements/:id` | admin | Eliminar y emitir |
| POST | `/api/demo/reset` | público | Borrar anuncios para el ensayo |
| WS | `/ws?token=...` | token | Eventos en tiempo real |

Eventos WebSocket: `hello`, `announcement:new`, `announcement:updated`,
`announcement:deleted`, `demo:reset`.

---

## Pruebas

```bash
cd server
bun test
```

Las pruebas cubren login, permisos, filtrado por grupo, CRUD y entrega selectiva
por WebSocket.

---

## Problemas comunes

**El teléfono no conecta**

- Verifica que esté en el mismo hotspot.
- Revisa el firewall de Windows.
- Usa el QR marcado como **Hotspot de Windows**, no el de un adaptador virtual.
- Si cambiaron de red, vuelve a escanear el QR.

**El QR de la terminal se ve raro**

- Es normal en algunas consolas de Windows. Usa el QR grande de la landing
  (`http://localhost:8787`) o escribe la URL manualmente en la app.

**La app dice “Sin respuesta del servidor”**

- Abre `/api/health` desde el navegador de la laptop.
- Comprueba que el servidor siga corriendo.
- Si el servidor se reinició, vuelve a iniciar sesión en la app.

**Cambió la IP**

- La app guarda la última URL; si ya no responde, entra a **Cuenta → Servidor**
  y vuelve a escanear el QR.

---

## Notas

- La autenticación es deliberadamente simple para la demo: contraseñas hasheadas
  y tokens de sesión opacos, sin JWT.
- Los archivos adjuntos quedaron fuera del alcance de esta demo.
- El backend anterior en `backend/` (Deno + PostgreSQL) no se usa.
