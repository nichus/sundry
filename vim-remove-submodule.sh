#!/bin/bash

if [ "$1x" -eq "x" ]; then
  echo "specify a module directory to remove"
  exit 1
fi
if [ ! -d vim/pack/nichus/start/$1 ]; then
  echo "submodule $1 is not installed"
  exit 1
fi

git submodule deinit vim/pack/nichus/start/$1
git rm vim/pack/nichus/start/$1
rm -rf .git/modules/vim/pack/nichus/start/$1
git commit
