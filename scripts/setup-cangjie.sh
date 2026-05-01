#!/bin/bash
set -e

ARCH="$(dpkg --print-architecture)"
case "$ARCH" in
    amd64)
        SDK_URL="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-x64-1.1.0.tar.gz&objectKey=69e9d50c21f5a8178d6fd219"
        STDX_URL="https://gitcode.com/Cangjie/cangjie_stdx/releases/download/v1.1.0.1/cangjie-stdx-linux-x64-1.1.0.1.zip"
        ;;
    arm64)
        SDK_URL="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-aarch64-1.1.0.tar.gz&objectKey=69e9d37021f5a8178d6fd216"
        STDX_URL="https://gitcode.com/Cangjie/cangjie_stdx/releases/download/v1.1.0.1/cangjie-stdx-linux-aarch64-1.1.0.1.zip"
        ;;
esac

curl -fSL "$SDK_URL" | tar -xz

mkdir -p cangjie_stdx
curl -fSL "$STDX_URL" | unzip -o -j -d cangjie_stdx || echo "STDX download failed, skipping..."

echo "Cangjie SDK and STDX installed successfully"
