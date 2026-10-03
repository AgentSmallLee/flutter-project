# Flutter 项目工程结构说明

> 项目名称：`flutter_project`
> Dart SDK：^3.13.5
> 版本号：1.0.0+1

---

## 一、整体目录结构

```
flutter_project/
├── android/              # Android 平台原生代码与配置
├── ios/                  # iOS 平台原生代码与配置
├── lib/                  # Dart 源代码（主要开发目录）
│   └── main.dart         # 应用入口文件
├── test/                 # 测试代码
├── build/                # 编译产物（自动生成，无需手动管理）
├── .dart_tool/           # Dart 工具缓存（自动生成）
├── .idea/                # Android Studio / IntelliJ 配置
├── pubspec.yaml          # 项目配置与依赖管理
├── pubspec.lock          # 依赖版本锁定文件
├── analysis_options.yaml # 静态代码分析规则配置
├── README.md             # 项目说明文档
└── .gitignore            # Git 忽略规则
```

---

## 二、核心目录详解

### 1. `lib/` — 主要开发目录

这是 Flutter 开发的核心工作目录，存放所有 Dart 源代码。

```
lib/
└── main.dart    # 应用入口，包含 main() 函数和根 Widget
```

- **main.dart**：程序入口。`main()` 函数调用 `runApp()` 启动 Flutter 应用。默认生成一个计数器示例页面。

> 💡 随着项目发展，通常会在 `lib/` 下进一步划分：
> - `models/` — 数据模型
> - `views/` / `screens/` — 页面
> - `widgets/` — 公共组件
> - `utils/` — 工具类
> - `services/` — 网络服务 / 数据服务
> - `providers/` / `state/` — 状态管理

---

### 2. `pubspec.yaml` — 项目配置与依赖管理

Flutter 项目的核心配置文件，类似 `package.json`（JS）或 `build.gradle`（Android）。

主要配置项：

| 配置项 | 说明 |
|--------|------|
| `name` | 项目名称（包名） |
| `description` | 项目描述 |
| `version` | 版本号，格式 `x.y.z+build` |
| `environment.sdk` | Dart SDK 版本约束 |
| `dependencies` | 项目运行依赖 |
| `dev_dependencies` | 开发时依赖（测试、代码规范等） |
| `flutter` | Flutter 专属配置（资源、字体等） |

当前项目依赖：
- `flutter` sdk — Flutter 框架
- `cupertino_icons: ^1.0.8` — iOS 风格图标库
- `flutter_test` — 测试框架
- `flutter_lints: ^6.0.0` — 代码规范检查

---

### 3. `android/` — Android 平台目录

存放 Android 平台的原生代码和资源配置。

```
android/
├── app/
│   ├── build.gradle.kts       # 应用级 Gradle 配置（Kotlin DSL）
│   └── src/
│       ├── main/
│       │   ├── AndroidManifest.xml    # Android 清单文件（权限、Activity等）
│       │   ├── kotlin/.../MainActivity.kt   # 主 Activity（Kotlin）
│       │   ├── java/.../GeneratedPluginRegistrant.java  # 插件注册（自动生成）
│       │   └── res/                    # 资源文件
│       │       ├── drawable*/          # 启动页背景
│       │       ├── mipmap-*/           # 应用图标（不同分辨率）
│       │       └── values/             # 主题样式
│       ├── debug/AndroidManifest.xml   # Debug 模式清单
│       └── profile/AndroidManifest.xml # Profile 模式清单
├── build.gradle.kts          # 项目级 Gradle 配置
├── settings.gradle.kts       # 项目模块设置
├── gradle.properties         # Gradle 属性配置
├── gradle/wrapper/           # Gradle Wrapper（统一版本）
├── gradlew / gradlew.bat     # Gradle 执行脚本
└── local.properties          # 本地 SDK 路径配置
```

关键点：
- **MainActivity.kt**：Android 原生入口，通常无需修改
- **AndroidManifest.xml**：配置应用权限、Activity、包名等
- **res/**：存放图标、启动页、主题等 Android 资源

---

### 4. `ios/` — iOS 平台目录

存放 iOS 平台的原生代码和资源配置。

```
ios/
├── Runner/                        # 主工程目录
│   ├── AppDelegate.swift          # 应用入口代理
│   ├── SceneDelegate.swift        # 场景代理（iOS 13+）
│   ├── Info.plist                 # 应用配置清单
│   ├── Base.lproj/                # 国际化界面文件
│   │   ├── LaunchScreen.storyboard # 启动页
│   │   └── Main.storyboard        # 主界面
│   ├── Assets.xcassets/           # 资源包
│   │   ├── AppIcon.appiconset/    # 应用图标
│   │   └── LaunchImage.imageset/  # 启动图片
│   └── GeneratedPluginRegistrant  # 插件注册（自动生成）
├── Runner.xcodeproj/              # Xcode 项目文件
├── Runner.xcworkspace/            # Xcode 工作区
├── RunnerTests/                   # iOS 单元测试
└── Flutter/
    ├── AppFrameworkInfo.plist
    ├── Debug.xcconfig             # Debug 编译配置
    ├── Release.xcconfig           # Release 编译配置
    └── ephemeral/                 # Flutter 临时生成文件
```

关键点：
- **Info.plist**：iOS 应用配置（权限、Bundle ID 等）
- **Assets.xcassets**：管理应用图标和启动图
- **Runner.xcworkspace**：使用 CocoaPods 时用这个打开项目

---

### 5. `test/` — 测试目录

```
test/
└── widget_test.dart    # Widget 测试示例
```

存放单元测试、Widget 测试、集成测试代码。使用 `flutter test` 运行。

---

## 三、配置与工具文件

| 文件 | 作用 |
|------|------|
| `pubspec.lock` | 锁定所有依赖的精确版本，保证团队协作一致 |
| `analysis_options.yaml` | Dart 静态分析规则，配置 lint 检查项 |
| `.gitignore` | 指定哪些文件不提交到 Git（构建产物、IDE配置等） |
| `.metadata` | Flutter 工具元数据，自动生成，不要手动改 |
| `README.md` | 项目说明文档 |
| `flutter_project.iml` | IntelliJ 模块文件 |
| `.idea/` | IDE 配置（运行配置、编辑器设置等） |

---

## 四、常用命令速查

```bash
# 获取依赖
flutter pub get

# 运行应用
flutter run                    # 默认设备
flutter run -d chrome          # 浏览器
flutter run -d macos           # macOS 桌面
flutter run -d <设备名>        # 指定设备

# 查看可用设备
flutter devices

# 查看/启动模拟器
flutter emulators
flutter emulators --launch <模拟器id>

# 运行测试
flutter test

# 检查环境
flutter doctor
```

---

## 五、当前项目状态

- ✅ 已配置 Android 平台（Kotlin + Gradle Kotlin DSL）
- ✅ 已配置 iOS 平台（Swift）
- ✅ 已配置 Web 平台（Chrome 可运行）
- ✅ 已配置 macOS 桌面平台
- 📦 仅有基础依赖，尚未添加第三方包
- 🎯 入口页面：默认计数器示例
