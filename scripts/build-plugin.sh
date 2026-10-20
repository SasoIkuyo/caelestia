#!/usr/bin/env bash
# Build and install only the C++ plugin from this repository.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREFIX="${PREFIX:-$HOME/.local}"
BUILD_DIR="${BUILD_DIR:-$ROOT/build}"
JOBS="${JOBS:-$(nproc 2>/dev/null || echo 2)}"
VERSION="${VERSION:-1.0.0}"
GIT_REVISION="${GIT_REVISION:-local}"

case "$PREFIX" in
    /*) ;;
    *) PREFIX="$PWD/$PREFIX" ;;
esac
case "$BUILD_DIR" in
    /*) ;;
    *) BUILD_DIR="$PWD/$BUILD_DIR" ;;
esac

cmake -S "$ROOT" -B "$BUILD_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DVERSION="$VERSION" \
    -DGIT_REVISION="$GIT_REVISION"

cmake --build "$BUILD_DIR" --parallel "$JOBS"
cmake --install "$BUILD_DIR"

echo "Plugin installed under $PREFIX/lib/qt6/qml/Caelestia"
