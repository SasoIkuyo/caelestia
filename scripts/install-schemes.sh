#!/usr/bin/env bash
# Install the extra colour schemes and the user-level Python patch.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
SCHEME_DIR="$DATA_HOME/caelestia/schemes"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$SCHEME_DIR"
while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    target="$SCHEME_DIR/$rel"
    mkdir -p "$(dirname "$target")"
    if [[ -e "$target" ]] && ! cmp -s "$ROOT/local/caelestia/schemes/$rel" "$target"; then
        cp -a "$target" "$target.bak.$STAMP"
    fi
    cp -a "$ROOT/local/caelestia/schemes/$rel" "$target"
done < <(cd "$ROOT/local/caelestia/schemes" && find . -type f -print0)

mkdir -p "$DATA_HOME/caelestia"
cp "$ROOT/local/caelestia/README-local.md" "$DATA_HOME/caelestia/README-local.md"

py_site="$(python3 -c 'import site; print(site.getusersitepackages())')"
mkdir -p "$py_site"
if [[ -e "$py_site/usercustomize.py" ]] && ! cmp -s "$ROOT/local/python-site/usercustomize.py" "$py_site/usercustomize.py"; then
    cp -a "$py_site/usercustomize.py" "$py_site/usercustomize.py.bak.$STAMP"
fi
cp "$ROOT/local/python-site/caelestia_local_patch.py" "$py_site/caelestia_local_patch.py"
cp "$ROOT/local/python-site/usercustomize.py" "$py_site/usercustomize.py"

echo "Schemes installed in $SCHEME_DIR"
echo "Python patch installed in $py_site"
echo "Clear ~/.cache/caelestia/schemes/variants to force palette regeneration."
