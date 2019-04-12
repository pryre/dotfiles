###Backends
#
#This may cause crashes

#GTK
#GDK_BACKEND=wayland
#CLUTTER_BACKEND=wayland

#SDL
#SDL_VIDEODRIVER=wayland

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
