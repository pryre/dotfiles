set -gx PATH $HOME/.local/bin $PATH

set -gx EDITOR kak
set -gx PAGER kak-pager
set -gx MANPAGER kak-man-pager

alias ed $EDITOR

# Theme
source $XDG_CONFIG_HOME/fish/config.theme

