# ContextKit

[English README](README.md)

ContextKit 是一个面向 macOS 的 Finder 右键能力平台。它不是把零散小工具堆进一个菜单里，而是把“右键”抽象成可扩展的 `Action` 执行入口，让宿主 App、Finder Extension、Agent、CLI 和插件共享同一套核心模型、规则与执行链路。

当前仓库已经按真实工程方式拆分为多 target + 本地 Swift Package，目标是长期维护，而不是把菜单构建、插件解析、执行器和 UI 状态全部塞进单文件。

## 当前范围

当前 v1 已落地的能力包括：

- Finder Sync 作为右键入口，按监控目录与上下文规则动态展示菜单
- 宿主 App 管理界面：概览、Actions、Plugins、Workflows、Settings
- Agent 负责处理 Finder Extension 发起的执行请求
- CLI 调试入口：运行 Action / Workflow、安装插件、列出插件、查看日志
- 共享 Core：Manifest、上下文规则、执行引擎、工作流、插件仓库、共享存储、IPC、日志
- 内置 Actions：
  - 复制路径
  - 复制相对路径
  - 在终端打开
  - 在编辑器打开
  - 复制 MD5
  - 复制 SHA256
  - 压缩
  - 解压
- 官方示例插件：
  - `JSONFormat`
  - `Base64Encode`
  - `Base64Decode`

## 架构分层

| 层 | 目录 | 责任 |
| --- | --- | --- |
| Host App | `Apps/ContextKitApp` | SwiftUI 管理界面、设置、插件管理、工作流编排 |
| Finder Extension | `Extensions/ContextKitFinderSync` | Finder 右键入口、菜单桥接、选择上下文读取、请求转发 |
| Agent | `Apps/ContextKitAgent` | 处理 Finder 发起的执行请求、异步执行、写回结果 |
| CLI | `Apps/contextkit-cli` | 命令解析、参数校验、输出格式化 |
| Shared Core | `Packages/ContextKitCore` | CoreModels、Manifest、ContextRules、Execution、Workflow、Plugin、Config、Store、Logging、IPC |
| Built-ins | `Packages/ContextKitBuiltins` | 内置 Action 的独立实现与注册 |
| Plugin SDK | `Packages/ContextKitPluginSDK` | 插件环境变量和输出契约 |
| Official Plugins | `Plugins/Official` | 官方示例插件和平台能力验证样板 |

## 目录结构

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

`project.yml` 是工程真源，`ContextKit.xcodeproj` 由 `xcodegen` 生成。

## 开发环境

- macOS 15.7+
- Xcode 26.3+ 或兼容 Swift 6 的 toolchain
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

安装 `xcodegen`：

```bash
brew install xcodegen
```

## 本地开发

### 1. 生成工程

```bash
xcodegen generate
```

### 2. 打开工程

```bash
open ContextKit.xcodeproj
```

### 3. 运行共享包测试

```bash
swift test --package-path Packages/ContextKitCore
swift test --package-path Packages/ContextKitBuiltins
swift test --package-path Packages/ContextKitPluginSDK
```

### 4. 构建各个 target

构建宿主 App：

```bash
xcodebuild \
  -project ContextKit.xcodeproj \
  -scheme ContextKit \
  -configuration Debug \
  -destination 'platform=macOS' \
  build
```

构建 Agent：

```bash
xcodebuild \
  -project ContextKit.xcodeproj \
  -scheme ContextKitAgent \
  -configuration Debug \
  -destination 'platform=macOS' \
  build
```

构建 CLI：

```bash
xcodebuild \
  -project ContextKit.xcodeproj \
  -scheme contextkit \
  -configuration Debug \
  build
```

### 5. 调试建议

- 宿主 App 负责设置监控目录、插件与工作流管理，首次启动后先在 `Settings` 中添加 monitored roots。
- 可在 `Settings` -> `Language` 中覆盖界面语言，默认会跟随系统语言。
- 安装应用后，需要先在 macOS 系统设置中启用 `ContextKit` 的 Finder 扩展，Finder 里才会出现对应菜单。
- Finder Sync 菜单只会在 monitored roots 内显示，这是产品边界的一部分，不会绕过。
- Finder Extension 自己不执行插件或脚本，只负责读取缓存和派发请求。
- 如果你要验证 Finder -> Agent 链路，请先运行 `ContextKitAgent`，再从 Finder 菜单触发 Action。
- CLI 直接复用共享 Core 执行，不复制业务逻辑。

### Finder 菜单排查

如果安装后 Finder 中看不到 `ContextKit`，请依次检查：

1. 先打开一次 `ContextKit.app`，让宿主 App 完成共享状态初始化并刷新菜单缓存。
2. 在 `Settings` 中至少添加一个监控目录。
3. 在 macOS 系统设置中启用 `ContextKit` 的 Finder 扩展。
4. 在上述某个监控目录内，对文件或文件夹执行右键。

### 6. 常用 CLI

```bash
contextkit run <action-id> <path...>
contextkit workflow run <workflow-id> <path...>
contextkit plugin install <local-path|git-url>
contextkit plugin list
contextkit logs tail
```

## 打包与分发构建

仓库内提供统一的分发脚本：

```bash
./Support/Scripts/build-distribution.sh
```

脚本会执行：

1. 校验依赖工具
2. 用 `xcodegen` 重新生成工程
3. 以 `Release` 配置构建 `ContextKit`、`ContextKitAgent`、`contextkit`
4. 生成单个可分发的 DMG 安装包
5. 生成 `SHA256SUMS.txt`

默认产物：

- `dist/ContextKit.dmg`
- `dist/SHA256SUMS.txt`

DMG 中包含：

- `ContextKit.app`
- `/Applications` 快捷方式

`ContextKitAgent.app` 会内嵌在 `ContextKit.app` 内，所以终端用户安装时只需要把一个 App 拖到 `/Applications`。宿主 App 启动时会自动拉起内嵌 agent；本地开发时仍然可以继续从 Xcode 单独运行 `ContextKitAgent.app`。

可选环境变量：

```bash
CONFIGURATION=Release
DIST_DIR=/absolute/path/to/dist
DERIVED_DATA_PATH=/absolute/path/to/DerivedData
DESTINATION='platform=macOS'
DMG_NAME=ContextKit.dmg
DMG_VOLUME_NAME=ContextKit
```

说明：

- CI 中的构建默认关闭代码签名：`CODE_SIGNING_ALLOWED=NO`
- 当前 Release 产物适合开发测试和内部验收；正式对外分发前通常还需要补签名与 notarization

## Finder Sync 与共享状态

`ContextKitApp`、`ContextKitFinderSync` 和 `ContextKitAgent` 通过 App Group 共享状态。共享目录中会保存：

- `settings.json`
- `menu-descriptors.json`
- `Workflows/`
- `Plugins/`
- `Requests/`
- `Responses/`
- `execution-log.json`

这意味着：

- App 修改设置后，Finder Extension 读取的是缓存后的菜单描述符
- Finder 点击菜单后，通过共享请求目录与 Agent 通信
- 日志、插件仓库和工作流定义在多入口之间保持一致

## 数据存储位置

运行时数据目录由 `ContextKitCore` 中的 `SharedDirectoryProvider` 统一解析。

优先位置：

- `~/Library/Group Containers/group.ci.nn.ContextKit/`

降级回退位置：

- `~/Library/Application Support/ContextKitShared/`

当前会写入的内容包括：

- `settings.json`
- `menu-descriptors.json`
- `execution-log.json`
- `Workflows/`
- `Plugins/`
- `Requests/`
- `Responses/`

如果在本地开发环境里 App Group 容器不可用，ContextKit 会自动回退到上面的 `Application Support` 路径。

## 开发原则

- 入口 target 只保留装配和生命周期代码
- 共享业务逻辑优先放进 `Packages/ContextKitCore`
- 内置 Actions 独立实现，不塞进统一 God file
- Finder Extension 只做入口，不做重执行逻辑
- README 与构建脚本使用同一套命令，尽量避免文档和实现漂移

## 国际化

当前仓库内置了英文和简体中文两套文案，默认跟随系统语言，用户也可以在设置页中手动切换。用户可见字符串统一收敛在：

- `Packages/ContextKitCore/Sources/ContextKitCore/Resources/en.lproj/Localizable.strings`
- `Packages/ContextKitCore/Sources/ContextKitCore/Resources/zh-Hans.lproj/Localizable.strings`

App、Finder Extension、CLI、Built-in Actions 和 Core 错误文案都通过 `ContextKitCore` 里的 `L10n` 共享访问。

如果你想贡献新的语言：

1. 复制一份现有的 `Localizable.strings` 到新的 `*.lproj` 目录，例如 `ja.lproj/Localizable.strings`
2. 保持 key 不变，只翻译 value
3. 运行共享包测试并至少本地打开一次 App / CLI 检查关键界面文案
4. 提交 PR 时说明新增的语言代码和已验证范围

只要遵守现有 key 约定，通常不需要改动 Swift 代码。
