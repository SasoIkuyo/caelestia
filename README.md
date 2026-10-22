<div align="center">

# Caelestia ES

**Mi versión de Caelestia: escritorio en español, música y personalización.**

Shell basado en Quickshell, con letras sincronizadas, fuentes configurables y ocho esquemas de color adicionales.

[Instalación](#instalación) · [Características](#características) · [Documentación](#documentación) · [Créditos](#créditos-y-licencia)

</div>

---

Caelestia ES reúne las personalizaciones de mi escritorio para compartirlas con
la comunidad. Parte de los dotfiles de
[Caelestia](https://github.com/caelestia-dots/caelestia) e incorpora el shell y
el plugin derivados de [MiDnight](https://github.com/dim-ghub/midnight-shell).

Esta es una versión comunitaria independiente. El fork conserva los dotfiles
originales en `main`; **esta versión vive en `personal/caelestia-es`**.
El origen de los componentes se detalla en [UPSTREAM.md](docs/UPSTREAM.md).

## Características

| Área | Qué incluye |
| --- | --- |
| Interfaz | Selector de Español y catálogo nativo, además de la traducción local QML. |
| Audio | Ocultar y recuperar dispositivos de reproducción y micrófonos. |
| Ubicación | Buscar ciudades y guardar la ubicación para el clima. |
| Actualizaciones | Vista previa con iconos, progreso y autenticación integrada (experimental, Arch/paru). |
| Música | Letras sincronizadas, selector de proveedor e indicadores de sincronización. |
| Reproductores | Selección MPRIS con prioridad manual y detección del reproductor en reproducción. |
| Tipografía | Selección de fuentes para reloj y letras; la fuente de las letras se conserva entre reinicios. |
| Colores | Ocho esquemas adicionales, versiones claras y oscuras y variantes Material. |
| QuickShare | Cambios para recepción de varios archivos, mantenimiento de conexión y gestión del historial. |
| Instalación | Plugin compilado desde fuente e instalación en el directorio del usuario. |

Los cambios recientes y sus límites se describen en [DESKTOP-IMPROVEMENTS.md](docs/DESKTOP-IMPROVEMENTS.md).

### Letras de canciones

Los proveedores se consultan en este orden:

```text
Local → LRCLIB → NetEase → Kugou → QQ Music → Musixmatch → Lyrics.ovh → Genius
```

Se priorizan las letras sincronizadas y se guardan en caché. Cuando solo hay
texto plano, se utiliza una temporización estimada según la duración de la
pista. La selección manual del reproductor tiene prioridad sobre la automática.

Consulta los detalles en [LYRICS.md](docs/LYRICS.md).

### Esquemas adicionales

`ayu` · `flexoki` · `github` · `kanagawa` · `melange` · `monokai` · `nightfox` · `oxocarbon`

El parche local del CLI permite descubrir los esquemas del usuario y aplicar
variantes Material a las paletas estáticas. La variante `tonalspot` mantiene
la paleta tal como fue definida.

Consulta los detalles en [SCHEMES.md](docs/SCHEMES.md).

## Instalación

Pensado para un entorno con Caelestia, Quickshell y Hyprland ya disponibles.
El instalador compila el plugin e instala los componentes de esta versión;
las dependencias deben estar instaladas previamente.

### Requisitos

- Qt 6.9 o superior, Quickshell y `caelestia-cli`.
- CMake, un compilador C++20 y Ninja o Make.
- Python 3 y Fish, utilizado por las herramientas de traducción.
- Dependencias de desarrollo del plugin: Protobuf, OpenSSL, libqalculate,
  PipeWire, aubio y libcava.

### Descargar e instalar

```bash
git clone --branch personal/caelestia-es https://github.com/SasoIkuyo/caelestia.git caelestia-es
cd caelestia-es
chmod +x scripts/*.sh
./scripts/install.sh
```

Por defecto, la instalación usa `~/.local` y no requiere `sudo`.

| Componente | Destino predeterminado |
| --- | --- |
| Shell QML | `~/.local/share/caelestia-es/shell` |
| Enlace de Quickshell | `~/.config/quickshell/caelestia` |
| Plugin C++ | `~/.local/lib/qt6/qml/Caelestia` |
| Esquemas | `~/.local/share/caelestia/schemes` |
| Extensión Python | Directorio de paquetes del usuario de Python |

El instalador respeta `XDG_DATA_HOME` y `XDG_CONFIG_HOME`. Al instalar el shell,
reemplaza el enlace de Quickshell existente; si encuentra una carpeta en su
lugar, la respalda antes de sustituirla. También instala `usercustomize.py`,
con respaldo si existe una versión diferente.

Al terminar:

```bash
caelestia shell -r
caelestia scheme list
```

### Configuración opcional de Hyprland y Caelestia

La configuración personal se instala únicamente si lo solicitas:

```bash
./scripts/install.sh --with-config
```

**Revisa primero [config/](config/README.md)**: incluye reglas de monitores,
aplicaciones y preferencias del equipo de origen. Esta opción copia archivos
a la configuración de Caelestia y Hyprland, con respaldos de los archivos
existentes que cambian.

Los recursos externos de Shimeji configurados como `survivor-slugcat` deben
instalarse por separado o sustituirse por otro recurso. La fuente Spotify Mix UI
no se distribuye; si falta, se utiliza una alternativa del sistema.

### Instalación por componentes

```bash
# Compilar e instalar únicamente el plugin
./scripts/build-plugin.sh

# Instalar únicamente esquemas y extensión Python
./scripts/install-schemes.sh

# Ver las opciones del instalador
./scripts/install.sh --help
```

Para cambiar el prefijo del plugin durante la instalación completa:

```bash
./scripts/install.sh --prefix "$HOME/.local"
```

## Estructura del proyecto

```text
shell/                 Interfaz QML, traducciones y recursos
plugin/                Plugin C++ y servicios
local/python-site/     Extensión local de caelestia-cli
local/caelestia/        Esquemas adicionales y generador
config/                Configuración personal opcional
scripts/               Instalación y compilación
docs/                 Documentación de cambios y procedencia
```

## Solución de problemas

| Problema | Qué revisar |
| --- | --- |
| No se encuentra el módulo `Caelestia` | Comprueba la instalación del plugin y el `QML_IMPORT_PATH` de `shell.qml`. El instalador ajusta la ruta al prefijo elegido. |
| No aparecen los esquemas adicionales | Comprueba que la extensión está instalada en el directorio de paquetes del usuario y que Python tiene habilitado el *user site*. |
| Las variantes no cambian la paleta | Elimina la caché de `~/.cache/caelestia/schemes/variants` y vuelve a seleccionar el esquema. |
| El reloj muestra otra fuente | Instala la familia elegida o cambia `appearance.font.clock` en `shell.json`. |

## Documentación

- [Personalizaciones incluidas](docs/CUSTOMIZATIONS.md)
- [Letras y proveedores](docs/LYRICS.md)
- [Esquemas y variantes](docs/SCHEMES.md)
- [Configuración opcional](config/README.md)
- [Procedencia del código](docs/UPSTREAM.md)
- [Cómo contribuir](CONTRIBUTING.md)

## Créditos y licencia

Gracias a los proyectos que hacen posible esta versión:

- **[Caelestia](https://github.com/caelestia-dots/caelestia)** — dotfiles y proyecto de origen.
- **[MiDnight](https://github.com/dim-ghub/midnight-shell)** — base del shell QML y del plugin C++ incluidos.
- **[Quickshell](https://github.com/quickshell-mirror/quickshell)** — base tecnológica del shell.

El código se distribuye bajo **GPL-3.0**; consulta [LICENSE](LICENSE).
Los recursos de terceros conservan sus respectivas licencias y avisos de autoría.
