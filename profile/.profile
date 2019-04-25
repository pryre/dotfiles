###Backends
#
#This may cause crashes

#GTK
export GDK_BACKEND=wayland
#CLUTTER_BACKEND=wayland

#Qt
#QT_QPA_PLATFORM=wayland-egl

#SDL
export SDL_VIDEODRIVER=wayland

#Java
#_JAVA_AWT_WM_NONREPARENTING=1



### Theming
#
export QT_QPA_PLATFORMTHEME="qt5ct"

#GTK_THEME is more of a debug override, can't set cursors, etc.
#export GTK_THEME=Adwaita:dark

gsettings set org.gnome.desktop.interface cursor-theme capitaine-cursors
gsettings set org.gnome.desktop.interface icon-theme la-capitaine-icon-theme
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark


### Sway auto-start
#
if [[ -z $DISPLAY ]]; then #&& [[ $(tty) = /dev/tty1 ]]; then
	export XDG_SESSION_TYPE=wayland
	export XKB_DEFAULT_LAYOUT=us

	SWAYCACHE=$HOME/.cache/sway
	mkdir -p $SWAYCACHE
	mv $SWAYCACHE/sway.log $SWAYCACHE/sway.log.last
	exec sway 2> $SWAYCACHE/sway.log
fi

