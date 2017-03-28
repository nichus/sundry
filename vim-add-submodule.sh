#!/bin/bash

if [ "$1x" -eq "x" ]; then
  echo "specify a git repo on the command line"
  exit 1
fi
repository=$(basename $(dirname $1))
project=${$(basename $1)%.git}
smpath="vim/pack/nichus/start/${repository}-${project}"
git submodule add $1 $smpath
git add .gitmodules $smpath
