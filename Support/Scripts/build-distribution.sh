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
DISTRIBUTION_CODE_SIGNING_ALLOWED="${DISTRIBUTION_CODE_SIGNING_ALLOWED:-YES}"
DISTRIBUTION_POST_SIGN_IDENTITY="${DISTRIBUTION_POST_SIGN_IDENTITY:-}"

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
    CODE_SIGNING_ALLOWED="$DISTRIBUTION_CODE_SIGNING_ALLOWED" \
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
    CODE_SIGNING_ALLOWED="$DISTRIBUTION_CODE_SIGNING_ALLOWED" \
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

read_bundle_app_group_identifier() {
  local bundle_path="$1"
  local info_plist="$bundle_path/Contents/Info.plist"

  if [[ ! -f "$info_plist" ]]; then
    printf 'Expected Info.plist not found: %s\n' "$info_plist" >&2
    exit 1
  fi

  /usr/libexec/PlistBuddy -c "Print :ContextKitAppGroupIdentifier" "$info_plist"
}

write_entitlements_file() {
  local output_path="$1"
  local app_group_identifier="$2"
  local sandbox_enabled="${3:-NO}"

  rm -f "$output_path"
  /usr/libexec/PlistBuddy -c "Add :com.apple.security.application-groups array" "$output_path"
  /usr/libexec/PlistBuddy -c "Add :com.apple.security.application-groups:0 string $app_group_identifier" "$output_path"

  if [[ "$sandbox_enabled" == "YES" ]]; then
    /usr/libexec/PlistBuddy -c "Add :com.apple.security.app-sandbox bool true" "$output_path"
  fi
}

codesign_bundle() {
  local bundle_path="$1"
  local entitlements_path="$2"

  if [[ ! -e "$bundle_path" ]]; then
    printf 'Expected bundle not found for signing: %s\n' "$bundle_path" >&2
    exit 1
  fi

  log "Signing $(basename "$bundle_path")"
  codesign \
    --force \
    --options runtime \
    --sign "$DISTRIBUTION_POST_SIGN_IDENTITY" \
    --entitlements "$entitlements_path" \
    "$bundle_path"
}

post_sign_distribution_app() {
  local app_bundle="$1"

  if [[ -z "$DISTRIBUTION_POST_SIGN_IDENTITY" ]]; then
    if [[ "$DISTRIBUTION_CODE_SIGNING_ALLOWED" == "NO" ]]; then
      DISTRIBUTION_POST_SIGN_IDENTITY="-"
    else
      log "Skipping post-sign step because DISTRIBUTION_POST_SIGN_IDENTITY is empty"
      return
    fi
  fi

  local temp_signing_dir
  temp_signing_dir="$(mktemp -d "${TMPDIR:-/tmp}/contextkit-signing.XXXXXX")"

  local host_group_id
  local agent_group_id
  local finder_group_id

  host_group_id="$(read_bundle_app_group_identifier "$app_bundle")"
  agent_group_id="$(read_bundle_app_group_identifier "$app_bundle/Contents/Library/LoginItems/ContextKitAgent.app")"
  finder_group_id="$(read_bundle_app_group_identifier "$app_bundle/Contents/PlugIns/ContextKitFinderSync.appex")"

  local host_entitlements="$temp_signing_dir/ContextKit.entitlements"
  local agent_entitlements="$temp_signing_dir/ContextKitAgent.entitlements"
  local finder_entitlements="$temp_signing_dir/ContextKitFinderSync.entitlements"

  write_entitlements_file "$host_entitlements" "$host_group_id"
  write_entitlements_file "$agent_entitlements" "$agent_group_id"
  write_entitlements_file "$finder_entitlements" "$finder_group_id" "YES"

  codesign_bundle "$app_bundle/Contents/PlugIns/ContextKitFinderSync.appex" "$finder_entitlements"
  codesign_bundle "$app_bundle/Contents/Library/LoginItems/ContextKitAgent.app" "$agent_entitlements"
  codesign_bundle "$app_bundle" "$host_entitlements"

  log "Verifying staged app signature"
  codesign --verify --deep --strict --verbose=2 "$app_bundle"
  rm -rf "$temp_signing_dir"
}

embed_agent_in_app_bundle() {
  local app_bundle="$1"
  local agent_bundle="$PRODUCTS_DIR/ContextKitAgent.app"
  local login_items_dir="$app_bundle/Contents/Library/LoginItems"
  local embedded_agent_bundle="$login_items_dir/ContextKitAgent.app"

  if [[ ! -d "$app_bundle" ]]; then
    printf 'Expected host app bundle not found: %s\n' "$app_bundle" >&2
    exit 1
  fi

  if [[ ! -d "$agent_bundle" ]]; then
    printf 'Expected agent app bundle not found: %s\n' "$agent_bundle" >&2
    exit 1
  fi

  log "Embedding ContextKitAgent.app inside ContextKit.app"
  mkdir -p "$login_items_dir"
  rm -rf "$embedded_agent_bundle"
  ditto "$agent_bundle" "$embedded_agent_bundle"
}

stage_distribution_root() {
  log "Preparing DMG staging directory"
  rm -rf "$DMG_STAGE_DIR"
  mkdir -p "$DMG_STAGE_DIR"

  copy_app_bundle "ContextKit.app" "$DMG_STAGE_DIR"
  embed_agent_in_app_bundle "$DMG_STAGE_DIR/ContextKit.app"
  post_sign_distribution_app "$DMG_STAGE_DIR/ContextKit.app"

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
  require_tool codesign

  mkdir -p "$DIST_DIR" "$DERIVED_DATA_PATH"
  find "$DIST_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

  log "Distribution code signing allowed: $DISTRIBUTION_CODE_SIGNING_ALLOWED"
  if [[ "$DISTRIBUTION_CODE_SIGNING_ALLOWED" == "NO" ]] && [[ -z "$DISTRIBUTION_POST_SIGN_IDENTITY" ]]; then
    log "Distribution post-sign identity: - (ad-hoc)"
  elif [[ -n "$DISTRIBUTION_POST_SIGN_IDENTITY" ]]; then
    log "Distribution post-sign identity: $DISTRIBUTION_POST_SIGN_IDENTITY"
  else
    log "Distribution post-sign identity: skipped"
  fi

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
