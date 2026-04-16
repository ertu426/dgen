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

# List commands
alias ll "eza -la --icons --group-directories-first"
alias ls "eza -l --icons --group-directories-first"
alias lt "eza --tree --icons --level=2"

# Shortcuts
alias c "clear"
alias cat "batcat"
alias top "btop"
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
# Starship Prompt Configuration
# =============================================================================
# starship init fish | source
if type -q starship
    starship init fish | source
end

# =============================================================================
# zoxide Prompt Configuration
# =============================================================================
# zoxide init fish | source
if type -q zoxide
  zoxide init fish | source
end
