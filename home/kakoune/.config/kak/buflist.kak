declare-option -hidden str-list buflist_info

define-command buflist %{
  edit -scratch *buflist*
  set-option window filetype 'buflist'
  set-option global buflist_info
  evaluate-commands -no-hooks -buffer * %{
    set-option -add global buflist_info "%val{bufname}|%val{modified}"
  }
  execute-keys '%d'
  execute-keys -draft %sh{
    eval "set -- $kak_quoted_opt_buflist_info"
    for info; do
      printf 'i %s<ret><esc>' "$info"
    done
  }
  execute-keys 'ged'
  execute-keys '%|sort<ret>'
  execute-keys '%<a-s>gif|;dedgii[] <esc>hhP'
  try %{ execute-keys '%<a-s>gi<a-i>[<a-k>false<ret>c <esc>' }
  try %{ execute-keys '%<a-s>gi<a-i>[<a-k>true<ret>c*<esc>' }
  execute-keys 'gg'
}

define-command -hidden buflist-open %{
  evaluate-commands -no-hooks  %{
    execute-keys 'gif]llGl'
    buffer %val{selection}
  }
}

hook global WinSetOption filetype=buflist %{
  map buffer normal <ret> ':<space>buflist-open<ret>'
  add-highlighter window/buflist group
  add-highlighter window/buflist/ regex '^[^\n]+$'   0:comment
  add-highlighter window/buflist/ regex '^ \[([ *])\] ([^\n]+)$'  1:yellow 2:link
}
