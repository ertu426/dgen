# =============================================================================
# config.fish — Fish Shell Configuration
# =============================================================================
# Multi-language support: Chinese + English
# =============================================================================

# Environment Variables
# =============================================================================

# Locale settings (Chinese first, English fallback)
set -gx LANG zh_CN.UTF-8
set -gx LC_ALL zh_CN.UTF-8
set -gx LANGUAGE zh_CN:zh:en

# Timezone
set -gx TZ Asia/Shanghai

# Development paths
set -gx PATH $HOME/.local/bin $HOME/.cargo/bin $PATH
set -gx PATH /usr/local/bin /usr/local/sbin $PATH

# Editor
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less

# History
set -gx HISTFILE ~/.config/fish/history
set -gx HISTSIZE 10000
set -gx SAVEHIST 10000

# =============================================================================
# Aliases — 常用命令别名
# =============================================================================

# Navigation shortcuts
alias .. "cd .."
alias ... "cd ../.."
alias .... "cd ../../.."

# List commands
alias ll "eza -la --icons --group-directories-first"
alias ls "eza -l --icons --group-directories-first"
alias lt "eza --tree --icons --level=2"

# Shortcuts
alias c "clear"
alias cat "batcat"
alias find "fd"
alias grep "rg"
alias top "btop"
alias lg "lazygit"
alias cd "z"

# Safety aliases
alias rm "rm -i"
alias cp "cp -i"
alias mv "mv -i"

# Git shortcuts
alias gs "git status"
alias ga "git add"
alias gc "git commit"
alias gp "git push"
alias gl "git pull"
alias gd "git diff"
alias gco "git checkout"
alias gb "git branch"
alias gf "git fetch"
alias gm "git merge"
alias gr "git rebase"
alias gst "git stash"
alias gstp "git stash pop"
alias glg "git log --graph --pretty=format:'%C(bold)%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# =============================================================================
# Functions — 实用函数
# =============================================================================

# Create and enter directory
function mkcd
    mkdir -p $argv[1]; and cd $argv[1]
end

# Extract archives
function extract
    if test (count $argv) -lt 1
        echo "Usage: extract <file>"
        return 1
    end
    switch $argv[1]
        case "*.tar.bz2"
            tar xjf $argv[1]
        case "*.tar.gz"
            tar xzf $argv[1]
        case "*.bz2"
            bunzip2 $argv[1]
        case "*.rar"
            unrar x $argv[1]
        case "*.gz"
            gunzip $argv[1]
        case "*.tar"
            tar xf $argv[1]
        case "*.tbz2"
            tar xjf $argv[1]
        case "*.tgz"
            tar xzf $argv[1]
        case "*.zip"
            unzip $argv[1]
        case "*.Z"
            uncompress $argv[1]
        case "*.7z"
            7z x $argv[1]
        case "*"
            echo "extract: unknown archive format"
            return 1
    end
end

# Weather (需要 curl)
function weather
    curl -s "wttr.in/$argv[1]?lang=zh"
end

# Process lookup
function psg
    ps aux | grep -v grep | grep -i $argv[1]
end

# Commit with auto-message
function gca
    git add -A && git commit -m "$argv"
end

# Quick push
function gpom
    git push origin (git branch --show-current)
end

# =============================================================================
# Starship Prompt Configuration
# =============================================================================
# starship init fish | source
if type -q starship
    starship init fish | source
end

# =============================================================================
# Zoxide Integration (cd enhancement)
# =============================================================================
if type -q zoxide
    zoxide init fish | source
end

# =============================================================================
# Welcome Message — 欢迎信息
# =============================================================================

set -l distro (uname -s)
set -l uptime_info (uptime -p 2>/dev/null || echo "up")

echo ""
echo -e "\033[1;36m╭─────────────────────────────────────────╮\033[0m"
echo -e "\033[1;36m│\033[0m  \033[1;32m🐟 DGen Development Environment\033[0m        \033[1;36m│\033[0m"
echo -e "\033[1;36m│\033[0m  \033[0;37mSystem:\033[0m $distro                     \033[1;36m│\033[0m"
echo -e "\033[1;36m│\033[0m  \033[0;37mShell:\033[0m Fish $FISH_VERSION               \033[1;36m│\033[0m"
echo -e "\033[1;36m│\033[0m  \033[0;37mUptime:\033[0m $uptime_info               \033[1;36m│\033[0m"
echo -e "\033[1;36m╰─────────────────────────────────────────╯\033[0m"
echo ""
echo "\033[0;33m💡 提示:\033[0m 使用 \033[1;32mll\033[0m 查看文件 | \033[1;32mlt\033[0m 树形视图 | \033[1;32mgs\033[0m Git 状态"
echo ""
