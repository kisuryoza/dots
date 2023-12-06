if status is-interactive
    # export environment variables
    export (envsubst < ~/.profile | rg --pcre2 '^export (?!.*PATH.*)(\w+)=' | sd "export " "")
    set path (envsubst < ~/.profile | rg '^export PATH' | sd 'export PATH=\"(.*)\"$' '$1' | sd ':' ' ')
    eval set -gx PATH $path

    source ~/.alias

    starship init fish | source
end
