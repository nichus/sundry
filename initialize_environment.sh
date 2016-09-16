#!/bin/bash

[ -e $HOME/.vimrc ] && rm $HOME/.vimrc
ln -s $(pwd)/vimrc $HOME/.vimrc

mkdir -p $HOME/.vim/autoload $HOME/.vim/bundle
curl -LSso $HOME/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

MODULES="git://github.com/altercation/vim-colors-solarized.git
	https://github.com/sheerun/vim-wombat-scheme.git
	git://github.com/tpope/vim-fugitive.git
	git://github.com/tpope/vim-git.git
	https://github.com/tpope/vim-sensible.git
	https://github.com/rust-lang/rust.vim.git
	https://github.com/pearofducks/ansible-vim.git
	https://github.com/airblade/vim-gitgutter
	https://github.com/bling/vim-airline
	https://github.com/vim-airline/vim-airline-themes
	https://github.com/pangloss/vim-javascript
	https://github.com/tpope/vim-surround
	https://github.com/scrooloose/syntastic
	https://github.com/dsolstad/vim-wombat256i.git
	https://github.com/jnurmine/Zenburn.git"

cd $HOME/.vim/bundle
for module in $MODULES; do
	git clone --depth=1 $module
done

mkdir -p $HOME/.zsh
cd $HOME/.zsh

git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git
git clone https://github.com/nichus/zsh-customizations custom
