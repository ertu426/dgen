#!/usr/bin/env fish

# ==========================================
# 🟢 配置区
# ==========================================
set -l PYTHON_VERSION "3.11"

# ==========================================
# ⚙️ 脚本执行逻辑区
# ==========================================

function print_info
    set_color green; echo -n "[INFO] "; set_color normal; echo $argv
end
function print_warning
    set_color yellow; echo -n "[WARNING] "; set_color normal; echo $argv
end
function print_error
    set_color red; echo -n "[ERROR] "; set_color normal; echo $argv
end

# 自动获取当前 Shell 的配置文件路径
function get_shell_rc
    # 检测是否在 Fish shell 中运行
    if set -q fish_pid
        set -l fish_config "$HOME/.config/fish/config.fish"
        mkdir -p (dirname $fish_config)
        echo $fish_config
    # 检测是否在 Zsh 中运行
    else if set -q ZSH_VERSION
        echo "$HOME/.zshrc"
    # 兜底使用 Bash
    else
        echo "$HOME/.bashrc"
    end
end

# 安装 uv
function install_uv
    if command -v uv > /dev/null 2>&1
        print_info "uv 已安装: $(uv --version)"
        return 0
    end

    print_info "正在安装 uv ..."
    if command -v curl > /dev/null 2>&1
        curl -LsSf https://astral.sh/uv/install.sh | sh
    else if command -v wget > /dev/null 2>&1
        wget -qO- https://astral.sh/uv/install.sh | sh
    else
        print_error "需要 curl 或 wget 来安装 uv"
        exit 1
    end

    set -gx PATH $HOME/.local/bin $HOME/.cargo/bin $PATH

    if command -v uv > /dev/null 2>&1
        print_info "uv 安装成功: $(uv --version)"
    else
        print_error "uv 安装失败"
        exit 1
    end
end

function install_python
    set -l version $argv[1]
    if uv python list --only-installed 2>/dev/null | grep -q "python$version\|$version\."
        print_info "Python $version 已安装，跳过"
        return 0
    end

    print_info "正在通过 uv 安装 Python $version ..."
    uv python install "$version"

    if uv python list --only-installed 2>/dev/null | grep -q "python$version\|$version\."
        print_info "Python $version 安装成功: $(uv run python$version --version 2>/dev/null)"
    else
        print_error "Python $version 安装失败"
        exit 1
    end
end

# 写入环境变量（自动适配 Fish / Zsh）
function configure_environment
    set -l version $argv[1]
    set -l shell_rc (get_shell_rc)
    set -l is_fish false
    if set -q fish_pid
        set is_fish true
    end

    # 1. 处理 PATH 配置
    if test -f "$shell_rc"; and grep -q "\.local/bin\|\.cargo/bin" "$shell_rc" 2>/dev/null
        print_info "更新 $shell_rc 中的PATH配置..."
        if $is_fish
            # Fish 语法清理
            sed -i '/set -gx PATH.*\.local\|\.cargo/d' "$shell_rc"
            echo "# uv (Python 管理工具)
set -gx PATH \$HOME/.local/bin \$HOME/.cargo/bin \$PATH" >> "$shell_rc"
        else
            # Zsh/Bash 语法清理 (保留原脚本逻辑)
            awk -v s='. "$HOME/.local/bin/env"' -v r='# uv (Python 管理工具)
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"' '
            BEGIN { replaced=0 }
            {
              if (!replaced && $0 == s) { print r; replaced=1 }
              else { print }
            }
            END { if (!replaced) { print ""; print r } }
            ' "$shell_rc" > "$shell_rc.tmp" && mv "$shell_rc.tmp" "$shell_rc"
        end
    else
        if $is_fish
            echo "
# uv (Python 管理工具)
set -gx PATH \$HOME/.local/bin \$HOME/.cargo/bin \$PATH" >> "$shell_rc"
        else
            echo '
# uv (Python 管理工具)
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"' >> "$shell_rc"
        end
    end

    # 2. 处理 PYTHON_LIB 配置
    set -l python_lib (uv run python -c "import sys; print(sys.prefix + '/lib')" --python "$PYTHON_VERSION" 2>/dev/null)
    if test -n "$python_lib"
        if $is_fish
            echo "set -gx PYTHON_LIB \"$python_lib\"" >> "$shell_rc"
        else
            echo "export PYTHON_LIB=\"$python_lib\"" >> "$shell_rc"
        end
    fi

    print_info "环境变量已写入 $shell_rc"
end

function main
    echo "========================================"
    echo "  uv + Python 安装脚本"
    echo "========================================"
    echo ""

    install_uv
    install_python $PYTHON_VERSION
    configure_environment

    echo ""
    print_info "🎉 安装完成！"
    echo "  - uv 版本:      $(uv --version)"
    echo "  - Python 版本:  $(uv run python --version 2>/dev/null)"
    echo "  - Python Lib:   $(uv run python -c "import sys; print(sys.prefix + '/lib')" --python "$PYTHON_VERSION" 2>/dev/null)"
end

main
exit 0
