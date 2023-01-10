# zsh-tmux-smart-status-bar

## Overview

I installed `tmux` for the status bar so I could have a clean prompt.

My goal was to have information on the current branch, AWS environment variables -- and to have meaningful window/tab names about the currently executed command or opened directory. 

There's a few scripts around, but they didn't fulfill my requirements:
* not great update mechanisms (e.g. polling, or on window switching)
* some were overly heavy and added delay to my shell
* just overly complicated in general, this is a status bar and it just needs to run a shell command and dump some environment variables
* missing something from the second sentence above

Some existing projects:
* <https://github.com/arl/gitmux>
* <https://github.com/drmad/tmux-git>
* <https://github.com/mbenford/zsh-tmux-auto-title>
* <https://github.com/ofirgall/tmux-window-name>

The reason why I call this "smart" is cause just like [zsh-tmux-auto-title](https://github.com/mbenford/zsh-tmux-auto-title), it uses [terminal escape sequences](https://en.wikipedia.org/wiki/ANSI_escape_code) to update the status bar using [zsh hooks](https://zsh.sourceforge.io/Doc/Release/Functions.html).

This means that it'll update the status bar in the most efficient manner (not spawning `tmux` processes), and it'll happen in real time as changes are made (when the shell prompt is rendered, or when a command is executed).

I use terminal escape sequences to modify the window name and pane name, where I make the pane name the content of the right hand side of my status bar. This is where my "meta" status info lives (e.g. current `git` branch, etc). I'm not using multiple panes, so this seems ok at the moment -- but if I face any issues I'll likely have to set the status text directly within the script calling `tmux`.

Things to do:
* make the window names even better or selective around what args are listed, e.g. like [tmux-window-name](https://github.com/ofirgall/tmux-window-name)

## Screenshot

![screenshot](screenshot.png)

## Installation

Just source this in your `.zshrc` :)
