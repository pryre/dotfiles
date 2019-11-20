function fish_prompt
		set chost (set_color white)'['(set_color $fish_color_user)$USER(set_color $fish_color_normal)'@'(set_color $fish_color_host)(prompt_hostname)(set_color white)']'(set_color normal)
		set cdir (set_color green)(prompt_pwd_short)(set_color normal)
		set cprompt (set_color white)"> "(set_color normal)

	    echo $chost' '$cdir$cprompt
end

