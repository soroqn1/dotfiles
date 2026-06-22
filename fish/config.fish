if not status is-interactive
    exit
end

# PATH
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/opt/postgresql@15/bin
fish_add_path /Users/soroqn/.spicetify
fish_add_path /Users/soroqn/.local/bin
fish_add_path /Users/soroqn/.antigravity/antigravity/bin
fish_add_path /Users/soroqn/.antigravity-ide/antigravity-ide/bin

# Integrations
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
source "/Users/soroqn/.openclaw/completions/openclaw.fish"

# atuin — enhanced history (Ctrl+R)
atuin init fish | source

# zoxide — smart cd (use 'z' instead of 'cd')
zoxide init fish | source

# Abbreviations
abbr -a v nvim
abbr -a lg lazygit
abbr -a lzd lazydocker
