#!/usr/bin/env bash
# Bash version of tmux smart status/title updater
# Works in tmux + bash, no job notifications

_TMUX_WINDOW_NAME_MAX_LEN=27
_TMUX_HOSTNAME="$(hostname -s)"
_TMUX_IS_TMUX=$([ "${TERM#tmux}" != "$TERM" ] && echo 1 || echo 0)
_TMUX_AWS_DEFAULT_REGION="${_TMUX_AWS_DEFAULT_REGION-"$AWS_DEFAULT_REGION"}"

# -- Utilities ----------------------------------------------------

set-window-name() {
    if [ $# -gt 0 ]; then
        export _TMUX_WINDOW_NAME_OVERRIDE="$*"
    else
        unset _TMUX_WINDOW_NAME_OVERRIDE
    fi
}
unset-window-name() { set-window-name; }

_tmux_smart_title_set_title() {
    local type="$1"; shift
    local text="$*"

    case "$type" in
        window)
            if [ "${TMUX_SMART_TITLE_DISABLE:-0}" -ne 0 ] || \
               [ "${ASCIINEMA_REC:-0}" -ne 0 ] || \
               [ "$_TMUX_IS_TMUX" -eq 0 ]; then
                return
            fi

            if [ -n "$_TMUX_WINDOW_NAME_OVERRIDE" ]; then
                text="$_TMUX_WINDOW_NAME_OVERRIDE"
            elif [ -n "$SSH_CLIENT" ]; then
                text="$USER@$_TMUX_HOSTNAME: $text"
            fi

            printf "\ek%s\e\\" "${text:0:$_TMUX_WINDOW_NAME_MAX_LEN}" >/dev/tty
            ;;
        pane)
            printf "\e]2;%s\e\\" "$text" >/dev/tty
            ;;
    esac
}

# -- Preexec / precmd hooks --------------------------------------

_tmux_window_name_preexec_hook() {
    (
        _tmux_smart_title_set_title window "$1"
    ) >/dev/null 2>&1 & disown
}

_tmux_window_name_precmd_hook() {
    (
        local output="$(basename "$PWD")"
        _tmux_smart_title_set_title window "$output"
    ) >/dev/null 2>&1 & disown
}

_tmux_status_bar_precmd_hook() {
    (
        local gitref output=() cdir aws_region gitpath
        gitref="$(timeout 0.05 sh -c 'git symbolic-ref -q --short HEAD || git describe HEAD --always --tags' 2>/dev/null)"
        cdir="$(pwd)"

        [ -n "$_BOB_CLIENT" ] && output+=("$_BOB_CLIENT")

        if [ "$_TMUX_IS_TMUX" -eq 1 ] && gitpath="$(git rev-parse --show-prefix 2>/dev/null)"; then
            output+=("#[fg=#50fa7b,bg=default]${cdir%/$gitpath}#[default]/${gitpath%/}")
        else
            output+=("$cdir")
        fi

        [ -n "$SSH_CONNECTION" ] && output+=("󰢹 $USER@$_TMUX_HOSTNAME")

        if [ -n "$AWS_PROFILE" ]; then
            [ "$_TMUX_AWS_DEFAULT_REGION" != "${AWS_REGION:-$AWS_DEFAULT_REGION}" ] && aws_region=" ${AWS_REGION:-$AWS_DEFAULT_REGION}"
            output+=(" $AWS_PROFILE$aws_region")
        fi

        [ -n "$AZURE_ACCOUNT" ] && output+=("󰠅 ${AZURE_ACCOUNT#*/}")
        [[ "$LD_PRELOAD" == *libproxychains4.so* ]] && output+=("󰒍 proxychains")

        [ -n "$VIRTUAL_ENV_PROMPT" ] && output+=("🐍$(basename "$(dirname "$VIRTUAL_ENV")")")

        [ -n "$gitref" ] && output+=("🌳$gitref")
        [ -z "$HISTFILE" ] && output+=("👻")

        local joined
        joined=$(printf " | %s" "${output[@]}")
        joined=${joined:3}

        _tmux_smart_title_set_title pane "$joined"
    ) >/dev/null 2>&1 & disown
}

# -- Plain output mode for tmux.conf ------------------------------

_tmux_status_bar_print() {
    local gitref output=() cdir aws_region gitpath
    gitref="$(timeout 0.05 sh -c 'git symbolic-ref -q --short HEAD || git describe HEAD --always --tags' 2>/dev/null)"
    cdir="$(pwd)"

    [ -n "$_BOB_CLIENT" ] && output+=("$_BOB_CLIENT")

    if [ "$_TMUX_IS_TMUX" -eq 1 ] && gitpath="$(git rev-parse --show-prefix 2>/dev/null)"; then
        output+=("${cdir%/$gitpath}/${gitpath%/}")
    else
        output+=("$cdir")
    fi

    [ -n "$SSH_CONNECTION" ] && output+=("$USER@$_TMUX_HOSTNAME")

    if [ -n "$AWS_PROFILE" ]; then
        [ "$_TMUX_AWS_DEFAULT_REGION" != "${AWS_REGION:-$AWS_DEFAULT_REGION}" ] && aws_region=" ${AWS_REGION:-$AWS_DEFAULT_REGION}"
        output+=("$AWS_PROFILE$aws_region")
    fi

    [ -n "$AZURE_ACCOUNT" ] && output+=("${AZURE_ACCOUNT#*/}")
    [[ "$LD_PRELOAD" == *libproxychains4.so* ]] && output+=("proxychains")

    [ -n "$VIRTUAL_ENV_PROMPT" ] && output+=("🐍$(basename "$(dirname "$VIRTUAL_ENV")")")

    [ -n "$gitref" ] && output+=("🌳$gitref")
    [ -z "$HISTFILE" ] && output+=("👻")

    local joined
    joined=$(printf " | %s" "${output[@]}")
    joined=${joined:3}
    echo "$joined"
}

# -- Entry point --------------------------------------------------

if [ "$1" = "print" ]; then
    _tmux_status_bar_print
    exit 0
fi

# Bash-only hooks
_tmux_preexec_invoke() {
    local cmd="$BASH_COMMAND"
    case "$cmd" in
        *_tmux_*hook*|PROMPT_COMMAND=*) return;;
    esac
    _tmux_window_name_preexec_hook "$cmd"
}
trap '_tmux_preexec_invoke' DEBUG

_tmux_precmd_invoke() {
    _tmux_window_name_precmd_hook
    _tmux_status_bar_precmd_hook
}
PROMPT_COMMAND="_tmux_precmd_invoke${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

