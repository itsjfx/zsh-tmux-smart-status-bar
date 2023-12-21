# zsh-tmux-smart-status-bar

## Overview

I installed `tmux` to have a clean prompt by displaying information on a status bar. I wanted information on the current branch, AWS environment variables, and meaningful window/tab names based on the currently executed command or current directory.

Existing scripts didn't meet my requirements:
* some had not great update mechanisms. they relied on polling, or on window switching
* some were overly heavy and added unnecessary and painful delay to my shell
* some were overly complicated for a simple task of populating a status bar
* were missing desired features

This script uses [terminal escape sequences](https://en.wikipedia.org/wiki/ANSI_escape_code) to update the status bar and window name efficiently using [zsh hooks](https://zsh.sourceforge.io/Doc/Release/Functions.html).

Updates are made when the shell prompt is rendered or when a command is executed.

## Screenshots

Status bar with `AWS`, `proxychains`, and `git` branch status
![status-bar-non-ssh](https://github.com/itsjfx/zsh-tmux-smart-status-bar/assets/13778935/3b4047ec-0dd2-4034-821b-145c6b865c49)


Status bar while `SSH`'d into a system which is also running the plugin where the current working directory is a `git` repo
![status-bar-ssh](https://github.com/itsjfx/zsh-tmux-smart-status-bar/assets/13778935/d9652cc8-b17d-4fdb-9625-6a876d8b1a6d)

## Installation

Add to your `.zshrc`

```bash
source /path/to/zsh-tmux-smart-status-bar/zsh-tmux-smart-status-bar.sh
```

To have a similar status bar in `tmux` to the screenshots, set:

```
# https://that.guru/blog/automatically-set-tmux-window-name
set -g allow-rename on

set-option -g status 2
set -g status-right ''
set -g status-format[1] ''
set -g status-format[1] '#[align=centre]#{pane_title}'
```

where `#{pane_title}` will have the status bar contents

You can customise the style of your `tmux` status bar however you like.

My full config (including options and styling) is available here:
* <https://github.com/itsjfx/dotfiles/tree/master/.config/tmux/conf.d>

Some helpful resources for learning how to style your bar:
* <https://www.fosslinux.com/104470/customizing-the-tmux-status-bar-in-linux.htm>
* <https://tao-of-tmux.readthedocs.io/en/latest/manuscript/09-status-bar.html>
* <https://linuxhint.com/customizing-status-bar-tmux/>
* <https://man7.org/linux/man-pages/man1/tmux.1.html#STATUS_LINE>
* <https://github.com/itsjfx/dotfiles/blob/master/.config/tmux/conf.d/001-style.conf>

## TODO

* make the window names shorter/more selective around what args are listed, like [tmux-window-name](https://github.com/ofirgall/tmux-window-name)

## See also

* <https://github.com/tmux/tmux/wiki/Advanced-Use#pane-titles-and-the-terminal-title>
* <https://zsh.sourceforge.io/Doc/Release/Functions.html>
* <https://github.com/arl/gitmux>
* <https://github.com/drmad/tmux-git>
* <https://github.com/mbenford/zsh-tmux-auto-title>
    * also uses terminal escape sequences as the update mechanism
* <https://github.com/ofirgall/tmux-window-name>
