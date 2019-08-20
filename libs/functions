#!/usr/bin/env bash
#
############################################################################
#                       _            _____         _                       #
#                      | | ___  _   |_   _|__  ___| |__                    #
#                   _  | |/ _ \| | | || |/ _ \/ __| '_ \                   #
#                  | |_| | (_) | |_| || |  __/ (__| | | |                  #
#                   \___/ \___/ \__, ||_|\___|\___|_| |_|                  #
#                               |___/                                      #
#                                                                          #
#                        http://itszfung.joytech.fun                       #
#                                                                          #
#                    2017~2018 JOYTech Creation Technology                 #
#                        Co., Ltd. All rights reserved                     #
############################################################################
#
#  Created by TszFung Lam on 2018-05-25
#  Modify by TszFung Lam on 2018-07-13
#  functions v0.1.0 Basic Functions

# 重置
RESET='\033[0m'

# 前景色
BOLD='\033[1m'
BLACK='\033[38;5;0m'
RED='\033[38;5;1m'
GREEN='\033[38;5;2m'
YELLOW='\033[38;5;3m'
BLUE='\033[38;5;4m'
MAGENTA='\033[38;5;5m'
CYAN='\033[38;5;6m'
WHITE='\033[38;5;7m'

# 背景色
ON_BLACK='\033[48;5;0m'
ON_RED='\033[48;5;1m'
ON_GREEN='\033[48;5;2m'
ON_YELLOW='\033[48;5;3m'

# 输出
msg() {
  echo -e "${DEBUG:+${ON_YELLOW}${MAGENTA}$(basename $0) ${BLUE}$(date "+%T.%2N ")}${RESET} ${@} ${RESET}\n" >&2
}
logs() {
  msg "${ON_GREEN}${WHITE} 输出 ⇒ ${RESET} ${@}"
}
warn() {
  msg "${YELLOW} 警告 ⇒ ${RESET} ${@}"
}
error() {
  msg "${ON_RED}${YELLOW} 异常 ⇒ ${RESET} ${@}"
}
success() {
  msg "${GREEN} 成功 ⇒ ${RESET} ${@}"
}

# 继续运行
continue_run() {
  [ -n "${FORCE}" ] && return || true
  read -r -p "$1 确认继续 ？ [Y|n] " response
  case $response in
      n*|N*) exit 1;;
  esac
}

# 同步仓库 sync_repo repo_path repo_uri repo_branch
sync_repo() {
  local repo_path="$1"
  local repo_uri="$2"
  local repo_branch="${3:-master}"
  if [ ! -e "$repo_path" ]; then
    mkdir -p "$repo_path"
    git clone -b "$repo_branch" "$repo_uri" "$repo_path"
  else
    cd "$repo_path" && git pull origin "$repo_branch"
  fi
  success "克隆完成"
}

# 更新仓库
update_repo() {
  git pull origin master;
  success "更新完毕"
}

# 链接 lnif file_path link_path
lnif() {
  if [ -e "$1" ]; then
    ln -sf "$1" "$2"
    [ $? == 0 ] && logs "链接文件成功"
  fi
}

# 删除链接 lnif file_path
unln() {
  if [ -e "$1" ]; then
    unlink $1
    [ $? == 0 ] && logs "删除链接文件成功"
  fi
}

# 删除文件夹里的所有链接文件
unln_folder() {
  local folder=$1
  for file in $(ls -A $folder)
  do
    if [ -L "$folder/$file" ]; then
      unln "$folder/$file"
    fi
  done
}

# 链接所有文件到 Home 目录
ln_files_2_home() {
  local folder=$1
  for file in $(ls $folder)
  do
    if [ -d "$folder/$file" ]; then
      lnfolder "$folder/$file"
    else
      lnif "$folder/$file" $HOME
    fi
  done
}

# # brew 安装
brew_install() {
  brew list $1 > /dev/null 2>&1 | true
  if [[ ${PIPESTATUS[0]} != 0 ]]; then
    logs "使用 brew 安装 $@"
    brew install $@
    if [[ $? != 0 ]]; then
      error "安装 $@ 失败..." && exit -1
    fi
  fi
  # Remove outdated versions from the cellar
  brew cleanup
  logs "安装结束"
}

# brew cask install "${apps[@]}"
brew_cask_install() {
  brew cask list $1 > /dev/null 2>&1 | true
  if [[ ${PIPESTATUS[0]} != 0 ]]; then
    logs "使用 brew cask 安装 $1"
    brew cask install $1
    if [[ $? != 0 ]]; then
      error "安装 $@ 失败..."
      exit -1
    fi
  fi
  logs "安装结束"
}

gem_install() {
  if [[ $(gem list --local | grep $1 | head -1 | cut -d' ' -f1) != $1 ]];then
    logs "使用 gem 安装 $1"
    gem install $1
  fi
  logs "安装结束"
}

apm_install() {
  apm list --installed --bare | grep $1@ > /dev/null
  if [[ $? != 0 ]]; then
      apm install $1
  fi
  logs "安装结束"
}

# Npm 安装
npm_install() {
  tip "使用 npm 安装 $@"
  npm list -g --depth 0 | grep $1@ > /dev/null
  if [[ $? != 0 ]]; then
    npm install -g $@ --registry=https://registry.npm.taobao.org
  fi
  success "安装 $@ 成功"
}

pip_install() {
  pip -v > /dev/null
  if [[ $? == 0 ]]; then
    logs "pip 下载：$1"
    pip install $@
  fi
  logs "安装结束"
}
