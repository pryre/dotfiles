##
## base16.kak by lenormf
##

evaluate-commands %sh{
    base00='rgb:1A1A1A'
    base01='rgb:262626'
    base02='rgb:333333'
    base03='rgb:888888'
    base04='rgb:996632'
    base05='rgb:CC8843'
    base06='rgb:FFFFFF'
    base07='rgb:999999'
    base08='rgb:CC4343'
	base09='rgb:CC4343'
    base0A='rgb:326699'
    base0B='rgb:669932'
    base0C='rgb:CCCCCC'
    base0D='rgb:996632'
    base0E='rgb:993266'
    base0F='rgb:ABABAB'

    ## code
    echo "
        face global value ${base09}+b
        face global type ${base08}
        face global variable ${base08}
        face global module ${base0B}
        face global function ${base0D}
        face global string ${base0B}
        face global keyword ${base0E}+b
        face global operator ${base04}
        face global attribute ${base09}+b
        face global comment ${base03}
        face global meta ${base0F}
        face global builtin default+b
    "

    ## markup
    echo "
        face global title ${base0A}
        face global header ${base04}
        face global bold ${base0F}
        face global italic ${base0F}
        face global mono ${base0B}
        face global block ${base0F}
        face global link ${base0A}
        face global bullet ${base08}
        face global list ${base08}
    "

    ## builtin
    echo "
        face global Default ${base05},${base00}
        face global PrimarySelection ${base06},${base02}+fg
        face global SecondarySelection ${base03},${base02}+fg
        face global PrimaryCursor ${base00},${base05}+fg
        face global SecondaryCursor ${base00},${base04}+fg
        face global PrimaryCursorEol ${base00},${base04}+fg
        face global SecondaryCursorEol ${base00},${base03}+fg
        face global LineNumbers ${base05},${base00}
        face global LineNumberCursor ${base05},${base01}+b
        face global MenuForeground ${base04},${base00}
        face global MenuBackground ${base00},${base04}
        face global MenuInfo ${base04}
        face global Information ${base01},${base04}
        face global Error ${base05},${base08}
        face global StatusLine ${base05},${base02}
        face global StatusLineMode ${base0F}
        face global StatusLineInfo ${base04}
        face global StatusLineValue ${base0B}
        face global StatusCursor ${base02},${base04}
        face global Prompt ${base01},${base04}
        face global MatchingChar ${base04},${base01}+b
        face global BufferPadding ${base04},${base00}
        face global Whitespace ${base04}+f
    "
}
