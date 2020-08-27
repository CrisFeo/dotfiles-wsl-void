declare-option -hidden str dir_cd '.'

define-command -params .. dir %{
  set-option global dir_cd .
  evaluate-commands %sh{
    case "$1" in
      '') dir="$(dirname "$kak_buffile")" ;;
      ~*) dir="$HOME/${1#?}" ;;
       *) dir="$1" ;;
    esac
    echo "dir-show '$dir'"
  }
}

define-command -hidden -params .. dir-show %{
  edit -scratch *dir*
  set-option window filetype 'dir'
  evaluate-commands %sh{
    case "$1" in
      /*) dir="$1" ;;
       *) dir="$kak_opt_dir_cd/$1" ;;
    esac
    dir="$(readlink -f "$dir")"
    echo "set-option global dir_cd '$dir'"
  }
  execute-keys -draft %sh{
    echo "%di$kak_opt_dir_cd<ret><esc>"
    list_cmd="ls<space>-ap<space>'$kak_opt_dir_cd'"
    sed_cmd="sed<space>-e<space>'s#^#<space>#'"
    echo "!$list_cmd|$sed_cmd<ret>"
  }
  try %{ execute-keys -draft %{ %<a-s><a-k>^$<ret>d } }
  try %{ execute-keys -draft %{ ggjxs^<space>\./$<ret>xd } }
  execute-keys 'ggj'
}

define-command -hidden dir-forward %{
  evaluate-commands -draft %{
    execute-keys %{ <a-/>^[^<space>]<ret>x_ }
    set-option global dir_cd %val{selection}
    echo -debug %opt{dir_cd}
  }
  execute-keys '<a-s>;x_<space>'
  evaluate-commands %sh{
    selection="$(echo "$kak_selection" | sed 's#^ ##')"
    target="$kak_opt_dir_cd/$selection"
    if [ -d "$target" ]; then
      echo "dir-show '$selection'"
    else
      echo "edit '$target'"
    fi
  }
}

hook global WinSetOption filetype=dir %{
  map buffer normal <ret>       ':<space>dir-forward<ret>'
  map buffer normal <backspace> ':<space>dir-show ..<ret>'
  add-highlighter window/dir group
  add-highlighter window/dir/ regex '^[^\n]+$'   0:comment
  add-highlighter window/dir/ regex '^ [^\n]+$'  0:list
  add-highlighter window/dir/ regex '^ [^\n]+/$' 0:link
}
