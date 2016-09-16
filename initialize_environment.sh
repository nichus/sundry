#!/bin/bash

function update_or_clone {
  dir=`basename $1 | awk -F. '{print $1}'`
  directory=${2:-$dir}
  if [ -d $directory ]; then
    cd $directory
    git pull
    cd ..
  else
    git clone --depth=1 $1 $directory
  fi
}

[ -e $HOME/.vimrc ] && rm $HOME/.vimrc
ln -s $(pwd)/vimrc $HOME/.vimrc

mkdir -p $HOME/.vim/autoload $HOME/.vim/bundle
curl -LSso $HOME/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

MODULES="git://github.com/tpope/vim-fugitive.git
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
	https://github.com/Marfisc/vorange.git
	https://github.com/sjl/badwolf.git
	https://github.com/YorickPeterse/happy_hacking.vim.git
	https://github.com/owickstrom/vim-colors-paramount.git
	https://github.com/pbrisbin/vim-colors-off.git
	https://github.com/kristijanhusak/vim-hybrid-material.git
	https://github.com/dsolstad/vim-wombat256i.git
	https://github.com/jnurmine/Zenburn.git
	git://github.com/altercation/vim-colors-solarized.git
	https://github.com/sheerun/vim-wombat-scheme.git"

cd $HOME/.vim/bundle
for module in $MODULES; do
  update_or_clone $module
done

mkdir -p $HOME/.zsh
cd $HOME/.zsh

update_or_clone https://github.com/robbyrussell/oh-my-zsh.git
update_or_clone https://github.com/nichus/zsh-customizations custom
