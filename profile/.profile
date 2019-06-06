### Sway auto-start
#
if [ -z $DISPLAY ] && [ -f /usr/bin/sway ] && [ $(tty) = /dev/tty1 ]; then
	export XDG_SESSION_TYPE=wayland
	export XKB_DEFAULT_LAYOUT=us

	###Backends
	#
	#This may cause crashes

	#GTK
	export GDK_BACKEND=wayland
	#export CLUTTER_BACKEND=wayland

	#Qt
	#QT_QPA_PLATFORM=wayland-egl
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
	SWAYCACHE=$HOME/.cache/sway
	mkdir -p $SWAYCACHE
	mv $SWAYCACHE/sway.log $SWAYCACHE/sway.log.old
	exec sway 2> $SWAYCACHE/sway.log
	
	#WLR_RDP_TLS_CERT_PATH=$HOME/.ssh/tls.crt \
	#WLR_RDP_TLS_KEY_PATH=$HOME/.ssh/tls.key \
	#WLR_BACKENDS=rdp \
	#sway
fi

