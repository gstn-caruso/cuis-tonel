#!/usr/bin/env bash
# Run the Tonel test suite using a Cuis Smalltalk image.
# Usage: CUIS_VM=<path-to-vm> CUIS_IMAGE=<path-to-image> bash run-tests.sh
# Or:    CUIS_DEV_ROOT=<path-to-Cuis-Smalltalk-Dev> bash run-tests.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Resolve VM binary
if [[ -n "${CUIS_VM:-}" ]]; then
  CUIS_VM_BIN="$CUIS_VM"
elif [[ -n "${CUIS_DEV_ROOT:-}" ]]; then
  ARCH="$(uname -m)"
  case "$(uname -s)-$ARCH" in
    Darwin-*)      CUIS_VM_BIN="$CUIS_DEV_ROOT/CuisVM.app/Contents/MacOS/Squeak" ;;
    Linux-x86_64)  CUIS_VM_BIN="$CUIS_DEV_ROOT/CuisVM.app/Contents/Linux-x86_64/squeak" ;;
    Linux-aarch64) CUIS_VM_BIN="$CUIS_DEV_ROOT/CuisVM.app/Contents/Linux-arm64/squeak" ;;
    *) echo "Unsupported platform: $(uname -s)-$ARCH" >&2; exit 1 ;;
  esac
else
  echo "ERROR: set CUIS_VM or CUIS_DEV_ROOT" >&2
  exit 1
fi

# Resolve image
if [[ -n "${CUIS_IMAGE:-}" ]]; then
  IMAGE_FILE="$CUIS_IMAGE"
elif [[ -n "${CUIS_DEV_ROOT:-}" ]]; then
  IMAGE_FILE="$(ls "$CUIS_DEV_ROOT/CuisImage/"Cuis*.image 2>/dev/null | head -1)"
  [[ -z "$IMAGE_FILE" ]] && { echo "ERROR: no .image found in $CUIS_DEV_ROOT/CuisImage/" >&2; exit 1; }
else
  echo "ERROR: set CUIS_IMAGE or CUIS_DEV_ROOT" >&2
  exit 1
fi

VM_ARGS="${CUIS_VM_ARGS:-${CUIS_VM_ARGUMENTS:-}}"

# Run from the repo root so DirectoryEntry currentDirectory resolves dist/ correctly
cd "$REPO_ROOT"
chmod +x "$CUIS_VM_BIN" 2>/dev/null || true

if [[ -n "$VM_ARGS" ]]; then
  read -r -a VM_ARGS_ARRAY <<< "$VM_ARGS"
  exec "$CUIS_VM_BIN" "${VM_ARGS_ARRAY[@]}" "$IMAGE_FILE" -s "$SCRIPT_DIR/run-tests.st"
else
  exec "$CUIS_VM_BIN" "$IMAGE_FILE" -s "$SCRIPT_DIR/run-tests.st"
fi
