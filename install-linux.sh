#!/usr/bin/env bash
#
# Created by TszFung Lam on 2019-08-15
# Modify by TszFung Lam on 2019-08-15
# install v0.1.0 Linux 服务器基本安装

# http://www.osdata.com/programming/shell/unixbook.pdf

# 导入库
. ./libs/functions
. ./libs/location

linux_install() {


}

linux_install




# Git 配置
if [ ! -f $HOME/.gitconfig ]; then
  read -r -p "配置 Git 仓库么？[y|N] " ans
  if [[ $ans =~ (yes|y|Y) ]];then
    if [[ "$(uname -s)" == "Darwin" ]];then
      GIT_USERNAME=$(osascript -e "long user name of (system info)")
    else
      GIT_USERNAME=$(whoami)
    fi
    read -r -p "$GIT_USERNAME 是您的 Git 用户名么？若不是，请输入：" ans
    [[ ! -z "$ans" ]] && GIT_USERNAME=$ans
    read -r -p "请输入您的 Email：" GIT_EMAIL
    logs "请确认您输入的信息：$GIT_USERNAME \t $GIT_EMAIL"
    sed -i "s/GIT_USERNAME/$GIT_USERNAME/" ${CONFIG_HOME}/git/.gitconfig > /dev/null 2>&1 | true
    if [[ ${PIPESTATUS[0]} != 0 ]]; then
      logs "MacOS 自带的 sed 而不是 gnu-sed"
      sed -i "" 's/GIT_USERNAME/'"$GIT_USERNAME"'/g' ${CONFIG_HOME}/git/.gitconfig;
      sed -i '' 's/GIT_EMAIL/'$GIT_EMAIL'/' ${CONFIG_HOME}/git/.gitconfig;
    else
      logs "gnu-sed"
      sed -i 's/GIT_USERNAME/'"$GIT_USERNAME"'/' ${CONFIG_HOME}/git/.gitconfig;
      sed -i 's/GIT_EMAIL/'$GIT_EMAIL'/' ${CONFIG_HOME}/git/.gitconfig;
    fi
    logs "Git 配置完毕"
    lnif ${CONFIG_HOME}/git/.gitconfig $HOME/.gitconfig
    logs "忽略文件配置完毕"
    lnif ${CONFIG_HOME}/git/.gitignore $HOME/.gitignore
    lnif ${CONFIG_HOME}/git/.gitignore $HOME/.agignore
    lnif ${CONFIG_HOME}/git/.gitignore $HOME/.dockerignore
  fi
fi