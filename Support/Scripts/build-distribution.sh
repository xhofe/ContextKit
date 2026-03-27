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
DMG_STAGE_DIR="${DMG_STAGE_DIR:-$ROOT_DIR/build/DistributionRoot}"
DMG_NAME="${DMG_NAME:-ContextKit.dmg}"
DMG_VOLUME_NAME="${DMG_VOLUME_NAME:-ContextKit}"

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

copy_app_bundle() {
  local bundle_name="$1"
  local destination_dir="$2"
  local bundle_path="$PRODUCTS_DIR/$bundle_name"

  if [[ ! -d "$bundle_path" ]]; then
    printf 'Expected app bundle not found: %s\n' "$bundle_path" >&2
    exit 1
  fi

  log "Staging $bundle_name"
  ditto "$bundle_path" "$destination_dir/$bundle_name"
}

copy_binary() {
  local binary_name="$1"
  local destination_path="$2"
  local binary_path="$PRODUCTS_DIR/$binary_name"

  if [[ ! -f "$binary_path" ]]; then
    printf 'Expected binary not found: %s\n' "$binary_path" >&2
    exit 1
  fi

  log "Staging $binary_name"
  cp "$binary_path" "$destination_path"
  chmod +x "$destination_path"
}

copy_directory() {
  local source_dir="$1"
  local destination_dir="$2"

  if [[ ! -d "$source_dir" ]]; then
    printf 'Expected directory not found: %s\n' "$source_dir" >&2
    exit 1
  fi

  log "Staging $(basename "$source_dir")"
  ditto "$source_dir" "$destination_dir"
}

stage_distribution_root() {
  log "Preparing DMG staging directory"
  rm -rf "$DMG_STAGE_DIR"
  mkdir -p "$DMG_STAGE_DIR/Extras/CLI" "$DMG_STAGE_DIR/Extras/Official Plugins"

  copy_app_bundle "ContextKit.app" "$DMG_STAGE_DIR"
  copy_app_bundle "ContextKitAgent.app" "$DMG_STAGE_DIR"
  copy_binary "contextkit" "$DMG_STAGE_DIR/Extras/CLI/contextkit"
  copy_directory "$ROOT_DIR/Plugins/Official" "$DMG_STAGE_DIR/Extras/Official Plugins"

  ln -s /Applications "$DMG_STAGE_DIR/Applications"
}

create_dmg() {
  local dmg_path="$DIST_DIR/$DMG_NAME"
  log "Creating DMG -> $DMG_NAME"
  hdiutil create \
    -volname "$DMG_VOLUME_NAME" \
    -srcfolder "$DMG_STAGE_DIR" \
    -format UDZO \
    -ov \
    "$dmg_path"
}

write_checksums() {
  log "Writing SHA256SUMS.txt"
  (
    cd "$DIST_DIR"
    shasum -a 256 \
      "$DMG_NAME" \
      > SHA256SUMS.txt
  )
}

main() {
  require_tool xcodegen
  require_tool xcodebuild
  require_tool ditto
  require_tool hdiutil
  require_tool shasum

  mkdir -p "$DIST_DIR" "$DERIVED_DATA_PATH"
  find "$DIST_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

  log "Generating Xcode project from project.yml"
  xcodegen generate --spec "$PROJECT_SPEC"

  build_app_scheme "ContextKit"
  build_app_scheme "ContextKitAgent"
  build_cli_scheme "contextkit"

  stage_distribution_root
  create_dmg
  find "$DIST_DIR" -name '.DS_Store' -delete
  write_checksums
  rm -rf "$DMG_STAGE_DIR"

  log "Distribution artifacts are ready in $DIST_DIR"
}

main "$@"
