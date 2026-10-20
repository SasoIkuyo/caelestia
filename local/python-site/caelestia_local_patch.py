"""Local Caelestia CLI extensions.

This module is loaded from ``usercustomize.py`` only when the ``caelestia``
package is imported.  It deliberately does not touch the root-owned package in
``/usr/lib``.
"""

from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
from types import SimpleNamespace

_INSTALLED = False
_CLASS_PATCHED = False
_CACHE_VERSION = 1


def _user_schemes_dir() -> Path:
    data_home = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local" / "share"))
    return data_home / "caelestia" / "schemes"


def _scheme_roots(scheme_mod):
    user_dir = _user_schemes_dir()
    roots = []
    if user_dir.is_dir():
        roots.append(user_dir)
    roots.append(scheme_mod.scheme_data_dir)
    return roots


def _variant_cache_path(source: Path, variant: str) -> Path:
    cache_home = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache"))
    digest = hashlib.sha256(str(source.resolve()).encode()).hexdigest()[:16]
    return cache_home / "caelestia" / "schemes" / "variants" / f"{digest}-{variant}-v{_CACHE_VERSION}.json"


def _read_variant_cache(source: Path, variant: str):
    cache = _variant_cache_path(source, variant)
    try:
        stat = source.stat()
        data = json.loads(cache.read_text())
        if data.get("mtime_ns") == stat.st_mtime_ns and data.get("size") == stat.st_size:
            colours = data.get("colours")
            if isinstance(colours, dict):
                return colours
    except (OSError, ValueError, TypeError):
        pass
    return None


def _write_variant_cache(source: Path, variant: str, colours: dict[str, str]) -> None:
    cache = _variant_cache_path(source, variant)
    try:
        stat = source.stat()
        cache.parent.mkdir(parents=True, exist_ok=True)
        cache.write_text(
            json.dumps(
                {
                    "mtime_ns": stat.st_mtime_ns,
                    "size": stat.st_size,
                    "colours": colours,
                }
            )
        )
    except OSError:
        pass


def _apply_variant(base, variant: str, mode: str, flavour: str):
    """Apply a Material variant while keeping the base scheme's tones.

    Static schemes already contain a hand-tuned palette.  Regenerating the
    whole palette from one seed makes every scheme look like a generic Material
    palette, so instead we keep each role's original tone and take only the
    variant's hue and chroma from materialyoucolor.
    """

    # Tonal spot is the native/default look of the static schemes.
    if variant == "tonalspot" or not base:
        return base

    seed = base.get("primary_paletteKeyColor") or base.get("primary")
    if not seed:
        return base

    try:
        from materialyoucolor.hct import Hct

        from caelestia.utils.material.generator import gen_scheme

        fake_scheme = SimpleNamespace(name="local", flavour=flavour, mode=mode, variant=variant)
        generated = gen_scheme(fake_scheme, Hct.from_int(int(seed, 16)))

        result = dict(base)
        for name, value in base.items():
            generated_value = generated.get(name)
            if not generated_value:
                continue
            try:
                base_hct = Hct.from_int(int(value, 16))
                variant_hct = Hct.from_int(int(generated_value, 16))
                variant_hct.tone = base_hct.tone
                result[name] = hex(variant_hct.to_int())[4:].upper()
            except (TypeError, ValueError):
                # Keep the original colour if a role cannot be converted.
                pass
        return result
    except Exception:
        # A broken/missing materialyoucolor installation must not prevent the
        # CLI from working.
        return base


def _patch_class(scheme_mod) -> None:
    global _CLASS_PATCHED
    if _CLASS_PATCHED:
        return

    original_get_colours_path = scheme_mod.Scheme.get_colours_path

    def get_colours_path(self):
        for root in _scheme_roots(scheme_mod):
            path = (root / self.name / self.flavour / self.mode).with_suffix(".txt")
            if path.is_file():
                return path
        return original_get_colours_path(self)

    def update_colours(self) -> None:
        if self.name == "dynamic":
            from caelestia.utils.material import get_colours_for_image
            from caelestia.utils.notify import notify

            try:
                self._colours = get_colours_for_image()
            except FileNotFoundError:
                if self.notify:
                    notify(
                        "-u",
                        "critical",
                        "Unable to set dynamic scheme",
                        "No wallpaper set. Please set a wallpaper via `caelestia wallpaper` before setting a dynamic scheme.",
                    )
                raise ValueError(
                    "No wallpaper set. Please set a wallpaper via `caelestia wallpaper` before setting a dynamic scheme."
                )
        else:
            source = self.get_colours_path()
            base = scheme_mod.read_colours_from_file(source)
            if self.variant == "tonalspot":
                self._colours = base
            else:
                cached = _read_variant_cache(source, self.variant)
                if cached is not None:
                    self._colours = cached
                else:
                    self._colours = _apply_variant(base, self.variant, self.mode, self.flavour)
                    _write_variant_cache(source, self.variant, self._colours)

    scheme_mod.Scheme.get_colours_path = get_colours_path
    scheme_mod.Scheme._update_colours = update_colours
    _CLASS_PATCHED = True


def _patch_helpers(scheme_mod) -> None:
    def get_scheme_names():
        names = set()
        for root in _scheme_roots(scheme_mod):
            if root.is_dir():
                names.update(entry.name for entry in root.iterdir() if entry.is_dir())
        return sorted(names) + ["dynamic"]

    def get_scheme_flavours(name: str | None = None):
        if name is None:
            name = scheme_mod.get_scheme().name
        if name == "dynamic":
            return ["default", "hard"]

        flavours = set()
        for root in _scheme_roots(scheme_mod):
            scheme_dir = root / name
            if scheme_dir.is_dir():
                flavours.update(entry.name for entry in scheme_dir.iterdir() if entry.is_dir())
        return sorted(flavours)

    def get_scheme_modes(name: str | None = None, flavour: str | None = None):
        if name is None or flavour is None:
            scheme = scheme_mod.get_scheme()
            name = name or scheme.name
            flavour = flavour or scheme.flavour

        if name == "dynamic":
            return ["light", "dark"]

        modes = set()
        for root in _scheme_roots(scheme_mod):
            mode_dir = root / name / flavour
            if mode_dir.is_dir():
                modes.update(entry.stem for entry in mode_dir.iterdir() if entry.is_file())
        return sorted(modes)

    for module in (scheme_mod,):
        module.get_scheme_names = get_scheme_names
        module.get_scheme_flavours = get_scheme_flavours
        module.get_scheme_modes = get_scheme_modes

    # parser.py and subcommands/scheme.py import these names directly, so they
    # need to see the extended versions as well.
    import caelestia.parser as parser

    parser.get_scheme_names = get_scheme_names

    from caelestia.subcommands import scheme as scheme_command

    scheme_command.get_scheme_names = get_scheme_names
    scheme_command.get_scheme_flavours = get_scheme_flavours
    scheme_command.get_scheme_modes = get_scheme_modes


def apply() -> None:
    global _INSTALLED
    if _INSTALLED:
        return

    try:
        from caelestia.utils import scheme as scheme_mod
    except ImportError:
        return

    _patch_class(scheme_mod)
    _patch_helpers(scheme_mod)
    _INSTALLED = True
