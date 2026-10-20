# Caelestia ES · MiDnight personalizado

Configuración completa y autoalojada de mi shell **Caelestia / Quickshell**, con
interfaz en español, letras sincronizadas, fuentes persistentes para reloj y
letras, esquemas de color adicionales y el plugin C++ ya modificado.

El proyecto empezó a partir de
[caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia) y de la
base [dim-ghub/midnight-shell](https://github.com/dim-ghub/midnight-shell), pero
el árbol actual incluye bastantes cambios propios. **Caelestia ES es una
versión comunitaria derivada e independiente**, sin afiliación oficial con
los proyectos originales. La licencia original
GPL-3.0 se conserva en [`LICENSE`](LICENSE).

## Qué contiene

```
.
├── shell/                  QML real que está ejecutándose (incluye Esp.js)
├── plugin/                 fuente C++ del plugin (servicios, letras, QuickShare…)
├── CMakeLists.txt          compilación del plugin
├── scripts/
│   ├── install.sh          instalación completa para el usuario actual
│   ├── build-plugin.sh     solo compilar/instalar el plugin
│   ├── install-schemes.sh  solo esquemas + parche Python
│   └── trs.fish            helper de traducciones que necesita el CMake
├── local/
│   ├── python-site/        parche de usuario para caelestia-cli
│   └── caelestia/          esquemas extra + generador
├── config/                 configuración opcional de Caelestia e Hyprland
└── docs/                   notas de cambios, letras, esquemas y upstream
```

La carpeta `shell/` es una copia del shell que se ejecuta actualmente en
`~/.local/share/caelestia-es/shell`; por eso incluye `Esp.js`, las traducciones
y los servicios añadidos (`Fonts.qml`, `LyricsStyle.qml`,
`ControllerBatteries.qml`). El plugin C++ vive en `plugin/` y se compila desde
fuente.

## Instalación rápida

Requisitos principales:

- Qt 6.9 o superior (el sistema actual usa Qt 6.12), Quickshell y `caelestia-cli`.
- CMake, Ninja o Make, y un compilador C++20.
- Dependencias del plugin: Protobuf, OpenSSL, libqalculate, PipeWire, aubio y
  libcava. En Arch/derivados suelen estar en `protobuf`, `openssl`,
  `libqalculate`, `pipewire`, `aubio` y `libcava`.

Desde esta carpeta:

```bash
chmod +x scripts/*.sh
./scripts/install.sh
```

El instalador:

1. copia el shell a `~/.local/share/caelestia-es/shell`;
2. crea el enlace `~/.config/quickshell/caelestia`;
3. compila e instala el plugin en `~/.local` (sin `sudo`);
4. instala el parche Python en el *user site* de Python;
5. copia los esquemas a `~/.local/share/caelestia/schemes`.

Después:

```bash
caelestia shell -r
caelestia scheme list
```

### Instalar también la configuración de Hyprland/Caelestia

Es opcional porque puede pisar configuración existente. El instalador hace
copias de seguridad de los archivos que reemplaza:

```bash
./scripts/install.sh --with-config
```

Revisa después, sobre todo, estos archivos:

- `~/.config/caelestia/shell.json`
- `~/.config/caelestia/hypr-user.lua`
- `~/.config/hypr/hyprland.lua`

### Solo el plugin

```bash
PREFIX="$HOME/.local" ./scripts/build-plugin.sh
```

### Solo esquemas y parche Python

```bash
./scripts/install-schemes.sh
```

## Personalizaciones incluidas

### Interfaz en español

`shell/Esp.js` contiene el diccionario español y los QML llaman a `Es.tr(...)`
alrededor de `Tr.tr(...)`/`qsTr(...)`. No se modificó el paquete del sistema.

### Letras

La cadena de proveedores es:

```
Local → LRCLIB → NetEase → Kugou → QQ Music → Musixmatch → Lyrics.ovh → Genius
```

Los proveedores con letras sincronizadas se intentan primero; los de texto
plano se usan con temporización estimada. La caché guarda las letras
sincronizadas. También se añadió el selector de proveedor en Nexus y los
indicadores de letras sincronizadas/sin sincronizar.

La preferencia de reproductor MPRIS es: reproductor reproduciendo → reproductor
predeterminado configurado → primero disponible; la elección manual tiene
prioridad.

Más detalles en [`docs/LYRICS.md`](docs/LYRICS.md).

### Fuentes persistentes

- `shell/services/Fonts.qml`: lista curada de fuentes para reloj/letras.
- `shell/services/LyricsStyle.qml`: guarda la fuente de las letras en
  `~/.local/state/caelestia/lyrics.json`, de modo que sobrevive a reinicios.
- El reloj usa `appearance.font.clock` de `shell.json`.

La fuente **Spotify Mix UI** no se redistribuye porque es propietaria; si no
está instalada, el shell usa una alternativa del sistema.

### Esquemas de color

Se añadieron ocho esquemas con variantes dark/light:

`ayu`, `flexoki`, `github`, `kanagawa`, `melange`, `monokai`, `nightfox` y
`oxocarbon`.

El parche de usuario permite que `caelestia scheme list` vea los esquemas en
`~/.local/share/caelestia/schemes`, y hace que las variantes Material cambien
realmente la paleta. En esquemas estáticos se conservan los tonos originales y
solo se toman tono/croma de la variante; `tonalspot` mantiene la paleta tal como
fue escrita. Hay una caché en `~/.cache/caelestia/schemes/variants`.

Más detalles en [`docs/SCHEMES.md`](docs/SCHEMES.md).

### QuickShare

El plugin incluye cambios propios para recepción de varios archivos, keepalive
y eliminación de entradas del historial. Son parte del árbol de trabajo actual
y se incluyen tal cual.

## Notas y datos personales

- En `config/caelestia/shell.json` se eliminaron las direcciones MAC de
  Bluetooth y la ruta absoluta del usuario; el resto de preferencias se
  conserva.
- Los recursos de **Shimeji** configurados (`~/.local/share/shimeji/...`) no se
  incluyen. El shell sí trae el set `pusheen` en
  `shell/assets/shimeji/pusheen/`, pero el ajuste de `shell.json` apunta a
  `survivor-slugcat`; copia esos recursos por separado o cambia la ruta.
- `config/hypr/hypr-user.lua` contiene reglas de monitores y aplicaciones de mi
  equipo. Revísalo antes de usarlo en otra máquina.
- El plugin se instala en `~/.local`; no se necesita `sudo`.

## Compilación manual

```bash
cmake -S . -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$HOME/.local" \
  -DVERSION=1.0.0 \
  -DGIT_REVISION=local
cmake --build build --parallel "$(nproc)"
cmake --install build
```

El resultado queda en:

```
~/.local/lib/qt6/qml/Caelestia
```

El `QML_IMPORT_PATH` del shell se ajusta automáticamente al prefijo elegido por
el instalador (`~/.local` por defecto).

## Solución de problemas

- **El shell no encuentra `Caelestia`**: comprueba que el plugin está en
  `~/.local/lib/qt6/qml/Caelestia` y que `shell.qml` tiene ese directorio en
  `QML_IMPORT_PATH`.
- **Las variantes no cambian los colores**: borra
  `~/.cache/caelestia/schemes/variants` y vuelve a seleccionar el esquema.
- **No aparecen los esquemas nuevos**: ejecuta `caelestia scheme list`; el
  parche Python debe estar en el *user site* de Python y el *user site* debe
  estar habilitado.
- **El reloj usa otra fuente**: instala la fuente o cambia
  `appearance.font.clock` en `~/.config/caelestia/shell.json`.

## Repositorio y ramas

Esta versión se publica en el fork
[SasoIkuyo/caelestia](https://github.com/SasoIkuyo/caelestia), en la rama
`personal/caelestia-es`. La rama `main` conserva la base de los dotfiles
originales; la rama personal incorpora esta instantánea de Caelestia ES,
incluidos el shell derivado de MiDnight y el plugin.

Para obtener esta versión:

```bash
git clone --branch personal/caelestia-es https://github.com/SasoIkuyo/caelestia.git
cd caelestia
```

Revisa `config/` antes de instalar: contiene preferencias de Hyprland
adaptadas al equipo de origen.

Para proponer cambios a los proyectos originales mediante pull requests,
consulta [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Créditos y upstream

- Caelestia: <https://github.com/caelestia-dots/caelestia>
- Shell base / MiDnight: <https://github.com/dim-ghub/midnight-shell>
- Quickshell: <https://github.com/quickshell-mirror/quickshell>

Consulta [`docs/UPSTREAM.md`](docs/UPSTREAM.md) y
[`docs/CUSTOMIZATIONS.md`](docs/CUSTOMIZATIONS.md) para el detalle de los
cambios.
