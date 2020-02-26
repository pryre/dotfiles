set -gx PATH $HOME/.local/bin $PATH
if set -q XDG_CONFIG_HOME
	set -g FISH_CONFIG_DIR $XDG_CONFIG_HOME/fish
else
	set -g FISH_CONFIG_DIR $HOME/.config/fish
end

set -gx EDITOR kak
set -gx PAGER kak-pager
set -gx MANPAGER kak-man-pager

alias ed $EDITOR

# Theme
source $FISH_CONFIG_DIR/theme.fish

# Machine-Specific

if test -e $FISH_CONFIG_DIR/host.(hostname).fish
    source $FISH_CONFIG_DIR/host.(hostname).fish
end

