#!/bin/bash

action=$1
shift

[ "$action" = "usage" ] && {
  echo "  done:"
  echo "    done \"THING THAT WAS ALREADY COMPLETED\""
  echo "      add an item and mark it as done in one step"
  echo ""
  exit
}

if "$TODO_SH" command add "$@"; then
  line=`wc -l "$TODO_FILE" | cut -d' ' -f1`
  "$TODO_SH" command do "$line"
fi
