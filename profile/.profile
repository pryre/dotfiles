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
export npm_config_prefix="$HOME/.local"

export EDITOR=kak
export PAGER=kak-pager
export MANPAGER=kak-man-pager

export CALIBRE_USE_DARK_PALETTE=1

#stty -ctlecho

# alias ed="$EDITOR"
# alias ls='ls --color=auto'
# alias la='ls -a'

# # Temporary Folder
# TMP_HOME_NAME="$HOME/Tmp"
# # If we have a temp dir, and
# if [ -d "$XDG_RUNTIME_DIR" ]; then
# 	# Get rid of the old copy if it exists
# 	if [ -L "$TMP_HOME_NAME" ] && [ -e "$TMP_HOME_NAME" ]; then
# 		rm "$TMP_HOME_NAME"
# 	fi

# 	TMP_RUN_NAME="$XDG_RUNTIME_DIR/user_tmp"
# 	mkdir -p "$TMP_RUN_NAME"
# 	ln -s "$TMP_RUN_NAME" "$TMP_HOME_NAME"
# fi

### Sway auto-start
if [ -z $DISPLAY ] && [ -f /usr/bin/sway ] && [ $(tty) = /dev/tty1 ]; then
	# export XDG_SESSION_TYPE=wayland
	# export XKB_DEFAULT_LAYOUT=us

	###Backends
	#
	#This may cause crashes

	#GTK
	# export GDK_BACKEND=wayland
	#export CLUTTER_BACKEND=wayland

	#Qt (should use wayland by default)
	#export QT_QPA_PLATFORM=xcb
	# export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

	#SDL
	#export SDL_VIDEODRIVER=wayland

	#Java
	# export _JAVA_AWT_WM_NONREPARENTING=1

	### Theming
	#
	export QT_QPA_PLATFORMTHEME="qt5ct"

	#GTK_THEME is more of a debug override, can't set cursors, etc.
	#export GTK_THEME=Adwaita:dark

	# gsettings set org.gnome.desktop.interface cursor-theme capitaine-cursors
	# gsettings set org.gnome.desktop.interface icon-theme la-capitaine-icon-theme
	# gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark

	### Run Sway
	#
	#export WLR_RDP_TLS_CERT_PATH=$HOME/.ssh/rdp/tls.crt
	#export WLR_RDP_TLS_KEY_PATH=$HOME/.ssh/rdp/tls.key
	#export WLR_BACKENDS=rdp

	# export XDG_CURRENT_DESKTOP=sway
	# export XDG_SESSION_TYPE=wayland

	# export XDG_CURRENT_DESKTOP=Unity
	#export XDG_CURRENT_DESKTOP=sway
	#export XDG_SESSION_TYPE=wayland
	#export XKB_DEFAULT_LAYOUT=us

	# SWAYCACHE=$HOME/.cache/sway
	# mkdir -p $SWAYCACHE
	# mv $SWAYCACHE/sway.log $SWAYCACHE/sway.log.old
	# dbus-run-session sway > $SWAYCACHE/sway.log 2>&1
	exec sway-run.sh
fi

if [ -z $DISPLAY ] && [ -f /usr/bin/startxfce4 ] && [ $(tty) = /dev/tty2 ]; then
	exec startxfce4
fi
