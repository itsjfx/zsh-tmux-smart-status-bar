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

## Features

* Lightweight and quick update mechanism with [zsh hooks](https://zsh.sourceforge.io/Doc/Release/Functions.html)
* Status bar updates even if SSH'd to a machine using the plugin but not running `tmux`
* Window names named after current working directory or current running process
* The following items displayed:
   * current working directory. git repository path hightlighted if within a repo
   * current username@hostname, if ssh'd to host also using the plugin and not running `tmux` within `ssh`
   * current AWS profile, with region displayed if set to a non-default region
   * current git tag/branch
   * proxychains status (e.g if running `proxychains -q zsh`)

## Screenshots

Status bar while SSH'd to my home machine which runs the plugin. In a git repo, with an AWS profile set.

The other tabs in my terminal are: open to `/tmp`, running a `git` command, and running `vim` (aliased to `v`).

![status-bar](https://github.com/itsjfx/zsh-tmux-smart-status-bar/assets/13778935/1b5c2739-53b8-4add-84fa-20741f3a7bad)

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
