# Configuración opcional

Esta carpeta contiene la configuración de usuario que acompañaba al shell. No
se instala por defecto:

```bash
./scripts/install.sh --with-config
```

El instalador copia los archivos y hace una copia de seguridad de los que ya
existan.

## Contenido

- `caelestia/shell.json`: preferencias del shell. Se quitaron las direcciones
  MAC de Bluetooth y se dejó la ruta de Shimeji con `~`.
- `caelestia/hypr-user.lua`: reglas de monitores, ventanas y aplicaciones de mi
  equipo. **Revísalo antes de reutilizarlo en otra máquina.**
- `caelestia/hypr-vars.lua`: variables de Hyprland.
- `caelestia/cli.json`: preferencias de `caelestia-cli`.
- `hypr/`: configuración completa de Hyprland (Lua), incluyendo esquema,
  animaciones, reglas y `hyprlock`.

## Dependencias externas

La configuración de Hyprland hace referencia a programas que no forman parte de
este repositorio, por ejemplo `foot`, `firefox`, `thunar`, `codium`, `aura`,
`unix-dashboard`, Discord, Steam y los recursos de Shimeji. Instálalos o adapta
las reglas antes de usar la configuración tal cual.
