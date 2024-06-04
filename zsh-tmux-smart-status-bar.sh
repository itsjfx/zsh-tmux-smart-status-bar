# set ft=zsh

# TODO may remove this cause you can do trimming and padding natively in tmux
# https://github.com/tmux/tmux/wiki/Formats#trimming-and-padding
_TMUX_WINDOW_NAME_MAX_LEN=27
_TMUX_HOSTNAME="$(hostname -s)"

set-window-name() {
    if (( $# )); then
        export _TMUX_WINDOW_NAME_OVERRIDE="$@"
    else
        unset _TMUX_WINDOW_NAME_OVERRIDE
    fi
}
unset-window-name() { set-window-name }

# inspired by https://github.com/mbenford/zsh-tmux-auto-title/blob/07fd6d7864df9aed4fbc5e1f67e1ad6eeef0a01f/zsh-tmux-auto-title.plugin.zsh#L17-L22
_tmux_smart_title_set_title() {
    local type
    type="$1"
    shift
    local text="$@"
    case "$type" in
        window)
            # disable under these circumstances
            # the window name terminal escape sequence is non standard and has issues on other terminals
            if  (( TMUX_SMART_TITLE_DISABLE )) || \
                (( ASCIINEMA_REC )) || \
                [[ "$TERM" != 'tmux-256color' ]]; then
                return;
            fi

            if [[ -n "$_TMUX_WINDOW_NAME_OVERRIDE" ]]; then
                text="$_TMUX_WINDOW_NAME_OVERRIDE"
            # inside an SSH session
            elif [ -n "$SSH_CLIENT" ]; then
                text="$USER@$_TMUX_HOSTNAME: $text"
            fi
            printf "\ek%s\e\\" "${text:0:"$_TMUX_WINDOW_NAME_MAX_LEN"}"
            ;;
        pane)
            printf "\e]2;%s\e\\" "$text"
            ;;
    esac
}

_tmux_window_name_preexec_hook() {
    local output="$1"
    _tmux_smart_title_set_title window "$output"
}

# TODO to use ${PWD##*/} or not to use
# TODO add some smarts to only show compact args for certain commands like: git, nvim, etc, and command name for rest
_tmux_window_name_precmd_hook() {
    local output="$(basename "$PWD")"
    _tmux_smart_title_set_title window "$output"
}

# example of another way using tmux command directly: https://github.com/drmad/tmux-git/blob/master/tmux-git.sh
_tmux_status_bar_precmd_hook() {
    local gitref="$(timeout 0.05 sh -c 'git symbolic-ref -q --short HEAD || git describe HEAD --always --tags' 2>/dev/null)"
    local output=()
    if [ -n "$_BOB_CLIENT" ]; then
        output+=("$_BOB_CLIENT")
    fi
    output+=("$(dirs)")
    if [ -n "$SSH_CONNECTION" ]; then
        output+=("󰢹 $USER@$(hostname)")
    fi
    if [ -n "$AWS_PROFILE" ]; then
        output+=("AWS: $AWS_PROFILE ${AWS_REGION:-$AWS_DEFAULT_REGION}")
    fi
    # TODO
    if [[ "$LD_PRELOAD" == *libproxychains4.so* ]]; then
        output+=("󰒍 proxychains")
    fi
    if [ -n "$gitref" ]; then
        output+=("🌳 $gitref")
    fi
    _tmux_smart_title_set_title pane "${(j: | :)output}"
}

# https://zsh.sourceforge.io/Doc/Release/Functions.html
autoload -U add-zsh-hook
# before prompt
add-zsh-hook precmd _tmux_window_name_precmd_hook
add-zsh-hook precmd _tmux_status_bar_precmd_hook
# before executed command
add-zsh-hook preexec _tmux_window_name_preexec_hook
