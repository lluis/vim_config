" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"             for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"           for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

if has("gui_running")
  colorscheme koehler
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" https://github.com/tpope/vim-pathogen
call pathogen#infect()

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup          " do not keep a backup file, use versions instead
else
  set backup            " keep a backup file
endif
set history=100         " keep 100 lines of command line history
set ruler               " show the cursor position all the time
set showcmd             " display incomplete commands
set incsearch           " do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" navigate split windows with ALT + Arrows
nmap <A-Down> <C-W><C-J>
nmap <A-Up> <C-W><C-K>
nmap <A-Right> <C-W><C-L>
nmap <A-Left> <C-W><C-H>
" More natural split opening
set splitbelow
set splitright

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Modern terminals support 256 colors, but sometimes you need to kick Vim to
" recognize this
if $TERM == "xterm-256color" || $TERM == "screen-256color" || $COLORTERM == "gnome-terminal"
  set t_Co=256
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Create unexisting directories on save
" http://stackoverflow.com/questions/4292733/vim-creating-parent-directories-on-save
function s:MkNonExDir(file, buf)
  if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
    let dir=fnamemodify(a:file, ':h')
    if !isdirectory(dir)
      call mkdir(dir, 'p')
    endif
  endif
endfunction
augroup BWCCreateDir
  autocmd!
  autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
augroup END

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
    au!

    " For all text files set 'textwidth' to 78 characters.
    "autocmd FileType text setlocal textwidth=78

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid or when inside an event handler
    " (happens when dropping a file on gvim).
    autocmd BufReadPost *
          \ if line("'\"") > 0 && line("'\"") <= line("$") |
          \   exe "normal g`\"" |
          \ endif

  augroup END

else

  set autoindent                " always set autoindenting on

endif " has("autocmd")

" Per fer mes llegible la lletra, x quan tens el fons negre
set background=dark

" Espais que ha de fer al apretar la tecla TAB
set tabstop=4

" Espais que ha de fer l'auto-indent (quan escrius codi)
set shiftwidth=2

" Fes espais en comptes de tabuladors
set expandtab

" Auto-timestamp
" let timestamp_regexp = '\v\C%((<Last %([cC]hanged?|[Mm]odified):\s+)|(\* \@version\s+))@<=.*$'
let timestamp_regexp = '\v\C%((<[Uu]ltim[a]* %([cC]anvi?|[Mm]odificacio):\s+)|(\* \@version\s+)|([Ll]ast [Cc]hanged: ))@<=.*$'
set modelines=20

set title

set autochdir
"if has('unnamedplus')
"  set clipboard^=unnamed,unnamedplus
"else
"  set clipboard^=unnamed
"endif
set clipboard=unnamed

" ignorecase plus smartcase make searches case-insensitive except when you
" include upper-case characters
set ignorecase
set smartcase

" powerline
" gap on arrow https://github.com/Lokaltog/powerline/issues/359
" in gitconfig set color=auto to solve branch display issues
set rtp+=~/.vim/bundle/powerline/powerline/bindings/vim
set laststatus=2
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)
" escape insert mode immediately
if ! has('gui_running')
    set ttimeoutlen=10
    augroup FastEscape
        autocmd!
        au InsertEnter * set timeoutlen=0
        au InsertLeave * set timeoutlen=1000
    augroup END
endif

" cometes en mode visual block, :help VISUAL
vmap " <Esc>`>a"<Esc>hlx`<i"<Esc>hlx

vmap f <Esc>`>a'.t %>><Esc>hlx`<i<%= ''<Esc>hlx
"vmap f <Esc>`>a' %><Esc>`<i<%= t '<Esc>
vmap g <Esc>`>a' %><Esc>`<hhi<%= t '<Esc>
vmap V <Esc>`>a') <Esc>hlx`<i T_(''<Esc>hlx

" next/previous buffer
:nmap <C-n> :bnext<CR>
:nmap <C-b> :bprev<CR>
:nmap , :CtrlPBuffer<CR>

" tabs
:nmap <S-Right> :tabnext<CR>
:nmap <S-Left> :tabprev<CR>

" file navigation
:nmap <C-a> :NERDTreeToggle<CR>
let NERDTreeQuitOnOpen = 1

" ignores pel CtrlP
let g:ctrlp_custom_ignore = 'node_modules\|build\|tmp'

" Treure el destacat actual a l'apretar espai, per exemple al cercar
:nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

" amaga els comentaris, zo per obrirlos i zc per tancar-los
"set fdm=expr
"set fde=getline(v:lnum)=~'^\\s*#'?1:getline(prevnonblank(v:lnum))=~'^\\s*#'?1:getline(nextnonblank(v:lnum))=~'^\\s*#'?1:0

" completar fitxers com al shell
set wildmode=longest,list:longest,list:full

" vimdiff: ignore spaces
set diffopt+=iwhite

" Match all forms of brackets in pairs (including angle brackets)
set matchpairs=(:),{:},[:],<:>

" If the Vim buffer for a file doesn't have any changes and Vim detects the
" file has been altered, quietly update it
set autoread

if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  au! BufRead,BufNewFile *.pp     setfiletype puppet
augroup END
