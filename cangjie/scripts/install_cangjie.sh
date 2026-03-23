#!/bin/bash
set -e

# 定义版本号 (可以通过 Dockerfile 传入或硬编码)
CANGJIE_VERSION="1.1.0-beta.24"
SRC_DIR="/tmp/cangjie_src"
INSTALL_DIR="$HOME/cangjie"
WORKSPACE_DIR="/home/dev/workspace"

SDK_aarch64="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-aarch64-1.1.0-beta.24.tar.gz&objectKey=69c1028a6e8ed61e6e07fd35"
SDK_x86_64="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-x64-1.1.0-beta.24.tar.gz&objectKey=69c102166e8ed61e6e07fd34"

echo "当前系统架构: $(uname -m)"

# 1. 根据架构选择对应的 SDK 包
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        wget $SDK_x86_64 -O $SRC_DIR/cangjie-sdk-linux-x64-${CANGJIE_VERSION}.tar.gz
        SDK_FILE="cangjie-sdk-linux-x64-${CANGJIE_VERSION}.tar.gz"
        ;;
    aarch64)
        wget $SDK_aarch64 -O $SRC_DIR/cangjie-sdk-linux-aarch64-${CANGJIE_VERSION}.tar.gz
        SDK_FILE="cangjie-sdk-linux-aarch64-${CANGJIE_VERSION}.tar.gz"
        ;;
    *)
        echo "不支持的架构: $ARCH"
        exit 1
        ;;
esac

echo "准备安装 SDK: $SDK_FILE"

# 2. 创建目标目录
mkdir -p "$INSTALL_DIR"
mkdir -p "$WORKSPACE_DIR"

# 3. 解压 SDK 到 $HOME/cangjie
# 注意：SDK 压缩包内部通常有一层目录结构，strip-components=1 是为了去掉外层目录，直接将内容解压到目标文件夹
# 如果官方包解压后没有外层目录，请去掉 --strip-components=1
if tar -tzf "$SRC_DIR/$SDK_FILE" | head -1 | grep -q "/$"; then
    # 如果第一行是目录，说明有外层包装
    tar -xzf "$SRC_DIR/$SDK_FILE" -C "$INSTALL_DIR" --strip-components=1
else
    # 否则直接解压
    tar -xzf "$SRC_DIR/$SDK_FILE" -C "$INSTALL_DIR"
fi

echo "SDK 解压完成。"

# 4. 配置环境变量到 ~/.zshrc
# 检查 envsetup.sh 是否存在
if [ -f "$INSTALL_DIR/envsetup.sh" ]; then
    echo "配置环境变量到 ~/.zshrc..."
    echo "" >> ~/.zshrc
    echo "# Cangjie Language Environment" >> ~/.zshrc
    echo "source \$HOME/cangjie/envsetup.sh" >> ~/.zshrc
else
    echo "警告: 未找到 $INSTALL_DIR/envsetup.sh，请手动配置环境变量。"
fi

# 5. 解压 VSCode 插件到 /home/dev/workspace
VSCODE_PLUGIN_FILE="cangjie-vscode-${CANGJIE_VERSION}.tar.gz"
wget "https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-vscode-1.1.0-beta.24.tar.gz&objectKey=69c1028a6e8ed61e6e07fd35" -O $SRC_DIR/$VSCODE_PLUGIN_FILE
if [ -f "$SRC_DIR/$VSCODE_PLUGIN_FILE" ]; then
    echo "解压 VSCode 插件..."
    tar -xzf "$SRC_DIR/$VSCODE_PLUGIN_FILE" -C "$WORKSPACE_DIR" --strip-components=1
    echo "VSCode 插件解压完成。"
else
    echo "未找到 VSCode 插件包: $VSCODE_PLUGIN_FILE，跳过。"
fi

echo "所有安装步骤已完成。"
