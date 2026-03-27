#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_SPEC="$ROOT_DIR/project.yml"
PROJECT_FILE="$ROOT_DIR/ContextKit.xcodeproj"
CONFIGURATION="${CONFIGURATION:-Release}"
DIST_DIR="${DIST_DIR:-$ROOT_DIR/dist}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$ROOT_DIR/build/DerivedData}"
APP_DESTINATION="${DESTINATION:-platform=macOS}"
PRODUCTS_DIR="$DERIVED_DATA_PATH/Build/Products/$CONFIGURATION"

log() {
  printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"
}

require_tool() {
  local tool="$1"
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'Missing required tool: %s\n' "$tool" >&2
    exit 1
  fi
}

build_app_scheme() {
  local scheme="$1"
  log "Building scheme: $scheme ($CONFIGURATION)"
  xcodebuild \
    -project "$PROJECT_FILE" \
    -scheme "$scheme" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -destination "$APP_DESTINATION" \
    CODE_SIGNING_ALLOWED=NO \
    build
}

build_cli_scheme() {
  local scheme="$1"
  log "Building scheme: $scheme ($CONFIGURATION)"
  xcodebuild \
    -project "$PROJECT_FILE" \
    -scheme "$scheme" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    CODE_SIGNING_ALLOWED=NO \
    build
}

package_app() {
  local bundle_name="$1"
  local archive_name="$2"
  local bundle_path="$PRODUCTS_DIR/$bundle_name"

  if [[ ! -d "$bundle_path" ]]; then
    printf 'Expected app bundle not found: %s\n' "$bundle_path" >&2
    exit 1
  fi

  log "Packaging $bundle_name -> $archive_name"
  ditto -c -k --sequesterRsrc --keepParent "$bundle_path" "$DIST_DIR/$archive_name"
}

package_binary() {
  local binary_name="$1"
  local archive_name="$2"
  local binary_path="$PRODUCTS_DIR/$binary_name"

  if [[ ! -f "$binary_path" ]]; then
    printf 'Expected binary not found: %s\n' "$binary_path" >&2
    exit 1
  fi

  log "Packaging $binary_name -> $archive_name"
  tar -C "$PRODUCTS_DIR" -czf "$DIST_DIR/$archive_name" "$binary_name"
}

package_directory() {
  local source_dir="$1"
  local archive_name="$2"

  if [[ ! -d "$source_dir" ]]; then
    printf 'Expected directory not found: %s\n' "$source_dir" >&2
    exit 1
  fi

  log "Packaging $(basename "$source_dir") -> $archive_name"
  ditto -c -k --sequesterRsrc --keepParent "$source_dir" "$DIST_DIR/$archive_name"
}

write_checksums() {
  log "Writing SHA256SUMS.txt"
  (
    cd "$DIST_DIR"
    shasum -a 256 \
      ContextKit.app.zip \
      ContextKitAgent.app.zip \
      contextkit-macos.tar.gz \
      ContextKitOfficialPlugins.zip \
      > SHA256SUMS.txt
  )
}

main() {
  require_tool xcodegen
  require_tool xcodebuild
  require_tool ditto
  require_tool tar
  require_tool shasum

  mkdir -p "$DIST_DIR" "$DERIVED_DATA_PATH"
  find "$DIST_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

  log "Generating Xcode project from project.yml"
  xcodegen generate --spec "$PROJECT_SPEC"

  build_app_scheme "ContextKit"
  build_app_scheme "ContextKitAgent"
  build_cli_scheme "contextkit"

  package_app "ContextKit.app" "ContextKit.app.zip"
  package_app "ContextKitAgent.app" "ContextKitAgent.app.zip"
  package_binary "contextkit" "contextkit-macos.tar.gz"
  package_directory "$ROOT_DIR/Plugins/Official" "ContextKitOfficialPlugins.zip"
  find "$DIST_DIR" -name '.DS_Store' -delete
  write_checksums

  log "Distribution artifacts are ready in $DIST_DIR"
}

main "$@"
