function prompt_pwd_short
	set realhome ~
	set -l tmp (string replace -r '^'"$realhome"'($|/)' '~$1' $PWD)

	string replace -ar '^(.*[\\\/])' '' $tmp
end
