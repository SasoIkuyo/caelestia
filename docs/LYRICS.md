# Letras: proveedores y comportamiento

## Cadena de búsqueda

`plugin/src/Caelestia/Services/lyrics.cpp` implementa la búsqueda en este orden:

1. **Local** — archivos/caché local.
2. **LRCLIB** — letras sincronizadas.
3. **NetEase** — letras sincronizadas o texto.
4. **Kugou** — búsqueda con headers de navegador.
5. **QQ Music** — búsqueda con headers de navegador.
6. **Musixmatch** — texto/HTML convertido a texto plano.
7. **Lyrics.ovh** — texto plano.
8. **Genius** — HTML/JSON de la página, convertido a texto plano.

Los primeros proveedores de la lista son los que suelen devolver `.lrc` con
timestamps. Si ninguno devuelve una letra sincronizada, se acepta texto plano y
se estima el tiempo.

## Sincronizadas frente a texto plano

- `Lyrics.synced` es `true` solo si la letra tiene timestamps utilizables.
- Una letra de texto plano se divide en líneas y se distribuye a lo largo de la
  duración de la pista.
- La interfaz muestra `Letras sincronizadas` o
  `Letras sin sincronizar (tiempo estimado)`.
- La caché solo se escribe para letras sincronizadas; así no se “congela” una
  estimación incorrecta.

## Selección del reproductor

`services/Players.qml` centraliza la lógica MPRIS:

1. Si hay un reproductor reproduciendo, se usa ese.
2. Si no, se usa el reproductor predeterminado configurado.
3. Si no, se usa el primero disponible.
4. Una elección manual del usuario tiene prioridad sobre lo anterior.

La misma lógica se usa para el widget de medios, la pantalla de bloqueo y las
letras de escritorio.

## Configuración

- `services.lyricsBackend` en `~/.config/caelestia/shell.json`:
  `Auto`, `Local`, `LRCLIB`, `NetEase`, `Kugou`, `QQMusic`, `Musixmatch`,
  `LyricsOvh` o `Genius`.
- El selector también está en **Nexus → Servicios → Medios y letras**.
- El offset manual se ajusta desde el panel de medios.

## Archivos relevantes

```
plugin/src/Caelestia/Config/enums.hpp
plugin/src/Caelestia/Services/lyrics.cpp
plugin/src/Caelestia/Services/lyrics.hpp
modules/dashboard/media/LyricsInfo.qml
modules/dashboard/media/LyricList.qml
modules/dashboard/dash/Media.qml
modules/background/DesktopLyrics.qml
modules/lock/Media.qml
services/Players.qml
```

## Limitaciones

- Los proveedores no oficiales pueden cambiar su HTML/API sin aviso.
- Algunos temas no tienen letra sincronizada en ningún proveedor; en ese caso
  se usa texto plano.
- La estimación de texto plano no conoce pausas, intros o cambios de tempo.
- La red puede fallar; el proveedor local y la caché siguen funcionando.
