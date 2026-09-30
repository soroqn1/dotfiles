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
test -f ~/.openclaw/completions/openclaw.fish; and source ~/.openclaw/completions/openclaw.fish

# atuin — enhanced history (Ctrl+R)
atuin init fish | source

# zoxide — smart cd (use 'z' instead of 'cd')
zoxide init fish | source

# Abbreviations
abbr -a v nvim
abbr -a lg lazygit
abbr -a lzd lazydocker

# Custom greeting
function fish_greeting
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1
        if not onefetch 2>/dev/null
            echo "Welcome to fish, the friendly interactive shell"
            echo "Type "(set_color green)"help"(set_color normal)" for instructions on how to use fish"
        end
    else
        echo "Welcome to fish, the friendly interactive shell"
        echo "Type "(set_color green)"help"(set_color normal)" for instructions on how to use fish"
    end
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
