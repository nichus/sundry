execute pathogen#infect()

" Pathogen modules used:
" * git://github.com/tpope/vim-fugitive.git
" * git://github.com/tpope/vim-git.git
" * https://github.com/tpope/vim-sensible.git
" * https://github.com/rust-lang/rust.vim.git
" * https://github.com/pearofducks/ansible-vim.git
" * https://github.com/airblade/vim-gitgutter
" * https://github.com/bling/vim-airline
" * https://github.com/vim-airline/vim-airline-themes
" * https://github.com/pangloss/vim-javascript
" * https://github.com/tpope/vim-surround
" * https://github.com/scrooloose/syntastic
" * https://github.com/hashivim/vim-terraform.git
" * https://github.com/tangledhelix/vim-kickstart.git
"
" Pathogen colorschemes used: (vimcolors.com for more)
" * https://github.com/Marfisc/vorange.git
" * https://github.com/jnurmine/Zenburn.git
" * https://github.com/sjl/badwolf.git
" * https://github.com/sheerun/vim-wombat-scheme.git
" * git://github.com/altercation/vim-colors-solarized.git
" * https://github.com/YorickPeterse/happy_hacking.vim.git
" * https://github.com/owickstrom/vim-colors-paramount.git
" * https://github.com/pbrisbin/vim-colors-off.git
" * https://github.com/kristijanhusak/vim-hybrid-material.git

syntax on
filetype plugin indent on

set softtabstop=2
set shiftwidth=2
set number
"set smartindent
set expandtab
set cindent
set list
set listchars=tab:▻\ ,trail:◈

set foldmethod=marker

" Align the asterisks of c-style comments
set comments-=s1:/*,mb:*,ex:*/
set comments+=s:/*,mb:\ *,ex:\ */
set comments+=fb:*

" Highlight the focused line
set cursorline

"set background=dark
"let g:badwolf_darkgutter=1
colorscheme vorange

let g:airline_powerline_fonts = 1
"let g:airline#extensions#whitespace#mixed_indent_algo = 1

let g:ansible_attribute_highlight = "ab"

if &diff
else
  silent sba
endif
