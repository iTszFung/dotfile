# 本环境参考了 https://github.com/smaximov/zsh-config
# 读取顺序
# /etc/zshenv
# ZDOTDIR/.zshenv（ZDOTDIR 未设置时默认为 $HOME）
# 如果是 login shell，读取 /etc/zprofile, $ZDOTDIR/.zprofile
# 如果是 interactive shell，读取 /etc/zshrc, $ZDOTDIR/.zshrc
# 如果是 login shell，读取 /etc/zlogin, $ZDOTDIR/.zlogin

# SCRIPT_HOME=$(cd $(dirname $BASH_SOURCE) && pwd)
# export SCRIPT_HOME=/Users/itszfung/TSpace/dotfile
export CONFIG_HOME=${DOTFILE_HOME}/.config
export CACHE_HOME=${DOTFILE_HOME}/.cache

# 全局变量
export TERM="xterm-256color"
export ZSH=${CONFIG_HOME}/zsh/oh-my-zsh
export ZDOTDIR=${CONFIG_HOME}/zsh
export ZSH_CACHE_DIR=${CACHE_HOME}/zsh
export HISTFILE=${ZSH_CACHE_DIR}/.zhistory
export dirstack_file=${CACHE_HOME}/zsh/.zdirs

[[ -f $ZDOTDIR/custom/.zshenv ]] && source $ZDOTDIR/custom/.zshenv

# 本地与远程编辑器
test -n "$(command -v emacs)" && EDITOR=emacs || EDITOR=vim
export VISUAL=$EDITOR

# Highlight section titles in manual pages.
export LESS_TERMCAP_md="${yellow}";

if test -n "$(command -v less)" ; then
    export PAGER="less -FirSwX"
    export MANPAGER="less -FiRswX"
else
    export PAGER=more
    export MANPAGER="$PAGER"
fi

export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

# 配置 vimrc 文件所在地
# export VIMINIT='let $MYVIMRC="$CONFIG_HOME/vim/.vimrc" | source $MYVIMRC'

# 确保非 login 环境已配置
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN || -z "${TMPDIR}" ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi


# 避免安装 Homebrew 时出现 gpg 问题
export GPG_TTY=$(tty);
# Enable persistent REPL history for `node`.
export NODE_REPL_HISTORY=${CACHE_HOME}/.node_history;
# Allow 32³ entries; the default is 1000.
export NODE_REPL_HISTORY_SIZE='32768';
# Use sloppy mode by default, matching web browsers.
export NODE_REPL_MODE='sloppy';
# Make Python use UTF-8 encoding for output to stdin, stdout, and stderr.
export PYTHONIOENCODING='UTF-8';