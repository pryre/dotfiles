define-command -params ..1 \
    -docstring %{spell-tex [<language>]: spell check the current buffer using tex mode
The first optional argument is the language against which the check will be performed
Formats of language supported:
 - ISO language code, e.g. 'en'
 - language code above followed by a dash or underscore with an ISO country code, e.g. 'en-US'} \
    spell-tex %{
    try %{ add-highlighter window/ ranges 'spell_regions' }
    evaluate-commands %sh{
        file=$(mktemp -d "${TMPDIR:-/tmp}"/kak-spell.XXXXXXXX)/buffer
        printf 'eval -no-hooks write -sync %s\n' "${file}"
        printf 'set-option buffer spell_tmp_file %s\n' "${file}"
    }
    evaluate-commands %sh{
        if [ $# -ge 1 ]; then
            if [ ${#1} -ne 2 ] && [ ${#1} -ne 5 ]; then
                echo "echo -markup '{Error}Invalid language code (examples of expected format: en, en_US, en-US)'"
                rm -rf "$(dirname "$kak_opt_spell_tmp_file")"
                exit 1
            else
                options="-l '$1'"
                printf 'set-option buffer spell_lang %s\n' "$1"
            fi
        fi

        {
            sed 's/^/^/' "$kak_opt_spell_tmp_file" | eval "aspell --mode=tex --byte-offsets -a $options" 2>&1 | {
                line_num=1
                regions=$kak_timestamp
                read line # drop the identification message
                while read -r line; do
                    case "$line" in
                        [\#\&]*)
                            if expr "$line" : '^&' >/dev/null; then
                               pos=$(printf %s\\n "$line" | cut -d ' ' -f 4 | sed 's/:$//')
                            else
                               pos=$(printf %s\\n "$line" | cut -d ' ' -f 3)
                            fi
                            word=$(printf %s\\n "$line" | cut -d ' ' -f 2)
                            # trim whitespace to make `wc` output consistent across implementations
                            len=$(($(printf %s "$word" | wc -c)))
                            regions="$regions $line_num.$pos+${len}|Error"
                            ;;
                        '') line_num=$((line_num + 1));;
                        \*) ;;
                        *) printf 'echo -markup %%{{Error}%s}\n' "${line}" | kak -p "${kak_session}";;
                    esac
                done
                printf 'set-option "buffer=%s" spell_regions %s' "${kak_bufname}" "${regions}" \
                    | kak -p "${kak_session}"
            }
            rm -rf $(dirname "$kak_opt_spell_tmp_file")
        } </dev/null >/dev/null 2>&1 &
    }
}
