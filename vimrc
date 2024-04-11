" Initialize vim-plug <https://github.com/junegunn/vim-plug>

call plug#begin()
" General usage plugins
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git'
Plug 'tpope/vim-sensible'
Plug 'rust-lang/rust.vim'
Plug 'pearofducks/ansible-vim'
Plug 'airblade/vim-gitgutter'
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'pangloss/vim-javascript'
Plug 'tpope/vim-surround'
Plug 'scrooloose/syntastic'
Plug 'hashivim/vim-terraform'
Plug 'tangledhelix/vim-kickstart'
Plug 'robbles/logstash.vim'
Plug 'yorokobi/vim-splunk'

" Colorschemes
"Plug 'Marfisc/vorange'
Plug 'xero/blaquemagick.vim'
"Plug 'jnurmine/Zenburn'
"Plug 'sjl/badwolf'
"Plug 'sheerun/vim-wombat-scheme'
"Plug 'dsolstad/vim-wombat256i'
"Plug 'altercation/vim-colors-solarized'
"Plug 'YorickPeterse/happy_hacking.vim'
"Plug 'owickstrom/vim-colors-paramount'
"Plug 'pbrisbin/vim-colors-off'
"Plug 'kristijanhusak/vim-hybrid-material'
"Plug 'ltlollo/diokai'
call plug#end()

set softtabstop=4
set shiftwidth=4
set tabstop=4
set number
"set smartindent
"set expandtab
set cindent
set list
set listchars=tab:»\ ,trail:·
"set listchars=tab:├\─,trail:▯

" Attempt to disable vim/mouse interactions
set mouse=

set foldmethod=marker

" Align the asterisks of c-style comments
set comments-=s1:/*,mb:*,ex:*/
set comments+=s:/*,mb:\ *,ex:\ */
set comments+=fb:*

" If uncommented highlight the focused line
"set cursorline

"set background=dark
"let g:badwolf_darkgutter=1
"colorscheme happy_hacking
colorscheme blaquemagick

let g:airline_powerline_fonts = 1
"let g:airline#extensions#whitespace#mixed_indent_algo = 1

let g:ansible_attribute_highlight = "ab"

let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_logstash_checkers = ['eslint']
let g:syntastic_javascript_checkers = ['eslint']

if &diff
else
  silent sba
endif
