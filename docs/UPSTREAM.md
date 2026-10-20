# Upstream, snapshot y atribución

Este repositorio no es un fork limpio de un único proyecto: es una instantánea
de una instalación de escritorio que empezó en Caelestia, pasó por la base
MiDnight y acumuló cambios propios.

## Orígenes

- Proyecto original: <https://github.com/caelestia-dots/caelestia>
- Base del árbol C++/QML usado para el plugin:
  <https://github.com/dim-ghub/midnight-shell>
  - rama: `main`
  - commit base: `1995613` (`fonts: fix glyph mismatch race condition between
    system and bundled fonts`)
  - el árbol de trabajo tenía 15 archivos modificados sin commit; esos cambios
    se incluyen en esta instantánea.
- Quickshell: <https://github.com/quickshell-mirror/quickshell>

## Qué se copió de dónde

| Parte | Origen |
| --- | --- |
| `shell/` | `~/.local/share/caelestia-es/shell`, el shell que estaba ejecutándose |
| `plugin/` | árbol de trabajo de `midnight-shell/plugin` |
| `scripts/trs.fish` | `midnight-shell/scripts/trs.fish` |
| `local/python-site/` | `~/.local/lib/python3.14/site-packages/` |
| `local/caelestia/schemes/` | `~/.local/share/caelestia/schemes/` |
| `config/` | `~/.config/caelestia` y `~/.config/hypr` |

El shell QML y el plugin C++ no vienen del mismo *commit* exacto: el shell live
incluye la traducción española y servicios añadidos que no están en el árbol de
fuente, mientras que el plugin se tomó del árbol de fuente que se estaba
usando para compilar. Juntos forman la configuración que funcionaba en el
equipo.

## Qué no se incluye

- El historial `.git` del fork original (esta carpeta puede tener su propio
  repositorio).
- Binarios compilados (`*.so`) y directorios de build; se generan con CMake.
- El paquete Python del sistema; el parche vive en el *user site*.
- La fuente propietaria Spotify Mix UI.
- Recursos de Shimeji y otras aplicaciones externas.
- Credenciales, tokens o direcciones MAC personales.

## Licencia

El código original y este árbol se distribuyen bajo GPL-3.0. Consulta
[`../LICENSE`](../LICENSE). Los assets de terceros conservan sus propias
licencias; revisa `shell/assets/` antes de redistribuirlos.
