function qi3ber2() {
  export PROMPT_COMMAND=prompt_command
  if [ -n "$1" ]; then
    set_palette $1
  fi
  
  RETCODE="\$( printf "%3s" \$CODE )"
  
  UL=""
  UR=""
  MID=""
  ML=""
  MR=""
  LL=""
  LR=""
  
  LINEONE="${Theme[0]}${UL}${MID}${ML} ${Theme[3]}\u${Theme[1]}@${Theme[4]}\h${ResetColours}:${Theme[7]}$TTY}${Theme[0]} ${MR}${UR}"
  LINETWO="${Theme[0]}${MR}${MID}${ML} ${Theme[6]}$$${ResetColours}:${Theme[7]}${LOADAVG}${Theme[0]} @ ${Theme[8]}${DATE}${Theme[0]} ${MR}${ML} ${Theme[5]}\w${Theme[0]} ${MR}${UR}"
  LINETHR="${Theme[0]}${LL}${MID}${ML} ${Theme[2]}\! ${Theme[9]}${RETCODE}${Theme[0]} ${MR}${UR}"
  
  PS1="${XTERM}$LINEONE \n$LINETWO \n$LINETHR \$${ResetColours} "
  export PS1
  
  PS2="${Theme[0]}-${Theme[1]}*${Theme[2]}->${Theme[8]}\$${ResetColours} "
  export PS2
  
  export OPROMPT=qi3ber2
  
  unset LINEONE
  unset LINETWO
  unset LINETHR
}
