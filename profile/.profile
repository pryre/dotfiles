### User directories
# export XDG_CONFIG_HOME=$HOME/.config
# export XDG_CACHE_HOME=$HOME/.cache
# export XDG_DATA_HOME=$HOME/.local/share

### If not running interactively, don't do else
case $- in
	*i*) ;;
	*) return;;
esac

### User Setup For Interractive Shells
#export PATH=~/.local/bin:$PATH
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
   export PATH="$HOME/.local/bin:$PATH"
fi

export EDITOR=kak
export PAGER=kak-pager
export MANPAGER=kak-man-pager

#stty -ctlecho

# alias ed="$EDITOR"
# alias ls='ls --color=auto'
# alias la='ls -a'


if [ "$BASH" ] ; then
	source $HOME/.bashrc
fi

### Sway auto-start
if [ -z $DISPLAY ] && [ -f /usr/bin/sway ] && [ $(tty) = /dev/tty1 ]; then
	export XDG_SESSION_TYPE=wayland
	export XKB_DEFAULT_LAYOUT=us

	###Backends
	#
	#This may cause crashes

	#GTK
	export GDK_BACKEND=wayland
	#export CLUTTER_BACKEND=wayland

	#Qt (should use wayland by default)
	#export QT_QPA_PLATFORM=xcb
	export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

	#SDL
	#export SDL_VIDEODRIVER=wayland

	#Java
	export _JAVA_AWT_WM_NONREPARENTING=1

	### Theming
	#
	export QT_QPA_PLATFORMTHEME="qt5ct"

	#GTK_THEME is more of a debug override, can't set cursors, etc.
	#export GTK_THEME=Adwaita:dark

	gsettings set org.gnome.desktop.interface cursor-theme capitaine-cursors
	gsettings set org.gnome.desktop.interface icon-theme la-capitaine-icon-theme
	gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark

	### Run Sway
	#
	#export WLR_RDP_TLS_CERT_PATH=$HOME/.ssh/rdp/tls.crt
	#export WLR_RDP_TLS_KEY_PATH=$HOME/.ssh/rdp/tls.key
	#export WLR_BACKENDS=rdp

	SWAYCACHE=$HOME/.cache/sway
	mkdir -p $SWAYCACHE
	mv $SWAYCACHE/sway.log $SWAYCACHE/sway.log.old
	exec sway > $SWAYCACHE/sway.log 2>&1
fi

