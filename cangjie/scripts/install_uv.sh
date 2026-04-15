#!/usr/bin/env sh
# =============================================================================
# install_uv.sh — 安装 uv 及指定版本 Python
#
# 兼容 Shell：sh / bash / zsh（推荐）
# Fish 用户请使用：bash install_uv.sh 或 sh install_uv.sh
#
# 用法：
#   sh install_uv.sh
#   PYTHON_VERSION=3.12 sh install_uv.sh   # 指定 Python 版本
# =============================================================================
set -eu  # 遇到错误立即退出，禁止使用未定义变量

# ==========================================
# 🟢 配置区（可通过环境变量覆盖）
# ==========================================
PYTHON_VERSION="${PYTHON_VERSION:-3.11}"

# ==========================================
# 📦 引入公共工具库
# ==========================================
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/lib/common.sh"

# =============================================================================
# 安装 uv
# =============================================================================
install_uv() {
    if command -v uv >/dev/null 2>&1; then
        print_info "uv 已安装：$(uv --version)"
        return 0
    fi

    print_step "安装 uv ..."
    if command -v curl >/dev/null 2>&1; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- https://astral.sh/uv/install.sh | sh
    else
        print_error "需要 curl 或 wget 来安装 uv，请先安装其中一个"
        exit 1
    fi

    # 让新安装的 uv 在当前 shell 会话中可用
    export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

    if command -v uv >/dev/null 2>&1; then
        print_info "uv 安装成功：$(uv --version)"
    else
        print_error "uv 安装失败，请检查网络或手动安装：https://docs.astral.sh/uv/"
        exit 1
    fi
}

# =============================================================================
# 安装指定版本 Python（通过 uv）
# =============================================================================
install_python() {
    _ver="$1"

    if uv python list --only-installed 2>/dev/null | grep -qE "python${_ver}|${_ver}\."; then
        print_info "Python ${_ver} 已安装，跳过"
        return 0
    fi

    print_step "通过 uv 安装 Python ${_ver} ..."
    uv python install "$_ver"

    if uv python list --only-installed 2>/dev/null | grep -qE "python${_ver}|${_ver}\."; then
        print_info "Python ${_ver} 安装成功"
    else
        print_error "Python ${_ver} 安装失败，请检查 uv 日志"
        exit 1
    fi
}

# =============================================================================
# 写入环境变量（自动适配 Fish / Zsh / Bash / sh）
# =============================================================================
configure_environment() {
    _ver="$1"
    _rc="$(get_shell_rc)"

    print_step "配置环境变量到 $_rc ..."

    # 获取 Python lib 路径（用于 PYTHON_LIB）
    _python_lib=""
    if command -v uv >/dev/null 2>&1; then
        _python_lib=$(uv run python -c "import sys; print(sys.prefix + '/lib')" \
            --python "$_ver" 2>/dev/null || true)
    fi

    # 根据目标 rc 文件类型生成对应语法的配置块
    if is_fish_rc "$_rc"; then
        # ── Fish 语法 ──────────────────────────────────────────────────────────
        _block="# uv + Python 管理工具
set -gx PATH \$HOME/.local/bin \$HOME/.cargo/bin \$PATH"
        if [ -n "$_python_lib" ]; then
            _block="${_block}
set -gx PYTHON_LIB \"${_python_lib}\""
        fi
    else
        # ── POSIX sh / Bash / Zsh 语法 ─────────────────────────────────────────
        _block='# uv + Python 管理工具
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"'
        if [ -n "$_python_lib" ]; then
            _block="${_block}
export PYTHON_LIB=\"${_python_lib}\""
        fi
    fi

    append_env_block "$_rc" "UV_PYTHON_ENV" "$_block"
}

# =============================================================================
# 主流程
# =============================================================================
main() {
    printf "\n%s========================================%s\n" "${_C_BOLD}" "${_C_RESET}"
    printf   "%s  uv + Python %s 安装脚本%s\n"              "${_C_BOLD}" "$PYTHON_VERSION" "${_C_RESET}"
    printf   "%s========================================%s\n\n" "${_C_BOLD}" "${_C_RESET}"

    install_uv
    install_python "$PYTHON_VERSION"
    configure_environment "$PYTHON_VERSION"

    # ── 安装摘要 ────────────────────────────────────────────────────────────
    _uv_ver=$(uv --version 2>/dev/null || echo "未知")
    _py_ver=$(uv run python --version 2>/dev/null || echo "未知")
    _py_lib=$(uv run python -c "import sys; print(sys.prefix + '/lib')" \
        --python "$PYTHON_VERSION" 2>/dev/null || echo "未知")
    _rc=$(get_shell_rc)

    printf "\n"
    print_info "🎉 安装完成！"
    printf "\n"
    printf "  %-18s %s\n" "uv 版本："     "$_uv_ver"
    printf "  %-18s %s\n" "Python 版本：" "$_py_ver"
    printf "  %-18s %s\n" "Python Lib："  "$_py_lib"
    printf "\n"
    printf "📋 后续步骤：\n"
    printf "  1. 重启终端 或 运行：source %s\n" "$_rc"
    printf "  2. 验证安装：uv --version && python%s --version\n" "$PYTHON_VERSION"
    printf "\n"
}

main
