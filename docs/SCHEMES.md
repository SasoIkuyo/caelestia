# Esquemas de color y variantes

## Esquemas incluidos

Además de los esquemas que trae Caelestia, se añaden:

| Esquema | Archivos |
| --- | --- |
| `ayu` | `default/dark.txt`, `default/light.txt` |
| `flexoki` | `default/dark.txt`, `default/light.txt` |
| `github` | `default/dark.txt`, `default/light.txt` |
| `kanagawa` | `default/dark.txt`, `default/light.txt` |
| `melange` | `default/dark.txt`, `default/light.txt` |
| `monokai` | `default/dark.txt`, `default/light.txt` |
| `nightfox` | `default/dark.txt`, `default/light.txt` |
| `oxocarbon` | `default/dark.txt`, `default/light.txt` |

Se instalan en:

```
~/.local/share/caelestia/schemes/
```

y se regeneran con:

```bash
python3 ~/.local/share/caelestia/schemes/generate.py
```

`generate.py` usa `materialyoucolor` y el generador de Caelestia para producir
la paleta base a partir de la semilla de cada tema.

## Por qué hace falta un parche

El paquete `caelestia-cli` del sistema solo busca esquemas en su propio
directorio. El parche de usuario:

- añade `~/.local/share/caelestia/schemes` a la búsqueda;
- extiende `get_scheme_names`, `get_scheme_flavours` y `get_scheme_modes`;
- hace que `caelestia scheme list/get/set` vean los esquemas nuevos;
- implementa las variantes de Material You para esquemas estáticos.

El paquete del sistema no se modifica. El parche se carga desde el *user site*
de Python mediante `usercustomize.py`, y solo cuando se importa `caelestia`.

## Variantes

En un esquema dinámico, Caelestia genera la paleta desde el fondo de pantalla.
En un esquema estático, la paleta está escrita a mano. Si se regenerara entera
desde una semilla, todos los esquemas acabarían pareciéndose a una paleta
Material genérica.

Por eso el parche:

1. lee la paleta original del esquema;
2. genera la paleta de la variante con `materialyoucolor`;
3. conserva el **tono** de cada rol original;
4. toma el **hue** y el **chroma** de la variante;
5. deja `tonalspot` intacto, porque es el aspecto nativo del esquema.

Así `vibrant`, `monochrome`, etc. cambian visiblemente la paleta sin perder la
identidad de Kanagawa, Monokai, GitHub, etc.

## Caché

Las paletas de variantes se guardan en:

```
~/.cache/caelestia/schemes/variants/
```

La primera generación tarda unos segundos; después se reutiliza la caché. Para
forzar una regeneración:

```bash
rm -rf ~/.cache/caelestia/schemes/variants
caelestia scheme set -n kanagawa -f default -m dark -v vibrant
```

## Comandos útiles

```bash
caelestia scheme list
caelestia scheme list -n
caelestia scheme get
caelestia scheme set -n tokyonight -f default -m dark -v vibrant
caelestia scheme set -n kanagawa -f default -m dark -v monochrome
```

El selector del launcher (`modules/launcher/services/Schemes.qml`) recarga la
lista y el esquema actual cuando cambia `scheme.json`.
