set -gx PATH $HOME/.local/bin $PATH

set -gx EDITOR kak
set -gx PAGER kak-pager
set -gx MANPAGER kak-man-pager

alias ed $EDITOR

# Theme
if set -q XDG_CONFIG_HOME
	set -g THEME_CONFIG $XDG_CONFIG_HOME/fish/config.theme
else
	set -g THEME_CONFIG $HOME/.config/fish/config.theme
end
source $THEME_CONFIG

