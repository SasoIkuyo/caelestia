# Local Caelestia colour-scheme extensions

The root-owned Caelestia package in `/usr/lib/python3.14/site-packages` was
left untouched.  These files extend it for the current user:

- `schemes/` contains extra schemes discovered by `caelestia scheme list`.
- `schemes/generate.py` regenerates the extra scheme files.
- `~/.local/lib/python3.14/site-packages/usercustomize.py` installs an import
  hook that loads the local patch only when the `caelestia` Python package is
  imported.
- `~/.local/lib/python3.14/site-packages/caelestia_local_patch.py` adds the
  user scheme directory and makes static schemes respond to their selected
  Material variant.

Variant palettes are cached under `~/.cache/caelestia/schemes/variants` so the
scheme list is instant after the first run.  To force a refresh, remove that
cache directory.

The local patch keeps each static scheme's original tones and takes the hue and
chroma of the selected Material variant.  `tonalspot` keeps the scheme as
authored; all other variants visibly change the palette.  Dynamic schemes still
use the upstream wallpaper-generated palette.
