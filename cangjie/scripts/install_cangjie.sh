#!/bin/zsh

# ==========================================
# 🟢 下载地址与目录配置区
# ==========================================

# 目录路径配置
SDK_DIR="$HOME/cangjie"
SDKX_DIR="$HOME/cangjie_sdkx"
WORKSPACE_DIR="/home/dev/workspace"

# 通用文件下载链接
VSCODE_PLUGIN_URI="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-vscode-1.1.0-beta.24.tar.gz&objectKey=69c100eb6e8ed61e6e07fd2f"

# AMD64 (x86_64) 架构下载链接
SDK_AMD64_URI="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-x64-1.1.0-beta.24.tar.gz&objectKey=69c102166e8ed61e6e07fd34"
SDKX_AMD64_URI="https://gitcode.com/Cangjie/cangjie_stdx/releases/download/v1.1.0-beta.24.1/cangjie-stdx-linux-x64-1.1.0-beta.24.1.zip"

# ARM64 (aarch64) 架构下载链接
SDK_ARM64_URI="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-aarch64-1.1.0-beta.24.tar.gz&objectKey=69c1028a6e8ed61e6e07fd35"
SDKX_ARM64_URI="https://gitcode.com/Cangjie/cangjie_stdx/releases/download/v1.1.0-beta.24.1/cangjie-stdx-linux-x64-1.1.0-beta.24.1.zip"

# ==========================================
# ⚙️ 脚本执行逻辑区
# ==========================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检测系统架构
detect_architecture() {
    local arch=$(uname -m)
    
    case $arch in
        x86_64|amd64) echo "x86_64" ;;
        aarch64|arm64) echo "aarch64" ;;
        *) 
            print_error "不支持的系统架构: $arch" 
            exit 1 
            ;;
    esac
}

# 下载文件函数
download_file() {
    local url="$1"
    local output_file="$2"
    local description="$3"
    
    print_info "正在下载 $description ..."
    
    if curl -L -o "$output_file" "$url" --silent --show-error --fail; then
        print_info "下载完成: $(basename "$output_file")"
        return 0
    else
        print_error "下载失败: $description"
        return 1
    fi
}

# 解压文件函数
extract_file() {
    local archive=$1
    local destination=$2
    local description=$3
    
    print_info "正在解压 $description ..."
    
    if [[ "$archive" == *.tar.gz ]]; then
        if tar -xzf "$archive" -C "$destination" --strip-components=1 2>/dev/null; then
            print_info "解压完成"
            return 0
        fi
    elif [[ "$archive" == *.zip ]]; then
        if unzip -q "$archive" -d "$destination" 2>/dev/null; then
            print_info "解压完成"
            return 0
        fi
    fi
    
    print_error "解压失败: $description"
    return 1
}

# 配置环境变量
configure_environment() {
    print_info "配置环境变量..."
    
    local shell_rc="$HOME/.zshrc"
    local hw_arch=$(detect_architecture)

    # 构建环境变量配置块
    local env_config_block=$(cat << ENV_EOF

# ⚠️ 以下由仓颉安装脚本自动生成
export CANGJIE_HOME="$SDK_DIR"
export CANGJIE_SDKX_HOME="$SDKX_DIR"
export PATH="\${CANGJIE_HOME}/bin:\${CANGJIE_HOME}/tools/bin:\$PATH:\$HOME/.cjpm/bin"
export LD_LIBRARY_PATH="\$PYTHON_LIB:\${CANGJIE_HOME}/runtime/lib/linux_${hw_arch}_cjnative:\${CANGJIE_HOME}/tools/lib:\$CANGJIE_STDX_HOME/linux_${hw_arch}_cjnative/static/stdx${LD_LIBRARY_PATH:+:LD_LIBRARY_PATH}"

compdef _gnu_generic cjc cjc-frontend
ENV_EOF
)
    
    # 检查并处理现有配置
    if grep -q "CANGJIE_HOME" "$shell_rc" 2>/dev/null; then
        print_warning "检测到已存在的CANGJIE_HOME配置"
        
        # 直接删除旧配置块
        if sed -i '/^# .* 仓颉安装脚本自动生成$/,/^export LD_LIBRARY_PATH.*cjnative.*$/d' "$shell_rc" 2>/dev/null; then
            print_info "旧配置已删除"
        else
            print_error "删除旧配置失败，请手动编辑 $shell_rc"
            exit 1
        fi
    fi
    
    # 添加新配置
    echo "$env_config_block" >> "$shell_rc"
    print_info "环境变量已写入 $shell_rc"
}

# 主函数
main() {
    echo "========================================"
    echo "     仓颉编程语言自动安装脚本           "
    echo "========================================"
    echo ""

    # 2. 检测架构
    ARCH=$(detect_architecture)
    
    # 3. 设置下载链接
    case $ARCH in
        x86_64)
            SDK_URL="$SDK_AMD64_URI"
            SDKX_URL="$SDKX_AMD64_URI"
            ;;
        aarch64)
            SDK_URL="$SDK_ARM64_URI"
            SDKX_URL="$SDKX_ARM64_URI"
            ;;
        *)
            print_error "无法为架构 '$ARCH' 设置下载链接"
            exit 1
            ;;
    esac
    
    # 4. 打印配置信息
    print_info "安装配置:"
    print_info "  架构:      $ARCH"
    print_info "  SDK路径:   $SDK_DIR"
    print_info "  标准库路径: $SDKX_DIR"
    
    # 5. 创建目录
    mkdir -p "$SDK_DIR" "$SDKX_DIR" "$WORKSPACE_DIR"
    
    # 6. 创建临时目录并下载
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR" || exit 1
    
    download_file "$SDK_URL" "sdk.tar.gz" "仓颉SDK" || exit 1
    download_file "$SDKX_URL" "sdkx.zip" "仓颉标准库" || exit 1
    download_file "$VSCODE_PLUGIN_URI" "vscode.tar.gz" "VSCode插件" || exit 1
    
    # 7. 解压文件
    extract_file "sdk.tar.gz" "$SDK_DIR" "仓颉SDK" || exit 1
    extract_file "sdkx.zip" "$SDKX_DIR" "仓颉标准库" || exit 1
    extract_file "vscode.tar.gz" "$WORKSPACE_DIR" "VSCode插件" || print_warning "VSCode插件解压失败，可手动处理"
    
    # 8. 配置环境变量
    configure_environment
    
    # 9. 清理临时文件
    cd - || exit 1
    rm -rf "$TEMP_DIR"
    
    # 10. 验证安装
    print_info "验证安装..."
    if [ -f "$SDK_DIR/bin/cjc" ]; then
        print_info "✅ 仓颉编译器安装成功"
    else
        print_warning "⚠️ 未找到编译器，可能需要手动检查"
    fi
    
    # 11. 完成提示
    echo ""
    print_info "🎉 安装完成！"
    echo ""
    echo "📦 后续步骤："
    echo "  1. 重启终端或运行: source ~/.zshrc"
    echo "  2. 验证安装: cjc --version"
    echo "  3. 安装VSCode插件 (如有下载)"
    echo ""
    echo "💡 提示: 如需卸载，请删除 $SDK_DIR, $SDKX_DIR 并检查 ~/.zshrc"
    echo ""
}

main
