#!/usr/bin/env sh
# =============================================================================
# lib/common.sh — 跨 Shell 公共工具库
#
# 兼容性：POSIX sh / bash / zsh / fish (通过 sh -c 调用)
# 使用方式：. "$(dirname "$0")/lib/common.sh"
# =============================================================================

# -----------------------------------------------------------------------------
# 颜色输出（自动降级：不支持颜色时退化为纯文本）
# -----------------------------------------------------------------------------
_color_supported() {
    # 判断 stdout 是否为终端且终端支持颜色
    [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null)" -ge 8 ] 2>/dev/null
}

if _color_supported; then
    _C_GREEN=$(tput setaf 2)
    _C_YELLOW=$(tput setaf 3)
    _C_RED=$(tput setaf 1)
    _C_CYAN=$(tput setaf 6)
    _C_BOLD=$(tput bold)
    _C_RESET=$(tput sgr0)
else
    _C_GREEN=""
    _C_YELLOW=""
    _C_RED=""
    _C_CYAN=""
    _C_BOLD=""
    _C_RESET=""
fi

print_info()    { printf "%s[INFO]%s    %s\n" "${_C_GREEN}"  "${_C_RESET}" "$*"; }
print_warning() { printf "%s[WARNING]%s %s\n" "${_C_YELLOW}" "${_C_RESET}" "$*"; }
print_error()   { printf "%s[ERROR]%s   %s\n" "${_C_RED}"    "${_C_RESET}" "$*" >&2; }
print_step()    { printf "\n%s==>%s %s%s%s\n" "${_C_CYAN}" "${_C_RESET}" "${_C_BOLD}" "$*" "${_C_RESET}"; }

# -----------------------------------------------------------------------------
# 系统架构检测
# 返回值：echo "x86_64" | "aarch64"，失败则 exit 1
# -----------------------------------------------------------------------------
detect_architecture() {
    _arch=$(uname -m)
    case "$_arch" in
        x86_64|amd64)   echo "x86_64"  ;;
        aarch64|arm64)  echo "aarch64" ;;
        *)
            print_error "不支持的系统架构: $_arch（当前仅支持 x86_64 / aarch64）"
            exit 1
            ;;
    esac
}

# -----------------------------------------------------------------------------
# Shell 配置文件路径检测
# 优先级：$SHELL 变量 > 常见路径探测 > fallback ~/.profile
#
# Fish 特殊处理：fish 不支持直接 source POSIX sh 脚本，
# 本函数返回 fish 配置路径供写入环境变量使用，
# 但执行本脚本本身应在 sh/bash/zsh 下进行。
# -----------------------------------------------------------------------------
get_shell_rc() {
    # 优先根据 $SHELL 判断
    _shell_bin=$(basename "${SHELL:-sh}")
    case "$_shell_bin" in
        fish)
            _fish_cfg="$HOME/.config/fish/config.fish"
            mkdir -p "$(dirname "$_fish_cfg")"
            echo "$_fish_cfg"
            ;;
        zsh)
            echo "$HOME/.zshrc"
            ;;
        bash)
            # bash 优先 .bash_profile（login shell），其次 .bashrc
            if [ -f "$HOME/.bash_profile" ]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"
            fi
            ;;
        *)
            # POSIX sh / 其他 shell
            echo "$HOME/.profile"
            ;;
    esac
}

# -----------------------------------------------------------------------------
# 判断当前写入的 shell rc 是否为 Fish 格式
# 返回：0 = fish，1 = 其他
# -----------------------------------------------------------------------------
is_fish_rc() {
    _rc_file="$1"
    case "$_rc_file" in
        */fish/*)  return 0 ;;
        *.fish)    return 0 ;;
        *)         return 1 ;;
    esac
}

# -----------------------------------------------------------------------------
# 带进度的文件下载（优先 curl，回退 wget）
# 用法：download_file <url> <output_file> <描述>
# -----------------------------------------------------------------------------
download_file() {
    _url="$1"
    _output="$2"
    _desc="$3"

    print_info "正在下载 ${_desc} ..."

    if command -v curl >/dev/null 2>&1; then
        if curl -L --fail --show-error --progress-bar -o "$_output" "$_url"; then
            print_info "下载完成：$(basename "$_output")"
            return 0
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget --show-progress -q -O "$_output" "$_url"; then
            print_info "下载完成：$(basename "$_output")"
            return 0
        fi
    else
        print_error "未找到 curl 或 wget，无法下载文件"
        exit 1
    fi

    print_error "下载失败：$_desc"
    return 1
}

# -----------------------------------------------------------------------------
# 归档解压（自动识别 .tar.gz / .zip）
# 用法：extract_file <archive> <destination_dir> <描述>
# -----------------------------------------------------------------------------
extract_file() {
    _archive="$1"
    _dest="$2"
    _desc="$3"

    print_info "正在解压 ${_desc} ..."
    mkdir -p "$_dest"

    case "$_archive" in
        *.tar.gz|*.tgz)
            if tar -xzf "$_archive" -C "$_dest" --strip-components=1 2>/dev/null; then
                print_info "解压完成"; return 0
            fi
            ;;
        *.zip)
            if unzip -q "$_archive" -d "$_dest" 2>/dev/null; then
                print_info "解压完成"; return 0
            fi
            ;;
        *)
            print_error "不支持的压缩格式：$_archive"
            return 1
            ;;
    esac

    print_error "解压失败：$_desc"
    return 1
}

# -----------------------------------------------------------------------------
# 安全地向 shell rc 写入一段配置（幂等：相同 marker 不重复写入）
# 用法：append_env_block <rc_file> <marker_tag> <config_content>
#   marker_tag：唯一标识符，用于检测和替换旧配置，如 "CANGJIE_ENV"
# -----------------------------------------------------------------------------
append_env_block() {
    _rc="$1"
    _tag="$2"
    _block="$3"

    _begin_marker="# >>> ${_tag} >>>"
    _end_marker="# <<< ${_tag} <<<"

    # 如果已存在旧配置块，先备份再删除
    if grep -qF "$_begin_marker" "$_rc" 2>/dev/null; then
        print_warning "检测到已存在的 ${_tag} 配置，将自动替换..."
        cp "$_rc" "${_rc}.bak.$(date +%Y%m%d%H%M%S)"
        # 使用 awk 删除 begin_marker 到 end_marker 之间的内容（含边界行）
        awk -v bm="$_begin_marker" -v em="$_end_marker" '
            $0 == bm { skip=1; next }
            $0 == em { skip=0; next }
            !skip { print }
        ' "$_rc" > "${_rc}.tmp" && mv "${_rc}.tmp" "$_rc"
        print_info "旧配置已清理"
    fi

    # 追加新配置块
    printf "\n%s\n%s\n%s\n" "$_begin_marker" "$_block" "$_end_marker" >> "$_rc"
    print_info "配置已写入 $_rc"
}
