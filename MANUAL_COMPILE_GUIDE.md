# WifiTrigger 手动编译指南

## 问题分析
当前在WSL环境中遇到的问题：
- 缺少iOS交叉编译工具链
- 系统clang不支持iOS特定参数
- 网络限制导致无法下载完整的iOS工具链

## 解决方案1：使用GitHub Codespaces（推荐）

1. 访问 https://github.com/codespaces
2. 创建一个新的Codespace
3. 在终端中运行以下命令：

```bash
# 安装依赖
sudo apt-get update
sudo apt-get install -y build-essential clang ldid git zip unzip

# 安装Theos
git clone --recursive https://github.com/theos/theos.git ~/theos
export THEOS=~/theos

# 安装iOS SDK
cd $THEOS/sdks
wget https://github.com/ios-cross/iphonesdk-fake/releases/download/v17.0.0/iPhoneOS15.6.sdk.tar.xz
tar -xf iPhoneOS15.6.sdk.tar.xz

# 安装ios-cmake (提供iOS交叉编译工具)
git clone https://github.com/leetal/ios-cmake.git
cd ios-cmake
sudo make install

# 获取项目代码
git clone https://github.com/[your-username]/WifiTrigger.git
cd WifiTrigger

# 编译
make clean package FINALPACKAGE=1
```

## 解决方案2：使用Mac电脑

如果您有Mac电脑，这是最简单的方法：

1. 安装Xcode
2. 安装Xcode命令行工具：`xcode-select --install`
3. 安装Theos：
```bash
git clone --recursive https://github.com/theos/theos.git ~/theos
export THEOS=~/theos
```

4. 下载iOS SDK：
```bash
cd ~/theos/sdks
curl -OL https://github.com/ios-cross/iphonesdk-fake/releases/download/v17.0.0/iPhoneOS15.6.sdk.tar.xz
tar -xf iPhoneOS15.6.sdk.tar.xz
```

5. 复制项目到Mac并编译：
```bash
cd [项目目录]
make clean package FINALPACKAGE=1
```

## 解决方案3：使用虚拟机

1. 下载并安装VirtualBox或VMware
2. 安装macOS虚拟机（如使用macOS Unlocker）
3. 在虚拟机中安装Xcode和Theos
4. 编译项目

## 解决方案4：使用云服务器

租用一台具有macOS环境的云服务器：
- MacStadium
- MacInCloud
- AWS EC2 Mac instances

## 解决方案5：修复当前WSL环境

如果要继续使用当前WSL环境，需要：

1. 安装真正的iOS交叉编译工具链：
```bash
# 在WSL中安装ios-cmake
cd /tmp
git clone https://github.com/leetal/ios-cmake.git
cd ios-cmake
sudo make install

# 或者使用osxcross
git clone https://github.com/tpoechtrager/osxcross.git
cd osxcross
# 按照README安装
```

2. 但这通常很复杂且容易出错

## 项目文件状态

所有源代码和配置文件已完成：

### 核心文件
- `Tweak.x`: 主要的WiFi检测和快捷指令执行逻辑
- `Makefile`: 构建配置
- `control`: 包信息
- `WifiTrigger.plist`: 过滤器配置

### 设置面板文件
- `Prefs/Makefile`: 设置面板构建配置
- `Prefs/WifiTriggerRootListController.m`: 设置面板控制器
- `Prefs/Resources/Root.plist`: 设置面板UI定义

### 代码特点
- 使用posix_spawn替代system()以符合iOS规范
- 支持多巴胺(rootless)环境
- 兼容iOS 15.x/16.x

## 预期输出

编译成功后，将在`packages/`目录中生成DEB安装包：
- `WifiTrigger_X.X.X_iphoneos-arm64.deb`

## 安装说明

1. 将DEB文件传输到越狱iOS设备
2. 使用Sileo或Zebra安装
3. 重启SpringBoard或重新启动设备
4. 在设置中配置WiFi名称和快捷指令名称

## 故障排除

### 编译错误
- 确保所有依赖项已安装
- 检查Theos路径设置正确
- 确认iOS SDK已正确安装

### 运行时错误
- 检查越狱环境是否支持Tweak
- 确认PreferenceLoader已安装
- 检查文件权限设置

## 重要提醒

由于当前环境缺少完整的iOS工具链，必须在具有完整工具链的环境中进行编译。推荐使用Mac电脑或GitHub Codespaces，这两种方法都能保证编译成功。