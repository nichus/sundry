# Initial stab, cleanup to follow

set -o notify
set -o emacs
umask 002

# Aliases
if type less >/dev/null 2>&1; then
  alias more=less
  export PAGER=less
fi
alias ssh='ssh -CY'
if type vim >/dev/null 2>&1; then
  alias vi=vim
fi
alias which='type -path'
alias fp='find . ! -perm -220 -type f -exec chmod -v ug+w {} \;'
alias enscript='/usr/bin/enscript -U2 -E -G -j --tabsize=2 --ps-level=2 --font=Courier6/7'
alias enscript1='/usr/bin/enscript -1 -G -j --ps-level=2'
alias indent='indent -kr -ce -cdw -npcs -prs -di16 -L132 -i2 -bli0 -nut -bc'

export LESS='-F -M -r'
export EDITOR=vim
export HISTSIZE=1000
export HISTFILESIZE=1000
export HISTCONTROL='ignoreboth'
export LANG=en_US.utf-8
export CVSUMASK=002
export GREP_OPTIONS='--colour=auto'
export LS_OPTIONS='-F --color=auto'
export RI='-Tf ansi'

if [ "$TERM" = "xterm" ]; then
  TERM="xterm=256color"
fi

OTHEME=qi3ber2

if [ -d $HOME/.bash ]; then
  OS=`uname -s`
  OSDIR=${HOME}/.bash/os
  if [ -d $OSDIR ]; then
    if [ -e $OSDIR/$OS.sh ]; then
      source $OSDIR/$OS.sh
    fi
  fi
  unset OSDIR

  DOMAINDIR=${HOME}/.bash/domains
  if [ -d $DOMAINDIR ]; then
    FILE=`$(type -path dnsdomainname || type -path domainname)`.sh
    if [ -e $DOMAINDIR/$FILE ]; then
      source $DOMAINDIR/$FILE
    fi
    unset FILE
  fi
  unset DOMAINDIR
  
  FILE=`uname -n | cut -d. -f1`.sh
  HOSTDIR=${HOME}/.bash/hosts
  if [ -d $HOSTDIR ]; then
    if [ -e $HOSTDIR/$FILE ]; then
      source $HOSTDIR/$FILE
    fi
  fi
  unset HOSTDIR
  unset FILE
  
  for FILE in $HOME/.bash/conf.d/*.sh; do
    source $FILE
  done
  unset FILE
fi

if [ $UID = '0' ]; then
  set_palette yellow
else
  set_palette solarized
fi

$OTHEME
