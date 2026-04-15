#!/usr/bin/env fish

# ==========================================
# 🟢 下载地址与目录配置区
# ==========================================
set -l SDK_DIR "$HOME/cangjie"
set -l SDKX_DIR "$HOME/cangjie_sdkx"
set -l WORKSPACE_DIR "/home/dev/workspace"

set -l VSCODE_PLUGIN_URI "https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-vscode-1.1.0-beta.25.tar.gz&objectKey=69cb70e16e8ed61e6e07fd3e"
set -l SDK_AMD64_URI "https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-x64-1.1.0-beta.25.tar.gz&objectKey=69cb718e6e8ed61e6e07fd42"
set -l SDKX_AMD64_URI "https://gitcode.com/Cangjie/cangjie_stdx/releases/download/v1.1.0-beta.25/cangjie-stdx-linux-x64-1.1.0-beta.25.1.zip"
set -l SDK_ARM64_URI "https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-aarch64-1.1.0-beta.25.tar.gz&objectKey=69cb74a76e8ed61e6e07fd45"
set -l SDKX_ARM64_URI "https://gitcode.com/Cangjie/cangjie_stdx/releases/download/v1.1.0-beta.25/cangjie-stdx-linux-aarch64-1.1.0-beta.25.1.zip"

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
    if set -q fish_pid
        set -l fish_config "$HOME/.config/fish/config.fish"
        mkdir -p (dirname $fish_config)
        echo $fish_config
    else if set -q ZSH_VERSION
        echo "$HOME/.zshrc"
    else
        echo "$HOME/.bashrc"
    end
end

function detect_architecture
    set -l arch (uname -m)
    switch $arch
        case x86_64 amd64; echo "x86_64"
        case aarch64 arm64; echo "aarch64"
        case '*'
            print_error "不支持的系统架构: $arch"
            exit 1
    end
end

function download_file
    set -l url $argv[1]
    set -l output_file $argv[2]
    set -l description $argv[3]
    
    print_info "正在下载 $description ..."
    if curl -L -o "$output_file" "$url" --silent --show-error --fail
        print_info "下载完成: "(basename "$output_file")
        return 0
    else
        print_error "下载失败: $description"
        return 1
    end
end

function extract_file
    set -l archive $argv[1]
    set -l destination $argv[2]
    set -l description $argv[3]
    
    print_info "正在解压 $description ..."
    switch $archive
        case '*.tar.gz'
            if tar -xzf "$archive" -C "$destination" --strip-components=1 2>/dev/null
                print_info "解压完成"; return 0
            end
        case '*.zip'
            if unzip -q "$archive" -d "$destination" 2>/dev/null
                print_info "解压完成"; return 0
            end
    end
    print_error "解压失败: $description"
    return 1
end

# 配置环境变量（自动适配 Fish / Zsh）
function configure_environment
    print_info "配置环境变量..."
    
    set -l shell_rc (get_shell_rc)
    set -l hw_arch (detect_architecture)
    set -l is_fish false
    
    if set -q fish_pid
        set is_fish true
    end

    # 构建不同 Shell 的配置块
    set -l env_config_block ""
    if $is_fish
        # Fish 语法配置块
        set env_config_block "
# ⚠️ 以下由仓颉安装脚本自动生成
set -gx CANGJIE_HOME \"$SDK_DIR\"
set -gx CANGJIE_SDKX_HOME \"$SDKX_DIR\"
set -gx PATH \$CANGJIE_HOME/bin \$CANGJIE_HOME/tools/bin \$PATH \$HOME/.cjpm/bin
set -gx LD_LIBRARY_PATH \$PYTHON_LIB \$CANGJIE_HOME/runtime/lib/linux_${hw_arch}_cjnative \$CANGJIE_HOME/tools/lib \$CANGJIE_STDX_HOME/linux_${hw_arch}_cjnative/static/stdx\$LD_LIBRARY_PATH
"
        # Zsh/Bash 中的 compdef 在 Fish 中无效，因此 Fish 中省略
    else
        # Zsh/Bash 语法配置块
        set env_config_block "
# ⚠️ 以下由仓颉安装脚本自动生成
export CANGJIE_HOME=\"$SDK_DIR\"
export CANGJIE_SDKX_HOME=\"$SDKX_DIR\"
export PATH=\"\${CANGJIE_HOME}/bin:\${CANGJIE_HOME}/tools/bin:\$PATH:\$HOME/.cjpm/bin\"
export LD_LIBRARY_PATH=\"\$PYTHON_LIB:\${CANGJIE_HOME}/runtime/lib/linux_${hw_arch}_cjnative:\${CANGJIE_HOME}/tools/lib:\$CANGJIE_STDX_HOME/linux_${hw_arch}_cjnative/static/stdx\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}\"

compdef _gnu_generic cjc cjc-frontend
"
    end
    
    # 检查并处理现有配置
    if test -f "$shell_rc"; and grep -q "CANGJIE_HOME" "$shell_rc" 2>/dev/null
        print_warning "检测到已存在的CANGJIE_HOME配置"
        cp $shell_rc "$shell_rc.backup"
        
        # 删除旧配置块 (兼容 Fish set 与 Bash export 写法)
        sed -i '/^# .* 仓颉安装脚本自动生成$/,/\(set -gx\|export\) LD_LIBRARY_PATH.*cjnative.*$/d' "$shell_rc"
        
        if test $status -eq 0
            print_info "旧配置已删除"
        else
            print_error "删除旧配置失败，请手动编辑 $shell_rc"
            exit 1
        end
    end
    
    # 添加新配置
    echo "$env_config_block" >> $shell_rc
    print_info "环境变量已写入 $shell_rc"
end

function main
    echo "========================================"
    echo "     仓颉编程语言自动安装脚本           "
    echo "========================================"
    echo ""

    set -l ARCH (detect_architecture)
    
    switch $ARCH
        case x86_64
            set -l SDK_URL $SDK_AMD64_URI
            set -l SDKX_URL $SDKX_AMD64_URI
        case aarch64
            set -l SDK_URL $SDK_ARM64_URI
            set -l SDKX_URL $SDKX_ARM64_URI
        case '*'
            print_error "无法为架构 '$ARCH' 设置下载链接"
            exit 1
    end
    
    print_info "安装配置:"
    print_info "  架构:      $ARCH"
    print_info "  SDK路径:   $SDK_DIR"
    print_info "  标准库路径: $SDKX_DIR"
    
    mkdir -p $SDK_DIR $SDKX_DIR $WORKSPACE_DIR
    
    set -l TEMP_DIR (mktemp -d)
    cd $TEMP_DIR; or exit 1
    
    # 注意：这里的局部变量作用域问题，用带引号的方式直接传参
    download_file "$SDK_AMD64_URI" "sdk.tar.gz" "仓颉SDK"; or test $ARCH = aarch64; and download_file "$SDK_ARM64_URI" "sdk.tar.gz" "仓颉SDK"; or exit 1
    download_file "$SDKX_AMD64_URI" "sdkx.zip" "仓颉标准库"; or test $ARCH = aarch64; and download_file "$SDKX_ARM64_URI" "sdkx.zip" "仓颉标准库"; or exit 1
    download_file "$VSCODE_PLUGIN_URI" "vscode.tar.gz" "VSCode插件"; or exit 1
    
    extract_file "sdk.tar.gz" $SDK_DIR "仓颉SDK"; or exit 1
    extract_file "sdkx.zip" $SDKX_DIR "仓颉标准库"; or exit 1
    extract_file "vscode.tar.gz" $WORKSPACE_DIR "VSCode插件"; or print_warning "VSCode插件解压失败，可手动处理"
    
    configure_environment
    
    cd -; or exit 1
    rm -rf $TEMP_DIR
    
    print_info "验证安装..."
    if test -f "$SDK_DIR/bin/cjc"
        print_info "✅ 仓颉编译器安装成功"
    else
        print_warning "⚠️ 未找到编译器，可能需要手动检查"
    end
    
    echo ""
    print_info "🎉 安装完成！"
    echo ""
    echo "📦 后续步骤："
    set -l source_cmd "source "(get_shell_rc)
    echo "  1. 重启终端或运行: $source_cmd"
    echo "  2. 验证安装: cjc --version"
    echo "  3. 安装VSCode插件 (如有下载)"
    echo ""
    echo "💡 提示: 如需卸载，请删除 $SDK_DIR, $SDKX_DIR 并检查 "(get_shell_rc)
    echo ""
end

main
