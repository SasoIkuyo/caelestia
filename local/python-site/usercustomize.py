"""Load the local Caelestia patch only when the CLI package is imported.

The patch lives in the user site so the system package remains untouched, but
it is applied through an import hook instead of importing Caelestia at Python
startup for every process.
"""

from __future__ import annotations

import importlib.abc
import importlib.util
import sys


class _CaelestiaPatchFinder(importlib.abc.MetaPathFinder):
    def find_spec(self, fullname, path=None, target=None):
        if fullname != "caelestia":
            return None

        # Avoid recursion while asking the normal finders for the real spec.
        sys.meta_path.remove(self)
        try:
            spec = importlib.util.find_spec(fullname)
        finally:
            sys.meta_path.insert(0, self)

        if spec is None or spec.loader is None:
            return None

        original_exec_module = spec.loader.exec_module

        def exec_module(module):
            original_exec_module(module)
            try:
                from caelestia_local_patch import apply

                apply()
            except Exception:
                # Never break the CLI because an optional local extension failed.
                pass

        spec.loader.exec_module = exec_module
        return spec


if not any(isinstance(finder, _CaelestiaPatchFinder) for finder in sys.meta_path):
    sys.meta_path.insert(0, _CaelestiaPatchFinder())
