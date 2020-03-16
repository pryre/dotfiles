define-command tabmode-tabs -params ..1 -docstring "Set the tab mode to use all tabs.\nUsage: tabmode-tabs [width]" %{
	evaluate-commands %sh{
		TABSIZE="${kak_opt_indentwidth}"
		# Default if unset
		if [ "$TABSIZE" -le 0 ]; then TABSIZE="4"; fi
		# Parameter if set
		if [ $1 ]; then if [ "$1" -gt 0 ]; then TABSIZE="$1"; fi; fi

		# Change keys to insert spaces
		printf "map buffer insert <tab> <tab>\n"
		# printf "map buffer insert <s-tab> '<a-;><lt>'\n"

		# Visual display
		printf "set-option buffer tabstop ${TABSIZE}\n"
		printf "set-option buffer indentwidth 0\n"
		printf "set-option buffer aligntab true\n"
	}
}

define-command tabmode-spaces -params ..1 -docstring "Set the tab mode to use all spaces.\nUsage: tabmode-spaces [width]" %{
	evaluate-commands %sh{
		TABSIZE="${kak_opt_indentwidth}"
		# Default if unset
		if [ "$TABSIZE" -le 0 ]; then TABSIZE="4"; fi
		# Parameter if set
		if [ $1 ]; then if [ "$1" -gt 0 ]; then TABSIZE="$1"; fi; fi

		# Change keys to insert spaces
		printf "map buffer insert <tab> '%${TABSIZE}s'\n"
		# printf "map buffer insert <s-tab> '<a-;><lt>'\n"

		# Visual display
		printf "set-option buffer tabstop ${TABSIZE}\n"
		printf "set-option buffer indentwidth ${TABSIZE}\n"
		printf "set-option buffer aligntab false\n"
	}
}
