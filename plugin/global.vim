" double quotes
inoremap <buffer> " <C-R>=<SID>Double('"','"')<CR>
function! s:Double(left,right)
    if strpart(getline(line(".")),col(".")-2,2) == a:left . a:right
	return "\<Del>"
    else
	return a:left . a:right . "\<Left>"
    endif
endfunction

