" red background when line >80 chars
if exists('+colorcolumn')
  set colorcolumn=80
  highlight ColorColumn ctermbg=236
else
  au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v\%<82v.', -1)
endif
