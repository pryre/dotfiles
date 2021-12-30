function set_background
	if not set -q WAYLAND_DISPLAY
		echo "Error: Can't find display"
		return 1
	end

	set -l BGPID (pgrep swaybg | head -n1)
	if not set -q BGPID
		echo "Error: Can't find swaybg"
		return 1
	end

	if set -q argv[1]
		ln -sf "$argv[1]" $HOME/.background
		swaymsg exec "swaybg -i $HOME/.background -m fill"
		sleep 2
		kill $BGPID
	else
		echo "Usage: setbackground IMAGE_PATH"
		return 1
	end
end
