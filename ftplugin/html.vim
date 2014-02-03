" vim filetype plugin
" Language:	HTML
" Maintainer: Carl Mueller, cmlr@math.rochester.edu
" Last Change:	October 10, 2002
" Version:  1.1
" Website:  http://www.math.rochester.edu/u/cmlr/vim/syntax/index.html
" This is an html mode.  Typing "<" produces "<>" with the cursor in
" between.  After that, you should be able to do everything else with the
" F1 key.  There are also Auctex style macros.  For example, ;1 inserts
" <h1></h1> with the cursor in between.  ;ta inserts <table></table> and
" ;td inserts <td></td>.

noremap <buffer> <C-Tab> :!firefox file:$PWD/% &<CR><Esc>
inoremap <buffer> <C-Tab> <C-C>:!firefox file:$PWD/% &<CR><Esc>

" Let % work with <...> pairs.
set matchpairs+=<:>

set autoindent
"set shiftwidth=2
set smarttab
set smartindent
set textwidth=0

" In normal mode, F1 inserts an html template.
noremap <buffer> <F1> :if strpart(getline(1),0,6) !~ "^<\[Hh]\[Tt]\[Mm]\[Ll]>"&&strpart(getline(2),0,6) !~ "^<\[Hh]\[Tt]\[Mm]\[Ll]>"<CR>0read ~/.vim/html-template.vim<CR>normal /<\/title\\|<\/TITLE<CR><CR>:endif<CR>4jf>a
inoremap <buffer> ;html  <ESC>:if strpart(getline(1),0,6) !~ "^<\[Hh]\[Tt]\[Mm]\[Ll]>"&&strpart(getline(2),0,6) !~ "^<\[Hh]\[Tt]\[Mm]\[Ll]>"<CR>0read ~/.vim/html-template.vim<CR>normal /<\/title\\|<\/TITLE<CR><CR>:endif<CR>4jf>a

" In insert mode, F1 looks back to find the last uncompleted <> tag, and
" inserts the completion.  It ignores uncompleted <hr>, <p>, <li>, <im..>,
" and their capitalized forms.  F2 does the same, but puts blank lines in
" between.
inoremap <buffer> <F1> <Esc>:call <SID>OneLineCompletion()<CR>a
" For the above, get the script closetag.vim from vim.sf.net
""inoremap <buffer> <F2> <Esc>:call <SID>ThreeLineCompletion()<CR>a
" noremap <buffer> <F2> :!firefox file:$PWD/% > /dev/null 2>&1 &<CR><Esc>
" inoremap <buffer> <F3> <a href=""></a><Esc>5hi
" inoremap <buffer> <F4> <a href="mailto:"></a><Esc>5hi
" inoremap <buffer> <F5> <IMG src="" alt=""><Esc>8hi
" inoremap <buffer> <M-c> <!--  --><Esc>3hi
" inoremap <buffer> <M-h> <a href=""></a><Esc>5hi
" inoremap <buffer> <M-i> <IMG src="" alt=""><Esc>8hi
" inoremap <buffer> <M-m> <a href="mailto:"></a><Esc>5hi

" In visual mode, F1 encloses the selected region in
" a pair of <>...</> braces.
function! s:InsertTag(tag)
    exe "normal `>a\<C-V></" . a:tag . ">\<Esc>`<i<" . a:tag . "\<Esc>l"
endfunction

vnoremap <buffer> <F1> <C-C>:call <SID>InsertTag(input("HTML Tag? "))<CR>

" Another way to insert the tag:
inoremap <buffer> <C-F1> <Esc>:call <SID>PutInTag(input("Tag? "))<CR>

function! s:PutInTag(tag)
    exe "normal a<" . a:tag . "\<Esc>la</" . a:tag . "\<Esc>F<"
    startinsert
endfunction

inoremap <buffer> " <C-R>=<SID>Double('"','"')<CR>
function! s:Double(left,right)
    if strpart(getline(line(".")),col(".")-2,2) == a:left . a:right
	return "\<Del>"
    else
	return a:left . a:right . "\<Left>"
    endif
endfunction

" If you have just used F1 in visual mode to insert a pair of <>...</>
" braces, you can type in what goes in the first, and then F1 will complete
" it.

" This function sees whether you are inside a <...> and moves you to the >
" if you are.  Otherwise it stays where it is.  Then it completes the last
" unmatched <...>, excluding <p> and <br> and <li>.  If </p>, etc. are
" present, they will screw things up.

function! s:OneLineCompletion()
    let string = strpart(getline(line(".")),0,col("."))
    if string =~ "<\[^>]\*$"
	normal f>
    endif
    exe "normal v\<Esc>"
    call <SID>GoBackwardToTag()
    exe "normal ly/\\W\<CR>"
    exe "normal `<a\<C-V></\<Esc>pa>\<Esc>"
endfunction

" This function is the same as the last, except it puts the matching
" </...> three lines down, if you are inside a <...>.

function! s:ThreeLineCompletion()
    let string = strpart(getline(line(".")),0,col("."))
    let inside = 0
    if string =~ "<\[^>]\*$"
	normal f>
	let inside = 1
    endif
    exe "normal v\<Esc>"
    call <SID>GoBackwardToTag()
    exe "normal ly/\\W\<CR>"
    if inside
	exe "normal `<a\<CR>\<CR></\<Esc>pk"
    else
	exe "normal `<a</\<Esc>pl"
    endif
endfunction

" This function searches backward for the first unmatched <...>
" WARNING!!  It ignores <p>, <br>, <li>, <im..>, and their capitalized
" versions.  It will miscount if these are completed with </p>, etc.
" Make sure you have a <HTML> or <html> or <Html>, etc, at the start of
" your file, or this function won't work.

function! s:GoBackwardToTag()
    let found = 2
    while found > 1
	exe "normal ?<\<CR>"
	let string = strpart(getline(line(".")),col("."),2)
	if string[0] == '/'
		let found = found + 1
	elseif string !~ "!-\\\|\[Pp]>\\\|\[Bb]\[Rr]\\\|\[Ll]\[Ii]\\\|\[Hh]\[Rr]\\\|\[Ii]\[Mm]"
		let found = found - 1
	endif
    endwhile
endfunction

noremap <buffer> <C-Del> :call <SID>DeleteTagForward()<CR>
function! s:DeleteTagForward()
    let string = strpart(getline(line(".")),col(".")-1,3)
    if string[0] == "<" && string[1] != "/"
	normal df>
	let look = strpart(string,1,2)
	if look[1] == " "
	    let look = look[0] . ">"
	endif
	exe "normal /<\\/" . look . "\<CR>"
	normal df>
    endif
endfunction

" xhtml "
set notimeout
inoremap <buffer> ;; ;
inoremap <buffer> ;<! <!--  --><Esc>F<Space>i

inoremap <buffer> ;head <head><Esc>o<meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><Esc>o</head><Esc>O
inoremap <buffer> ;title <title></title><Esc>7hi
inoremap <buffer> ;body <body><Esc>o</body><Esc>O

inoremap <buffer> ;stylet <style type="text/css" media="screen">@import "";</style><ESC>9hi
inoremap <buffer> ;script <script type="text/javascript" src=""></script><ESC>F"i

inoremap <buffer> ;1 <h1></h1><ESC>F<i
inoremap <buffer> ;2 <h2></h2><ESC>F<i
inoremap <buffer> ;3 <h3></h3><ESC>F<i
inoremap <buffer> ;4 <h4></h4><ESC>F<i
inoremap <buffer> ;5 <h5></h5><ESC>F<i

inoremap <buffer> ;br <br />
inoremap <buffer> ;hr <hr />

inoremap <buffer> ;em <em></em><Esc>F<i
inoremap <buffer> ;p <p></p><Esc>F<i
inoremap <buffer> ;s <strong></strong><Esc>F<i
inoremap <buffer> ;b <b></b><Esc>F<i

inoremap <buffer> ;acronym <acronym title=""></acronym><Esc>F"i
inoremap <buffer> ;abbr <abbr title=""><Esc>F"i
inoremap <buffer> ;cite <cite></cite><Esc>F<i
inoremap <buffer> ;code <code></code><Esc>F<i
inoremap <buffer> ;ad <address></address><Esc>F<i
inoremap <buffer> ;bq <blockquote><Esc>o</blockquote><Esc>O
inoremap <buffer> ;str <strike></strike><Esc>F<i

inoremap <buffer> ;ul <ul><Esc>o</ul><Esc>O
inoremap <buffer> ;ol <ol><Esc>o</ol><Esc>O
inoremap <buffer> ;li <li></li><Esc>F<i

inoremap <buffer> ;img <img src="" alt="" /><Esc>10hi
inoremap <buffer> ;ah <a href="" title=""></a><Esc>14hi
inoremap <buffer> ;am <a href="mailto:"></a><Esc>F"i
inoremap <buffer> ;an <a name=""></a><Esc>F"i

inoremap <buffer> ;div <div class=""><Esc>o</div><Esc>k6la
inoremap <buffer> ;span <span class=""></span><Esc>6hi

inoremap <buffer> ;table <table><Esc>o</table><Esc>O
inoremap <buffer> ;td <td></td><Esc>F<i
inoremap <buffer> ;th <th></th><Esc>F<i
inoremap <buffer> ;tr <tr><Esc>o</tr><Esc>O
inoremap <buffer> ;cap <caption></caption><Esc>F<i

" formularios "
inoremap <buffer> ;form <form name="" method="" action=""><Esc>o</form><Esc>O
inoremap <buffer> ;ih <input type="hidden" name="" value="" /><Esc>12hi
inoremap <buffer> ;it <input type="text" name="" value="" /><Esc>12hi
inoremap <buffer> ;ip <input type="password" name="" value="" /><Esc>12hi
inoremap <buffer> ;ichk <input type="checkbox" name="" value="" /><Esc>12hi
inoremap <buffer> ;ir <input type="radio" name="" value="" /><Esc>12hi
inoremap <buffer> ;ib <input type="button" name="" value="" /><Esc>12hi
inoremap <buffer> ;ir <input type="reset" name="" value="" /><Esc>12hi
inoremap <buffer> ;if <input type="file" name="" value="" /><Esc>12hi
inoremap <buffer> ;ta <textarea name=""></textarea><Esc>F"i
inoremap <buffer> ;sel <select name=""><Esc>o</select><Esc>O
inoremap <buffer> ;opt <option value=""></option><Esc>F"i
inoremap <buffer> ;label <label for=""></label><Esc>F"i

" utf-8 "
inoremap <buffer> ;& &amp; <ESC>i

inoremap <buffer> ;Ã¡ &#225; <ESC>i
inoremap <buffer> ;Ã© &#233; <ESC>i
inoremap <buffer> ;Ã­ &#237; <ESC>i
inoremap <buffer> ;Ã³ &#243; <ESC>i
inoremap <buffer> ;Ãº &#250; <ESC>i

inoremap <buffer> ;Ã~A &#193; <ESC>i
inoremap <buffer> ;Ã~I &#201; <ESC>i
inoremap <buffer> ;Ã~M &#205; <ESC>i
inoremap <buffer> ;Ã~S &#211; <ESC>i
inoremap <buffer> ;Ã~Z &#218; <ESC>i

inoremap <buffer> ;? &#63; <ESC>i
inoremap <buffer> ;Â¿ &#191; <ESC>i
inoremap <buffer> ;! &#33; <ESC>i
inoremap <buffer> ;Â¡ &#161; <ESC>i
inoremap <buffer> ;@ &#64; <ESC>i


" Auctex style for the visual mode.  Surrounds the region by the
" appropriate pair of tags.
" vnoremap <buffer> <F3> <C-C>`>a</a<C-V>><Esc>`<i<a href=""><Esc>v<C-C>`<hi
vnoremap <buffer> ;ah <C-C>`>a</a<C-V>><Esc>`<i<a href=""><Esc>v<C-C>`<hi
vnoremap <buffer> ;1 <C-C>:call <SID>InsertTag("h1")<CR>
vnoremap <buffer> ;2 <C-C>:call <SID>InsertTag("h2")<CR>
vnoremap <buffer> ;3 <C-C>:call <SID>InsertTag("h3")<CR>
vnoremap <buffer> ;4 <C-C>:call <SID>InsertTag("h4")<CR>
vnoremap <buffer> ;5 <C-C>:call <SID>InsertTag("h5")<CR>
vnoremap <buffer> ;ad <C-C>:call <SID>InsertTag("address")<CR>
vnoremap <buffer> ;c <C-C>:call <SID>InsertTag("center")<CR>
vnoremap <buffer> ;dd <C-C>:call <SID>InsertTag("dd")<CR>
vnoremap <buffer> ;dl <C-C>:call <SID>InsertTag("dl")<CR>
vnoremap <buffer> ;dt <C-C>:call <SID>InsertTag("dt")<CR>
vnoremap <buffer> ;e <C-C>:call <SID>InsertTag("em")<CR>
vnoremap <buffer> ;f <C-C>:call <SID>InsertTag("font")<CR>
vnoremap <buffer> ;o <C-C>:call <SID>InsertTag("ol")<CR>
vnoremap <buffer> ;s <C-C>:call <SID>InsertTag("strong")<CR>
vnoremap <buffer> ;ta <C-C>:call <SID>InsertTag("table")<CR>
vnoremap <buffer> ;td <C-C>:call <SID>InsertTag("td")<CR>
vnoremap <buffer> ;th <C-C>:call <SID>InsertTag("th")<CR>
vnoremap <buffer> ;tr <C-C>:call <SID>InsertTag("tr")<CR>
vnoremap <buffer> ;u <C-C>:call <SID>InsertTag("ul")<CR>
vnoremap <buffer> ;C <C-C>`>a --<C-V>><Esc>`<i<!-- <Esc>
vnoremap <buffer> ;R <C-C>`>a ==<C-V>><Esc>`<i<!== <Esc>

" nnoremenu 40.401 Html.template\ \ \ \ \ \ \ \ F1 :if strpart(getline(1),0,6) !~ "^<\[Hh]\[Tt]\[Mm]\[Ll]>"<CR>0read ~/.vim/html-template.vim<CR>normal /<\/title\\|<\/TITLE<CR><CR>:endif<CR>i
" inoremenu 40.402 Html.one-line\ tag\ \ \ \ F1 <Esc>:call <SID>OneLineCompletion()<CR>i
" inoremenu 40.403 Html.two-line\ tag\ \ \ \ F2 <Esc>:call <SID>ThreeLineCompletion()<CR>a
" inoremenu 40.404 Html.href\ \ \ \ \ \ \ \ \ \ \ \ F3 <a href=""></a><Left><Left><Left><Left><Left><Left>
" inoremenu 40.405 Html.email\ \ \ \ \ \ \ \ \ \ \ F4 <a href="mailto:"></a><Left><Left><Left><Left><Left><Left>
" vnoremenu 40.406 Html.embrace\ \ \ \ \ \ \ \ \ F1 <C-C>a <Esc>`>i</><Esc>`<i<><Esc>$x`<a
" inoremenu 40.408 Html.put\ image\ \ \ \ \ \ \ F5 <IMG SRC=""><Left><Left>
