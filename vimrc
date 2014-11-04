" - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
" Section 0: Preamble
" - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
" I don't like to maintain 'vi' compatibility
set nocompatible

" Don't create those annoying backup files
set nobackup

let myname = "Orien Vandenbergh"
let myemail = "address@foo.com"

" - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
" Section 1: Appearance
" - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
" Enable syntax highlighting
syntax enable

" Instruct vim to use the syntax colors appropriate for a dark background
set background=dark

" Configure my preferred colorscheme
" Favorites are: wombat, vividchalk, torte, textmate16, solarized and badwolf2
"let g:solarized_termcolor=256
"let g:solarized_contrast="normal"
"let g:solarized_visibility="normal"
"colorscheme solarized
"let g:badwolf_darkgutter=1
colorscheme badwolf2

" Set my default encoding to utf-8
set encoding=utf-8
set termencoding=utf-8
set fileencoding=utf-8

" Briefly flip to the matching tag whenever one is typed
set showmatch

" To support flashing rather than beeping
"set visualbell
"set vb t_vb=

" Display the line number gutter, coding nice, cut-n-paste unfriendly
set number

" Display the x,y coords in the status bar
set ruler

" Adjust some settings so perl syntax is formatted cleaner
let perl_include_POD = 1
let perl_want_scope_in_variables = 1
let perl_extended_vars = 1
let perl_string_as_statement = 1
" This sets the minimum number of lines to process for syntax highlighting, a bigger number is more cpu intensive
let perl_sync_dist = 1000

syntax sync fromstart

" By default vim doesn't report on all ':' commands, tell it to always report
set report = 0

" r: display [RO] for Read Only files
" I: don't display the welcome message
set shortmess=+rI

" Display current mode and partially typed commands in the status line
set showmode
set showcmd

" When searching, search incrementally, rather than waiting until enter is pressed
set incsearch

" When enabled (I disable it) this will highlight all search matches
set nohlsearch

" Display some hidden characters, this makes me happy
set list
set listchars=tab:▻\ ,trail:◈

" - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
" Section 2: gvim specific
" - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
set guioptions-=rmT
set guifont=Monospace\ 8

" - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
" Section 3: Insert mode Tweaks
" - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
set noexpandtab
set softtabstop=2
set tabstop=8
set shiftwidth=2
set shiftround
set autoindent
set smartindent

" Turn off text wrapping, but enable comment wrapping
set formatoptions-=t
set textwidth=0

" - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
" Section 4: Behavior
" - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
" Disable the mouse, we aren't friends
"set mouse=a

" Add <> to the list of matched characters
set matchpairs+=<:>

" Load and use the matchit vim plugin
if filereadable($VIMRUNTIME . "/macros/matchit.vim")
  source $VIMRUNTIME/macros/matchit.vim
endif

" Disable '=' as a valid character in filenames
set isfname-==

" Default to case insensitive matching, but when caps are found assume sensitive
set ignorecase
set smartcase

" Don't resize all open windows when I split in a new window
set noequalalways

" Configure folding to use markers, and be fully folded on file open
set foldmethod=marker
set foldlevel=0

" - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
" Section 5: Keymappings
" - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

" Tweak how backspace is handled, allow deleting eol, start, and indentations
set backspace=eol,start,indent

" I hate F1 being mapped to help, so now it's an extra escape
map <F1> <ESC>
imap <F1> <ESC>

" During an svn edit, display a split window with the diff enclosed
map <F9> :new<CR>:read !svn diff<CR>:set syntax=diff buftype=nofile<CR>gg
map <F10> :let difffile=expand('%')<CR>:new<CR>:read '!git diff --cached '.difffile<CR>:set syntax=diff buftype=nofile<CR>gg

noremap gf gf`"
noremap <C-^> <C-^>`" 

" - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
" Section 6: Functions
" - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function! IncrementSerial(date,num)
  if (strftime("%Y%m%d") == a:date)
    return a:date . a:num+1
  endif
  
  return strftime("%Y%m%d") . '01'
endfunction

command SOA :%s/\(2[0-9]\{7\}\)\([0-9]\{2\}\)\(\s*;\s*[sS]erial\)/\=IncrementSerial(submatch(1),submatch(2)) . submatch(3)/gc

" - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
" Section 7: Filetype specific behavior
" - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
" Enable filetype detection, with plugins and specialized indenting rules
filetype plugin indent on

" I like my c-style comments with aligned asterisks
set comments-=s1:/*,mb:*,ex:*/
set comments+=s:/*,mb:\ *,ex:\ */
set comments+=fb:*

" Configure smart perl manpages
autocmd FileType perl set keywordprg=perldoc\ -f

" Verify that myprograms compile before saving
autocmd FileType php  map <C-B> :!php -l %<CR>
autocmd FileType perl map <C-B> :!perl -c %<CR>
autocmd FileType ruby map <C-B> :!ruby -c %<CR>

" For files using C style comments, set my comments options
autocmd FileType                c,cpp,javascript,slang            set cindent formatoptions+=ro

" For make files, don't expand my tabs
autocmd FileType                make                              set noexpandtab

" For shell style files, don't let smartindent remove the indents on my comments
autocmd FileType                perl,ruby                         inoremap # X<ctrl-v><backspace>#

" Handle dns zone files
autocmd BufWritePre             /var/named/*.db                   execute ":SOA"
