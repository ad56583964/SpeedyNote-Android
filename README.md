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

## 使用 Android SDK 将 APK 安装到设备

前提：

- 已经完成上面的构建流程，生成了 NoteApp 的 APK（容器构建时，产物会写回宿主机的 `build/android-armv8/build/Debug/...`）。
- 本机已安装 Android SDK，并确保 `adb` 在 `PATH` 中（通常位于 `$ANDROID_SDK_ROOT/platform-tools/adb`）。

一个集中示例（在 `android-conan` 根目录运行）：

```bash
# 1) 查看当前已连接的设备 / 模拟器
adb devices

# 2) 在构建输出目录中查找生成的 APK
find build/android-armv8/build/Debug -name "*.apk"

# 3) 安装或覆盖安装 APK（请替换为上一步查到的实际路径）
adb install -r path/to/NoteApp-debug.apk

# 4) 可选：卸载应用（需要知道应用包名）
adb uninstall <应用包名>
```

### 使用 adb 连接设备（USB / Wi‑Fi 调试）

1. 在真机上启用开发者选项与 USB 调试  
   - 设置 → 关于手机 → 连续点击“版本号”若干次，开启开发者选项；  
   - 设置 → 系统 → 开发者选项 → 打开“USB 调试”。  

2. （USB 方式）使用数据线连接设备  
   - 连接后执行：

     ```bash
     adb devices
     ```

   - 确认列表中有一个 `device` 状态的设备（首次连接手机上会弹框让你确认授权）。  

3. （可选）Wi‑Fi 调试方式（Android 11+，使用 Wireless debugging）  
   - 在设备上：设置 → 系统 → 开发者选项 → 打开“无线调试（Wireless debugging）”；  
   - 点进“无线调试”，选择“使用配对码配对设备”或类似选项：  
     - 记录显示的 **配对地址**（例如 `192.168.1.10:37173`）和 **配对码**。  
   - 在 PC 上执行配对：

     ```bash
     # 使用手机上显示的配对地址
     adb pair 192.168.1.10:37173
     # 按提示输入配对码
     ```

   - 配对成功后，设备界面会再显示一个“IP 地址与端口”（例如 `192.168.1.10:39615`），用来建立实际调试连接：

     ```bash
     adb connect 192.168.1.10:39615
     adb devices
     ```

   - 确认设备以 `device` 状态出现在 `adb devices` 列表中，即表示通过 Wi‑Fi 连接成功。  

4. 在构建输出目录中查找生成的 APK（以 NoteApp 为例）：

   ```bash
   find build/android-armv8/build/Debug -name "*.apk"
   ```

   你会看到类似 `NoteApp` 相关的 `*-debug.apk` 文件路径。

5. 使用 `adb install` 安装到当前连接的设备（`-r` 表示覆盖安装）：

   ```bash
   adb install -r path/to/NoteApp-debug.apk
   ```

   将 `path/to/NoteApp-debug.apk` 替换为第 4 步中实际查到的 APK 路径。

6. 如需卸载，可使用：

   ```bash
   adb uninstall <应用包名>
   ```

   应用包名由 SpeedyNote 的 Android 清单决定（例如 `org.example.NoteApp` 等），可通过安装后的：

   ```bash
   adb shell pm list packages | grep note
   ```

   等方式定位。

### 多设备 / 模拟器同时连接时的注意事项

当 `adb devices` 输出中有多条 `device` 条目时，直接执行 `adb install` 会出现：

```text
adb: more than one device/emulator
```

此时需要显式指定要安装到哪一个设备，或先断开多余连接。例如：

```bash
# 指定某个设备（序列号来自 adb devices 输出）
adb -s 192.168.10.7:45511 install -r path/to/NoteApp-debug.apk

# 或先断开所有 Wi‑Fi 连接，再只连一个
adb disconnect
adb connect 192.168.10.7:45511
adb install -r path/to/NoteApp-debug.apk
```
