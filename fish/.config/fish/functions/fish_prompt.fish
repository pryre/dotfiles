function fish_prompt
		set chost (set_color white)$USER@(prompt_hostname)(set_color normal)
		set cdir (set_color green)(prompt_pwd_short)(set_color normal)

	    echo [$chost] $cdir"> "
end

