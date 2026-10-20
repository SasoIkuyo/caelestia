#!/usr/bin/env bash
# Install this Caelestia snapshot for the current user.
#
# The C++ plugin is built from source and installed under the user prefix
# (default: ~/.local), so no root access is required.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
SHELL_DIR="$DATA_HOME/caelestia-es/shell"
SCHEME_DIR="$DATA_HOME/caelestia/schemes"
PREFIX="${PREFIX:-$HOME/.local}"
BUILD_DIR="${BUILD_DIR:-$ROOT/build}"
JOBS="${JOBS:-$(nproc 2>/dev/null || echo 2)}"
VERSION="${VERSION:-1.0.0}"
GIT_REVISION="${GIT_REVISION:-local}"
WITH_CONFIG=0
SKIP_PLUGIN=0
STAMP="$(date +%Y%m%d-%H%M%S)"

usage() {
    cat <<'EOF'
Usage: ./scripts/install.sh [options]

Options:
  --with-config       Also install the optional ~/.config/caelestia and
                      ~/.config/hypr files. Existing files are backed up.
  --skip-plugin       Do not build/install the C++ plugin.
  --prefix PATH       Install prefix for the plugin (default: ~/.local).
  --build-dir PATH    CMake build directory (default: ./build).
  -h, --help          Show this help.

The shell, local Python extension and colour schemes are always installed.
EOF
}

while (($#)); do
    case "$1" in
        --with-config) WITH_CONFIG=1 ;;
        --skip-plugin) SKIP_PLUGIN=1 ;;
        --prefix)
            [[ $# -ge 2 ]] || { echo "error: --prefix needs a value" >&2; exit 2; }
            PREFIX="$2"; shift ;;
        --build-dir)
            [[ $# -ge 2 ]] || { echo "error: --build-dir needs a value" >&2; exit 2; }
            BUILD_DIR="$2"; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "error: unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
    shift
done

case "$PREFIX" in
    /*) ;;
    *) PREFIX="$PWD/$PREFIX" ;;
esac
case "$BUILD_DIR" in
    /*) ;;
    *) BUILD_DIR="$PWD/$BUILD_DIR" ;;
esac

backup_file() {
    local target="$1"
    if [[ -e "$target" || -L "$target" ]]; then
        cp -a "$target" "$target.bak.$STAMP"
    fi
}

copy_tree_with_backups() {
    local src="$1" dst="$2"
    while IFS= read -r -d '' rel; do
        rel="${rel#./}"
        local target="$dst/$rel"
        mkdir -p "$(dirname "$target")"
        if [[ -e "$target" ]] && ! cmp -s "$src/$rel" "$target"; then
            backup_file "$target"
        fi
        cp -a "$src/$rel" "$target"
    done < <(cd "$src" && find . -type f -print0)
}

install_shell() {
    echo "==> Installing shell QML to $SHELL_DIR"
    mkdir -p "$SHELL_DIR"
    copy_tree_with_backups "$ROOT/shell" "$SHELL_DIR"

    # The repository stores a portable placeholder. Point the shell at the
    # prefix selected above, which is where cmake --install puts the plugin.
    local escaped_prefix="${PREFIX//&/\\&}"
    sed -i "s|^//@ pragma Env QML_IMPORT_PATH=.*$|//@ pragma Env QML_IMPORT_PATH=${escaped_prefix}/lib/qt6/qml:/usr/lib/qt6/qml|" \
        "$SHELL_DIR/shell.qml"
    chmod +x "$SHELL_DIR/assets/wrap_term_launch.sh" 2>/dev/null || true

    local link="$CONFIG_HOME/quickshell/caelestia"
    mkdir -p "$CONFIG_HOME/quickshell"
    if [[ -L "$link" ]]; then
        rm -f "$link"
    elif [[ -e "$link" ]]; then
        backup_file "$link"
        rm -rf "$link"
    fi
    ln -s "$SHELL_DIR" "$link"
    echo "    symlinked $link"
}

build_plugin() {
    if ((SKIP_PLUGIN)); then
        echo "==> Skipping plugin build (--skip-plugin)"
        return
    fi
    if ! command -v cmake >/dev/null 2>&1; then
        echo "error: cmake is required to build the plugin" >&2
        exit 1
    fi

    echo "==> Configuring plugin (prefix: $PREFIX)"
    cmake -S "$ROOT" -B "$BUILD_DIR" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$PREFIX" \
        -DVERSION="$VERSION" \
        -DGIT_REVISION="$GIT_REVISION"

    echo "==> Building plugin with $JOBS jobs"
    cmake --build "$BUILD_DIR" --parallel "$JOBS"

    echo "==> Installing plugin"
    cmake --install "$BUILD_DIR"
}

install_python() {
    local py_site
    py_site="$(python3 -c 'import site; print(site.getusersitepackages())')"
    if [[ -z "$py_site" ]]; then
        echo "error: could not determine the Python user site directory" >&2
        exit 1
    fi

    echo "==> Installing local Python extension to $py_site"
    mkdir -p "$py_site"
    if [[ -e "$py_site/usercustomize.py" ]] && ! cmp -s "$ROOT/local/python-site/usercustomize.py" "$py_site/usercustomize.py"; then
        backup_file "$py_site/usercustomize.py"
    fi
    cp "$ROOT/local/python-site/caelestia_local_patch.py" "$py_site/caelestia_local_patch.py"
    cp "$ROOT/local/python-site/usercustomize.py" "$py_site/usercustomize.py"

    if ! python3 -c 'import site; raise SystemExit(0 if site.ENABLE_USER_SITE else 1)'; then
        echo "warning: Python user site is disabled; enable it for the scheme patch to load" >&2
    fi
}

install_schemes() {
    echo "==> Installing extra colour schemes to $SCHEME_DIR"
    mkdir -p "$SCHEME_DIR"
    copy_tree_with_backups "$ROOT/local/caelestia/schemes" "$SCHEME_DIR"
    mkdir -p "$DATA_HOME/caelestia"
    cp "$ROOT/local/caelestia/README-local.md" "$DATA_HOME/caelestia/README-local.md"
}

install_config() {
    if ((!WITH_CONFIG)); then
        echo "==> Skipping optional user configs (use --with-config to install)"
        return
    fi

    echo "==> Installing optional Caelestia config"
    mkdir -p "$CONFIG_HOME/caelestia"
    copy_tree_with_backups "$ROOT/config/caelestia" "$CONFIG_HOME/caelestia"

    echo "==> Installing optional Hyprland config"
    mkdir -p "$CONFIG_HOME/hypr"
    copy_tree_with_backups "$ROOT/config/hypr" "$CONFIG_HOME/hypr"
}

build_plugin
install_shell
install_python
install_schemes
install_config

cat <<EOF

Done.

Next steps:
  1. Restart the shell:   caelestia shell -r
  2. Check schemes:       caelestia scheme list
  3. If you installed configs, review:
       $CONFIG_HOME/caelestia/shell.json
       $CONFIG_HOME/caelestia/hypr-user.lua
       $CONFIG_HOME/hypr/hyprland.lua

The plugin is installed under:
  $PREFIX/lib/qt6/qml/Caelestia
EOF
