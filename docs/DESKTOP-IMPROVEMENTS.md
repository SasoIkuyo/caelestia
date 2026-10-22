# Audio, ubicación y actualizaciones

## Cambios

- Audio: ocultar salidas y micrófonos, volver a mostrarlos y recordar la selección. Ocultar un dispositivo no lo silencia ni lo desconecta. El cambio de salida mediante atajo omite los dispositivos ocultos.
- Idioma: Español aparece en el selector. Se incluye un catálogo nativo de 740 entradas traducidas, sin entradas pendientes; requiere compilar el plugin. El diccionario local sigue disponible para la interfaz existente.
- Clima: búsqueda de ciudades con región y país, guardado de coordenadas y regreso a ubicación automática por IP. La búsqueda usa Open-Meteo.
- Rendimiento: visualizador decorativo a 30 FPS, sin textura adicional en el renderizador por CPU ni capa de pantalla completa cuando no se usa desenfoque. Los paneles multimedia ocultos dejan de solicitar análisis de audio.
- Actualizaciones: vista previa de paquetes y versiones, iconos, registro en vivo, respuestas desde el panel y autenticación mediante el agente polkit de Quickshell. La página y el registro tienen desplazamiento independiente.
- Configuración opcional: el editor predeterminado es VS Code (`code`) y su etiqueta es “Editor de Código”. Solo se instala esa preferencia al usar `--with-config`.

## Actualizador experimental

Requiere Arch Linux, Python 3, pacman-contrib (`checkupdates`), paru y pkexec. No instala una política polkit nueva ni almacena contraseñas. Mantiene las confirmaciones del gestor y la revisión de AUR.

La página puede cerrarse durante una actualización; Quickshell debe permanecer abierto. El porcentaje corresponde a la operación actual, no al total. Se conservan los últimos 60.000 caracteres del registro. Los conflictos de configuración y los mensajes inusuales de compilación AUR necesitan más pruebas.

No reiniciar automáticamente Quickshell después de actualizarlo: el plugin y las bibliotecas deben pertenecer a la misma compilación. No mezclar un plugin local antiguo con módulos nuevos del sistema.

## Comprobaciones

```sh
python -m unittest discover -s tests -v
node --test tests/qml-logic.test.js
msgfmt --check --statistics -o /tmp/caelestia-es.mo plugin/src/Caelestia/I18n/trs/es.po
```

Las pruebas Python simulan los procesos y no instalan paquetes. Las pruebas JavaScript comprueban los métodos de los servicios QML con dispositivos y respuestas de red simulados. En la instalación local se probó la interfaz, la búsqueda de Santiago y una actualización real de repositorios y AUR. El catálogo nativo también se validó mediante compilación del módulo I18n sobre la base actual de MiDnight.

Los cambios candidatos para upstream se preparan por separado en `quickshell-contributions`. El actualizador requiere revisión adicional antes de proponerlo al proyecto original.
