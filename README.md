# ContextKit

[中文说明](README_cn.md)

ContextKit is a macOS Finder context-menu platform. Instead of collecting unrelated utilities in one menu, it treats the context menu as an extensible `Action` entry point shared by the host app, Finder extension, agent, CLI, and plugins.

The repository is structured as a real multi-target macOS project with local Swift packages, so product logic lives in shared modules rather than growing inside giant app-entry files.

## Current Scope

The current v1 implementation includes:

- Finder Sync as the context-menu entry point, filtered by monitored roots and context rules
- A host app with `Overview`, `Actions`, `Plugins`, `Workflows`, and `Settings`
- An agent that executes requests coming from Finder
- A CLI for running actions and workflows, installing plugins, listing plugins, and reading logs
- Shared core modules for manifests, context rules, execution, workflows, plugins, shared storage, IPC, and logging
- Built-in actions:
  - Copy Path
  - Copy Relative Path
  - Open in Terminal
  - Open in Editor
  - Copy MD5
  - Copy SHA256
  - Compress
  - Extract
- Official sample plugins:
  - `JSONFormat`
  - `Base64Encode`
  - `Base64Decode`

## Architecture

| Layer | Directory | Responsibility |
| --- | --- | --- |
| Host App | `Apps/ContextKitApp` | SwiftUI management UI, settings, plugin management, workflow authoring |
| Finder Extension | `Extensions/ContextKitFinderSync` | Finder entry point, menu bridging, selection reading, request dispatching |
| Agent | `Apps/ContextKitAgent` | Processes Finder requests asynchronously and writes back results |
| CLI | `Apps/contextkit-cli` | Argument parsing, validation, and console output |
| Shared Core | `Packages/ContextKitCore` | CoreModels, Manifest, ContextRules, Execution, Workflow, Plugin, Config, Store, Logging, IPC |
| Built-ins | `Packages/ContextKitBuiltins` | Independent built-in action implementations and registration |
| Plugin SDK | `Packages/ContextKitPluginSDK` | Minimal plugin contract for environment and output |
| Official Plugins | `Plugins/Official` | Official examples used to validate platform capabilities |

## Repository Layout

```text
ContextKit
├── Apps
│   ├── ContextKitApp
│   ├── ContextKitAgent
│   └── contextkit-cli
├── Extensions
│   └── ContextKitFinderSync
├── Packages
│   ├── ContextKitCore
│   ├── ContextKitBuiltins
│   └── ContextKitPluginSDK
├── Plugins
│   └── Official
├── Support
│   ├── Entitlements
│   ├── Plists
│   └── Scripts
└── project.yml
```

`project.yml` is the source of truth. `ContextKit.xcodeproj` is generated from it with `xcodegen`.

## Requirements

- macOS 15.7+
- Xcode 26.3+ or another Swift 6 compatible toolchain
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

Install `xcodegen`:

```bash
brew install xcodegen
```

## Local Development

### 1. Generate the project

```bash
xcodegen generate
```

### 2. Open the project

```bash
open ContextKit.xcodeproj
```

### 3. Run package tests

```bash
swift test --package-path Packages/ContextKitCore
swift test --package-path Packages/ContextKitBuiltins
swift test --package-path Packages/ContextKitPluginSDK
```

### 4. Build the targets

Build the host app:

```bash
xcodebuild \
  -project ContextKit.xcodeproj \
  -scheme ContextKit \
  -configuration Debug \
  -destination 'platform=macOS' \
  build
```

Build the agent:

```bash
xcodebuild \
  -project ContextKit.xcodeproj \
  -scheme ContextKitAgent \
  -configuration Debug \
  -destination 'platform=macOS' \
  build
```

Build the CLI:

```bash
xcodebuild \
  -project ContextKit.xcodeproj \
  -scheme contextkit \
  -configuration Debug \
  build
```

### 5. Debugging notes

- The host app owns monitored-root configuration, plugin management, and workflow authoring. Start by adding monitored roots in `Settings`.
- Language can be overridden from `Settings` -> `Language`; the default is `System Default`.
- After installing the app, enable the `ContextKit` Finder extension in macOS System Settings before expecting the menu to appear in Finder.
- Finder Sync only appears inside monitored roots. That is a product boundary, not a temporary limitation.
- The Finder extension only reads cache and dispatches requests. It does not execute plugins or scripts directly.
- To validate the Finder -> Agent flow locally, run `ContextKitAgent` first and then trigger actions from Finder.
- The CLI reuses the same shared core logic instead of copying execution code.

### Finder menu troubleshooting

If `ContextKit` does not appear in Finder after installation, check the following:

1. Open `ContextKit.app` once so it can bootstrap shared state and refresh the menu cache.
2. In `Settings`, add at least one monitored root.
3. Enable the `ContextKit` Finder extension in macOS System Settings.
4. Right-click a file or folder inside one of the monitored roots.

### 6. Common CLI commands

```bash
contextkit run <action-id> <path...>
contextkit workflow run <workflow-id> <path...>
contextkit plugin install <local-path|git-url>
contextkit plugin list
contextkit logs tail
```

## Packaging

The repository provides a single distribution script:

```bash
./Support/Scripts/build-distribution.sh
```

It performs:

1. Tool checks
2. `xcodegen` project generation
3. `Release` builds for `ContextKit`, `ContextKitAgent`, and `contextkit`
4. Staging a single installable DMG
5. SHA256 checksum generation

Default outputs:

- `dist/ContextKit.dmg`
- `dist/SHA256SUMS.txt`

The DMG contains:

- `ContextKit.app`
- `/Applications` shortcut

`ContextKitAgent.app` is embedded inside `ContextKit.app`, so end users only need to drag a single app into `/Applications`. The host app launches the embedded agent on startup, while local development builds can still run the standalone `ContextKitAgent.app` from Xcode.

Optional environment variables:

```bash
CONFIGURATION=Release
DIST_DIR=/absolute/path/to/dist
DERIVED_DATA_PATH=/absolute/path/to/DerivedData
DESTINATION='platform=macOS'
DMG_NAME=ContextKit.dmg
DMG_VOLUME_NAME=ContextKit
```

Notes:

- Local distribution builds sign the app by default so the embedded Finder extension and App Group container can register correctly on macOS.
- Set `DISTRIBUTION_CODE_SIGNING_ALLOWED=NO` only for internal CI validation. Unsigned artifacts are not suitable for validating Finder extension visibility or shared-container behavior.
- Production distribution still needs proper Developer ID signing and notarization.

## Finder Sync and Shared State

`ContextKitApp`, `ContextKitFinderSync`, and `ContextKitAgent` share state through an App Group directory. The shared area contains:

- `settings.json`
- `menu-descriptors.json`
- `Workflows/`
- `Plugins/`
- `Requests/`
- `Responses/`
- `execution-log.json`

This means:

- The app updates settings and menu descriptors, while Finder reads the cached menu model
- Finder dispatches requests through shared request files, and the agent processes them
- Logs, plugin installation state, and workflows stay consistent across all entry points

## Data Storage

Runtime data is resolved by `SharedDirectoryProvider` in `ContextKitCore`.

Preferred location for signed builds:

- `~/Library/Group Containers/<TeamID>.ci.nn.ContextKit/`

Compatibility and fallback locations:

- `~/Library/Group Containers/group.ci.nn.ContextKit/`
- `~/Library/Application Support/ContextKitShared/`

The store currently contains:

- `settings.json`
- `menu-descriptors.json`
- `execution-log.json`
- `Workflows/`
- `Plugins/`
- `Requests/`
- `Responses/`

`<TeamID>` comes from the signing identity used at build time. In this repository's default local setup it resolves to `6UKCRW5N6G`, so the signed path becomes `~/Library/Group Containers/6UKCRW5N6G.ci.nn.ContextKit/`.

If the preferred App Group container becomes available after earlier fallback-based runs, ContextKit migrates the shared data forward automatically.

If the app group container is unavailable in a local development environment, ContextKit automatically falls back to the `Application Support` path above.

## Engineering Principles

- Entry targets should keep only lifecycle and composition code
- Shared business logic belongs in `Packages/ContextKitCore`
- Built-in actions should stay isolated instead of collapsing into one god file
- Finder Extension is only an entry point, not the execution runtime
- The README and the build script should stay aligned with the actual developer workflow

## Localization

The project currently ships with English and Simplified Chinese. The default language follows the system language, and users can override it in the app settings. User-facing copy is centralized in:

- `Packages/ContextKitCore/Sources/ContextKitCore/Resources/en.lproj/Localizable.strings`
- `Packages/ContextKitCore/Sources/ContextKitCore/Resources/zh-Hans.lproj/Localizable.strings`

The host app, Finder extension, CLI, built-in actions, and core error messages all read localized strings through the shared `L10n` helper in `ContextKitCore`.

To contribute another language:

1. Copy an existing `Localizable.strings` file into a new `*.lproj` folder, for example `ja.lproj/Localizable.strings`
2. Keep all keys unchanged and translate only the values
3. Add the language to `Packages/ContextKitCore/Sources/ContextKitCore/ConfigKit/AppLanguage.swift`
4. Update `Packages/ContextKitCore/Sources/ContextKitCore/Localization/LocalizationBundleResolver.swift`
5. Update `Apps/ContextKitApp/Features/Settings/AppLanguage+DisplayName.swift`
6. Run package tests and do a quick smoke test in the app and CLI
7. Mention the locale identifier and the validated areas in your pull request
