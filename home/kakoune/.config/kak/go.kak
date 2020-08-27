hook global WinSetOption filetype=go %{
  set buffer formatcmd 'goimports'
  hook buffer BufWritePre .* %{format}
}
