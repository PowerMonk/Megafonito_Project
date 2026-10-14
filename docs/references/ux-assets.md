# UX reference inventory

Tracked design references are in `UX/UI/`:

| Asset | Name suggests |
| --- | --- |
| `Pantallas_actuales.pdf` | A screen set describing a previous/current UI snapshot. |
| `Pantallas_home.pdf` | Home/feed concepts. |
| `Pantallas_creacion_anuncio.pdf` | Notice-creation concepts. |
| `Pantallas_oportunidades.pdf` | Opportunity screens. |
| `Pantallas_cuenta.pdf` | Account/profile screens. |
| `pantallas_soporte-cuenta-contactos.pdf` | Support, account, and contact concepts. |
| `pantalla_soporte.pdf` | Support screen concept. |
| `Legacy_Revamp/Pantallas.pdf` | Older redesign concepts. |
| `Legacy_Revamp/Pantallas.png` | Raster counterpart/preview of the older redesign. |

## How this refresh treats them

The user confirmed that the screens present in the Flutter code are the active product baseline. These PDFs are **historical visual context only**, not authority for destinations, routes, or current interactions. The refresh preserves the implemented five destinations—Inicio, Contactos, Oportunidades, Procesos, Cuenta—and the separate Support app-bar route. It does not rearrange navigation to match a PDF.

PDFs may be consulted for brand/product inspiration if useful, but visual decisions must be checked against running Flutter screens. Documentation should record any notable mismatch rather than silently reconciling a design image with the code.
