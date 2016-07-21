execute pathogen#infect()

" Pathogen modules used:
" * git://github.com/altercation/vim-colors-solarized.git
" * https://github.com/sheerun/vim-wombat-scheme.git
" * git://github.com/tpope/vim-fugitive.git
" * git://github.com/tpope/vim-git.git
" * https://github.com/tpope/vim-sensible.git
" * https://github.com/rust-lang/rust.vim.git
" * https://github.com/chase/vim-ansible-yaml.git
" * https://github.com/airblade/vim-gitgutter
" * https://github.com/bling/vim-airline
" * https://github.com/vim-airline/vim-airline-themes
" * https://github.com/pangloss/vim-javascript
" * https://github.com/tpope/vim-surround
" * https://github.com/scrooloose/syntastic
"
" Standalone colorschemes used:
" * https://github.com/jnurmine/Zenburn.git
" * https://github.com/sjl/badwolf.git

syntax on
filetype plugin indent on

set softtabstop=2
set shiftwidth=2
set number
"set smartindent
set cindent
set list
set listchars=tab:▻\ ,trail:◈

set foldmethod=marker

" Align the asterisks of c-style comments
set comments-=s1:/*,mb:*,ex:*/
set comments+=s:/*,mb:\ *,ex:\ */
set comments+=fb:*

"set background=dark
"let g:badwolf_darkgutter=1
colorscheme zenburn

let g:airline_powerline_fonts = 1
let g:airline#extensions#whitespace#mixed_indent_algo = 1

let g:ansible_attribute_highlight = "ab"
