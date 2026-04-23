#!/usr/bin/env sh
# =============================================================================
# install_cangjie.sh — 仓颉编程语言 SDK 自动安装脚本
#
# 兼容 Shell：sh / bash / zsh（推荐）
# Fish 用户请使用：bash install_cangjie.sh 或 sh install_cangjie.sh
#
# 用法：
#   sh install_cangjie.sh
#   SDK_DIR=/opt/cangjie sh install_cangjie.sh   # 自定义安装路径
# =============================================================================
set -eu  # 遇到错误立即退出，禁止使用未定义变量

# ==========================================
# 🟢 配置区（可通过环境变量覆盖）
# ==========================================
SDK_DIR="${SDK_DIR:-$HOME/cangjie}"
STDX_DIR="${STDX_DIR:-$HOME/cangjie_sdkx}"
WORKSPACE_DIR="${WORKSPACE_DIR:-/home/dev/workspace}"

# 下载地址
VSCODE_PLUGIN_URI="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-vscode-1.1.0-beta.25.tar.gz&objectKey=69cb70e16e8ed61e6e07fd3e"
SDK_AMD64_URI="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-x64-1.1.0-beta.25.tar.gz&objectKey=69cb718e6e8ed61e6e07fd42"
STDX_AMD64_URI="https://gitcode.com/Cangjie/cangjie_stdx/releases/download/v1.1.0-beta.25/cangjie-stdx-linux-x64-1.1.0-beta.25.1.zip"
SDK_ARM64_URI="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-aarch64-1.1.0-beta.25.tar.gz&objectKey=69cb74a76e8ed61e6e07fd45"
STDX_ARM64_URI="https://gitcode.com/Cangjie/cangjie_stdx/releases/download/v1.1.0-beta.25/cangjie-stdx-linux-aarch64-1.1.0-beta.25.1.zip"

# ==========================================
# 📦 引入公共工具库
# ==========================================
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/lib/common.sh"

# =============================================================================
# 配置环境变量（自动适配 Fish / Zsh / Bash / sh）
# =============================================================================
configure_environment() {
    _hw_arch="$1"    # x86_64 | aarch64
    _rc="$(get_shell_rc)"

    print_step "配置环境变量到 $_rc ..."

    if is_fish_rc "$_rc"; then
        # ── Fish 语法 ──────────────────────────────────────────────────────────
        # Fish 不支持 compdef，故省略 zsh 补全配置
        _block="# 仓颉 SDK
set -gx CANGJIE_HOME \"${SDK_DIR}\"
set -gx CANGJIE_STDX_HOME \"${STDX_DIR}\"
set -gx PATH \$CANGJIE_HOME/bin \$CANGJIE_HOME/tools/bin \$PATH \$HOME/.cjpm/bin
set -gx LD_LIBRARY_PATH \$PYTHON_LIB \$CANGJIE_HOME/runtime/lib/linux_${_hw_arch}_cjnative \$CANGJIE_HOME/tools/lib \$CANGJIE_STDX_HOME/linux_${_hw_arch}_cjnative/static/stdx \$LD_LIBRARY_PATH"
    else
        # ── POSIX sh / Bash / Zsh 语法 ─────────────────────────────────────────
        _block="# 仓颉 SDK
export CANGJIE_HOME=\"${SDK_DIR}\"
export CANGJIE_STDX_HOME=\"${STDX_DIR}\"
export PATH=\"\${CANGJIE_HOME}/bin:\${CANGJIE_HOME}/tools/bin:\$PATH:\$HOME/.cjpm/bin\"
export LD_LIBRARY_PATH=\"\${PYTHON_LIB:+\$PYTHON_LIB:}\${CANGJIE_HOME}/runtime/lib/linux_${_hw_arch}_cjnative:\${CANGJIE_HOME}/tools/lib:\${CANGJIE_STDX_HOME}/linux_${_hw_arch}_cjnative/static/stdx\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}\""

        # Zsh 下追加 compdef 补全（仅 zsh）
        case "$(basename "${SHELL:-sh}")" in
            zsh) _block="${_block}
# Zsh 补全
compdef _gnu_generic cjc cjc-frontend" ;;
        esac
    fi

    append_env_block "$_rc" "CANGJIE_ENV" "$_block"
}

# =============================================================================
# 主流程
# =============================================================================
main() {
    printf "\n%s========================================%s\n"    "${_C_BOLD}" "${_C_RESET}"
    printf   "%s  仓颉编程语言 SDK 自动安装脚本%s\n"           "${_C_BOLD}" "${_C_RESET}"
    printf   "%s========================================%s\n\n" "${_C_BOLD}" "${_C_RESET}"

    # ── 1. 检测架构 ─────────────────────────────────────────────────────────
    ARCH="$(detect_architecture)"

    # ── 2. 根据架构选择下载地址（修复原脚本的硬编码 Bug）─────────────────────
    case "$ARCH" in
        x86_64)
            SDK_URL="$SDK_AMD64_URI"
            STDX_URL="$STDX_AMD64_URI"
            ;;
        aarch64)
            SDK_URL="$SDK_ARM64_URI"
            STDX_URL="$STDX_ARM64_URI"
            ;;
        *)
            print_error "无法为架构 '$ARCH' 匹配下载链接"
            exit 1
            ;;
    esac

    print_info "安装配置："
    printf "  %-20s %s\n" "系统架构："     "$ARCH"
    printf "  %-20s %s\n" "SDK 路径："     "$SDK_DIR"
    printf "  %-20s %s\n" "标准库路径："   "$STDX_DIR"
    printf "  %-20s %s\n" "工作区路径："   "$WORKSPACE_DIR"
    printf "\n"

    # ── 3. 创建目录 ─────────────────────────────────────────────────────────
    mkdir -p "$SDK_DIR" "$STDX_DIR" "$WORKSPACE_DIR"

    # ── 4. 下载到临时目录 ────────────────────────────────────────────────────
    TEMP_DIR="$(mktemp -d)"
    # 确保临时目录在退出时被清理（无论成功还是失败）
    trap 'rm -rf "$TEMP_DIR"' EXIT

    cd "$TEMP_DIR"

    download_file "$SDK_URL"          "sdk.tar.gz"   "仓颉 SDK"     || exit 1
    download_file "$STDX_URL"         "sdkx.zip"     "仓颉标准库"   || exit 1
    download_file "$VSCODE_PLUGIN_URI" "vscode.tar.gz" "VSCode 插件" || \
        print_warning "VSCode 插件下载失败，可跳过手动处理"

    # ── 5. 解压 ──────────────────────────────────────────────────────────────
    extract_file "sdk.tar.gz"  "$SDK_DIR"       "仓颉 SDK"   || exit 1
    extract_file "sdkx.zip"    "$STDX_DIR"      "仓颉标准库" || exit 1
    if [ -f "vscode.tar.gz" ]; then
        extract_file "vscode.tar.gz" "$WORKSPACE_DIR" "VSCode 插件" || \
            print_warning "VSCode 插件解压失败，可手动处理"
    fi

    # ── 6. 配置环境变量 ───────────────────────────────────────────────────────
    configure_environment "$ARCH"

    # ── 7. 验证安装 ───────────────────────────────────────────────────────────
    print_step "验证安装..."
    if [ -f "$SDK_DIR/bin/cjc" ]; then
        print_info "✅ 仓颉编译器已就绪：$SDK_DIR/bin/cjc"
    else
        print_warning "⚠️  未找到 $SDK_DIR/bin/cjc，请手动检查安装包"
    fi

    # ── 8. 完成摘要 ──────────────────────────────────────────────────────────
    _rc="$(get_shell_rc)"
    printf "\n"
    print_info "🎉 安装完成！"
    printf "\n"
    printf "📋 后续步骤：\n"
    printf "  1. 重启终端 或 运行：source %s\n" "$_rc"
    printf "  2. 验证安装：cjc --version\n"
    printf "  3. 如需 VSCode 插件，参考 %s 目录下的文件\n" "$WORKSPACE_DIR"
    printf "\n"
    printf "💡 卸载提示：删除 %s、%s 并清理 %s 中的 CANGJIE_ENV 配置块\n" \
        "$SDK_DIR" "$STDX_DIR" "$_rc"
    printf "\n"
}

main
