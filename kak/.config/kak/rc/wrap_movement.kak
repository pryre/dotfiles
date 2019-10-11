declare-option bool linenumbers false
set-option global linenumbers true
define-command move-visual-line -params 1 %{
	    execute-keys %sh{
		n=$(tput cols)
		if [ $kak_opt_linenumbers ]; then
			x=$(echo $kak_buf_line_count | wc --chars)
			n=$(expr $n - $x)
		fi
		printf "%s\n" "${n}$1"
	    }
}

map global normal <up> '<esc>: move-visual-line h<ret>'
map global normal <down> '<esc>: move-visual-line l<ret>'
map global normal <s-up> '<esc>: move-visual-line H<ret>'
map global normal <s-down> '<esc>: move-visual-line L<ret>'

