if !exists( "*RubyEndToken" )

  function RubyEndToken ()
    let current_line = getline('.')
    let braces_at_end = '{\s*\(|\(,\|\s\|\w\)*|\s*\)\?\(\s*#.*\)\?$'
    let stuff_without_do = '^\s*\<\(class\|if\|unless\|begin\|case\|for\|module\|while\|until\|def\)\>'
    let with_do = '\<do\>\s*\(|\(,\|\s\|\w\)*|\s*\)\?\(\s*#.*\)\?$'

    if getpos('.')[2] < len(current_line)
      return "\<CR>"
    elseif match(current_line, braces_at_end) >= 0
      return "\<CR>}\<C-O>O"
    elseif match(current_line, stuff_without_do) >= 0
      return "\<CR>end\<C-O>O"
    elseif match(current_line, with_do) >= 0
      return "\<CR>end\<C-O>O"
    else
      return "\<CR>"
    endif
  endfunction

endif

imap <buffer> <CR> <C-R>=RubyEndToken()<CR>

inoremap <buffer> ;< <%=  %><Esc>F<Space>i
inoremap <buffer> ;> <%  -%><Esc>F<Space>i

" red background when line >80 chars
if exists('+colorcolumn')
  set colorcolumn=80
else
  au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif
