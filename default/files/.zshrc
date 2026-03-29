# ─── ENV ────────────────────────────────────────────────────────────
export PATH=$HOME/.local/bin:$PATH

# ─── Starship prompt ────────────────────────────────────────────────
eval "$(starship init zsh)"

# ─── Zsh plugins (via Homebrew) ──────────────────────────────────────
# Syntax highlighting (must be before autosuggestions for best results)
if [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Autosuggestions (fish-like suggestions)
if [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi

autoload -Uz compinit && compinit

# ─── History ─────────────────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# ─── fzf ─────────────────────────────────────────────────────────────
if [[ -f ~/.fzf.zsh ]]; then
    source ~/.fzf.zsh
elif command -v fzf &>/dev/null; then
    eval "$(fzf --zsh 2>/dev/null)"
fi
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
# Use fd for fzf if available
if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# ─── Zoxide (smart cd) ──────────────────────────────────────────────
eval "$(zoxide init zsh)"

# ─── Aliases ─────────────────────────────────────────────────────────
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias lt='eza --tree --icons --level=2'
alias cat='bat'
alias find='fd'
alias grep='rg'
alias top='btop'