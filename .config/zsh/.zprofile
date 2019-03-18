##############################################################################
#Import the shell-agnostic (Bash or Zsh) environment config
# source ${CONFIG_HOME}/conf/shell/.profile
##############################################################################

# History Configuration
HISTFILE=~/.histfile
HISTSIZE=5000
SAVEHIST=5000
HISTDUP=erase

setopt    appendhistory
setopt    sharehistory
setopt    incappendhistory
setopt  autocd extendedglob nomatch notify
unsetopt beep
unsetopt correct

# zsh 搜索程序的目录列表
path=(
  /usr/local/{bin,sbin}
  $path
)

# 当 TMPDIR 变量为空或者目录不存在时，设置临时文件夹
if [[ -z "${TMPDIR}" ]]; then
  export TMPDIR="/tmp/zsh-${UID}"
  if [[ ! -d "${TMPDIR}" ]]; then
    mkdir -m 700 "${TMPDIR}"
  fi
fi
