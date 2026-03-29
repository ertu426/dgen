#!/bin/bash

# ==========================================
# 🟢 配置区
# ==========================================

UV_INSTALL_METHOD="installer"
PYTHON_VERSION="3.11"

# ==========================================
# ⚙️ 脚本执行逻辑区
# ==========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# 安装 uv
install_uv() {
    if command -v uv &> /dev/null; then
        print_info "uv 已安装: $(uv --version)"
        return 0
    fi

    print_info "正在安装 uv ..."

    if command -v curl &> /dev/null; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
    elif command -v wget &> /dev/null; then
        wget -qO- https://astral.sh/uv/install.sh | sh
    else
        print_error "需要 curl 或 wget 来安装 uv"
        exit 1
    fi

    # 加载 uv 到当前 shell
    export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

    if command -v uv &> /dev/null; then
        print_info "uv 安装成功: $(uv --version)"
    else
        print_error "uv 安装失败"
        exit 1
    fi
}

install_python() {
    local version="$1"

    if uv python list --only-installed 2>/dev/null | grep -q "python${version}\|${version}\."; then
        print_info "Python $version 已安装，跳过"
        return 0
    fi

    print_info "正在通过 uv 安装 Python $version ..."
    uv python install "$version"

    if uv python list --only-installed 2>/dev/null | grep -q "python${version}\|${version}\."; then
        print_info "Python $version 安装成功: $(uv run python${version} --version 2>/dev/null || true)"
    else
        print_error "Python $version 安装失败"
        exit 1
    fi
}

# 写入环境变量到 shell 配置
configure_environment() {
  local version="$1"
  local shell_rc="$HOME/.bashrc"
  [ -n "$ZSH_VERSION" ] && shell_rc="$HOME/.zshrc"

  SEARCH='. "$HOME/.local/bin/env"'
  REPLACEMENT='# uv (Python 管理工具)
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"'

  if grep -q '\.local/bin\|\.cargo/bin' "$shell_rc" 2>/dev/null; then
    awk -v s="$SEARCH" -v r="$REPLACEMENT" '
    BEGIN { replaced=0 }
    {
      if (!replaced && $0 == s) {
        print r
        replaced=1
      } else {
        print $0
      }
    }
    END {
      if (!replaced) {
        # 若未找到匹配行，则在文件末尾追加替换内容（前面加一空行以分隔）
        print ""
        print r
      }
    }
    ' "${shell_rc}" > "${shell_rc}.tmp" && mv "${shell_rc}.tmp" "${shell_rc}"
  else
    cat >> "$shell_rc" << 'EOF'
# uv (Python 管理工具)
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
EOF
  fi

  uv run python -c "import sys; print(sys.prefix + '/lib')" --python "$PYTHON_VERSION" 2>/dev/null | sed 's/^/export PYTHON_LIB=/' >> $shell_rc
  print_info "环境变量已写入 $shell_rc"
}

main() {
    echo "========================================"
    echo "  uv + Python 安装脚本"
    echo "========================================"
    echo ""

    install_uv
    install_python "$PYTHON_VERSION"
    configure_environment

    echo ""
    print_info "🎉 安装完成！"
    echo "  - uv 版本:      $(uv --version)"
    echo "  - Python 版本:  $(uv run python --version 2>/dev/null || true)"
    echo "  - Python Lib 路径: $(uv run python -c "import sys; print(sys.prefix + '/lib')" --python "$PYTHON_VERSION" 2>/dev/null)"
}

main
exit 0
