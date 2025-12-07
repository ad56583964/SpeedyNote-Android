# android-conan

## 背景

`android-conan` 是 SpeedyNote 的 Android 构建工程，用于在统一的 Docker 环境中，为 Android/arm64 编译并打包 NoteApp。

整体思路：先准备构建环境镜像 → 进入镜像 → 在镜像中按步骤执行构建命令，最终得到 APK。

## 获取 SpeedyNote 源码

- 推荐在 `android-conan` 根目录下执行：
  - `make speedynote-clone`（从 `https://github.com/ad56583964/SpeedyNote.git` 克隆 SpeedyNote 到本仓库的 `SpeedyNote/` 目录，默认分支为 `android/poppler-reorg`）
- 或手动执行：
  - `git clone -b android/poppler-reorg https://github.com/ad56583964/SpeedyNote.git SpeedyNote`

`SpeedyNote/` 目录已在本仓库的 `.gitignore` 中忽略，建议作为独立的 git 仓库维护。如果你已经在其他位置有本地 SpeedyNote 副本，也可以在配置/构建时通过 `-D SPEEDYNOTE_SRC_DIR=/path/to/SpeedyNote` 显式指定源码位置。

## 正常构建 SpeedyNote（NoteApp）的流程

- 宿主机上：`make build-image` → `make enter-container`
  - `make build-image`（构建或更新一个标准的 Android + Qt + Conan 构建环境镜像，后续所有步骤都复用这个镜像）
  - `make enter-container`（基于这个镜像启动一个容器，并进入到工程目录，在这个干净且统一的环境中进行后续构建）

- 容器里：
  1）`make in-conan`（准备工程所需依赖和交叉编译所需的基础配置）
  2）`make in-build-poppler`（为 Android 构建出 SpeedyNote 需要的 Poppler 环境，形成可复用的 PDF 支持）
  3）`make in-configure`（把 SpeedyNote 项目、前面准备好的依赖、Qt 和 Android 环境串联起来，生成可用于构建 Android 应用的工程配置）
  4）`make in-apk`（在上述配置基础上编译 NoteApp 并打包成 APK，得到可安装到设备或模拟器上的应用）

- 快捷方式（容器里，Poppler 已经准备好的情况下）：
  - `make in-build`（一步完成依赖准备、工程配置和 APK 构建，适合作为日常迭代时的一键构建命令）
