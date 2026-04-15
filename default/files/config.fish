if status is-interactive
    # Commands to run in interactive sessions can go here
end

# PATH: system paths are used on Linux

# Starship prompt
source (/opt/homebrew/bin/starship init fish --print-full-init | psub)