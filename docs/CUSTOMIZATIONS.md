# Cambios propios

Resumen de lo que se aparta del upstream de Caelestia/MiDnight.

## 1. Interfaz en español

- `shell/Esp.js`: diccionario de traducciones español → inglés.
- Los QML importan `Esp.js` y envuelven textos con `Es.tr(...)`.
- Se mantiene la infraestructura nativa `Tr.tr()`/`qsTr()` de Caelestia.
- El idioma no se aplica al paquete Python del sistema.

## 2. Letras

### Proveedores

Cadena actual:

```
Local
  → LRCLIB
  → NetEase
  → Kugou
  → QQ Music
  → Musixmatch
  → Lyrics.ovh
  → Genius
```

- Los proveedores con letras sincronizadas se intentan antes que los de texto
  plano.
- Los proveedores de texto plano usan temporización estimada.
- Solo se guardan en caché las letras sincronizadas.
- `plugin/src/Caelestia/Config/enums.hpp` añade los nuevos valores de
  `LyricsBackend`.

### Interfaz

- Selector de proveedor en `modules/nexus/pages/ServicesPage.qml`.
- Estado de letras sincronizadas/sin sincronizar en
  `modules/dashboard/media/LyricsInfo.qml`.
- Reproductor activo y metadatos MPRIS centralizados en
  `services/Players.qml`.
- Preferencia de reproductor: reproduciendo → predeterminado configurado →
  primero; la elección manual manda.

### Temporización

- Las letras sin timestamps se reparten según la duración de la pista.
- El offset manual se conserva.
- La caché de letras sincronizadas evita volver a consultar proveedores.

## 3. Fuentes de reloj y letras

- `shell/services/Fonts.qml`: lista curada de familias disponibles; evita que
  el selector se llene de fuentes Noto/iconos.
- `shell/services/LyricsStyle.qml`: guarda la fuente de las letras en
  `~/.local/state/caelestia/lyrics.json` con `JsonAdapter` + `FileView`.
- `shell/services/ControllerBatteries.qml`: lectura de batería de DualSense y
  control del lightbar; las rutas usan `Quickshell.env("HOME")`.
- El reloj flotante lee `appearance.font.clock` de `shell.json`.
- La fuente Spotify Mix UI no se incluye por ser propietaria.

## 4. Esquemas de color y variantes

- Ocho esquemas nuevos en `local/caelestia/schemes/`:
  `ayu`, `flexoki`, `github`, `kanagawa`, `melange`, `monokai`, `nightfox`,
  `oxocarbon`.
- `local/python-site/caelestia_local_patch.py`:
  - añade el directorio de esquemas de usuario;
  - extiende `caelestia scheme list/get/set`;
  - implementa variantes estáticas conservando los tonos originales y tomando
    tono/croma de Material You;
  - cachea las variantes en `~/.cache/caelestia/schemes/variants`.
- `local/python-site/usercustomize.py`: import hook que carga el parche solo
  cuando se importa `caelestia`; no toca `/usr/lib/python3.14`.
- `modules/launcher/services/Schemes.qml`: recarga la lista y el esquema actual
  cuando cambia `scheme.json`.

## 5. QuickShare

Cambios incluidos en el plugin (parte del árbol de trabajo original):

- recepción de varios archivos con `QSaveFile` y nombres seguros;
- keepalive y ACK de desconexión;
- `removeHistoryEntry(int index)`;
- correcciones de finalización/errores de transferencia.

Estos cambios son independientes de las letras y los esquemas, pero se
conservaron para no perder trabajo del usuario.

## 6. Build y despliegue

- `CMakeLists.txt` propio para compilar solo el plugin sin consultar el remoto.
- `scripts/install.sh` instala todo en `~/.local` sin `sudo`.
- `scripts/build-plugin.sh` compila solo el plugin.
- `scripts/install-schemes.sh` instala esquemas y parche Python.
- El `QML_IMPORT_PATH` del `shell.qml` se genera con el prefijo elegido por el
  instalador.
