#!/bin/sh
set -eu
ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
mkdir -p "$ROOT_DIR/Modules/Sources/DI/Generated"
needle generate "$ROOT_DIR/Modules/Sources/DI/Generated/NeedleGenerated.swift" "$ROOT_DIR/Modules/Sources/DI"
echo "complete needle"