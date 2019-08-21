#!/usr/bin/env bash
#
# Created by TszFung Lam on 2019-08-15
# Modify by TszFung Lam on 2019-08-15
# install v0.1.0 安装并运行所有配置

# http://www.osdata.com/programming/shell/unixbook.pdf

# TODO: zsh 的环境文件、配置文件、脚本文件在 Linux 上有问题
# 导入库
. ./libs/functions
. ./libs/location

# 基础变量
DEBUG=
VERSION=0.2.0
COMMAND=$(basename "$0")  # install.sh
SCRIPT_HOME=$(cd $(dirname $BASH_SOURCE) && pwd) # /Users/itszfung/TSpace/dotfile
CACHE_HOME=${SCRIPT_HOME}/.cache
CONFIG_HOME=${SCRIPT_HOME}/.config

LOGFILE=dot.log
>$LOGFILE
exec >  >(tee -ia $LOGFILE)
exec 2> >(tee -ia $LOGFILE >&2)

[ ! -z "$DEBUG" ] && set -x;

# 免密配置
if ! sudo grep -q "%wheel		ALL=(ALL) NOPASSWD: ALL #itszfung" "/etc/sudoers"; then
  read -r -p "sudo 免密设置 (需要输入管理员密码) [y|N] " ans
  if [[ $ans =~ (yes|y|Y) ]];then
    sudo -v
    # 保持管理员直到脚本运行完毕
    while true; do
      sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    logs "备份 sudoers 配置文件"
    sudo cp /etc/sudoers /etc/sudoers.bak
    echo -e "\n%wheel		ALL=(ALL) NOPASSWD: ALL #itszfung" | sudo tee -a /etc/sudoers > /dev/null
    if [ "$(uname -s)" != "Darwin" ];then
      if [ -z "$(cat /etc/group |grep wheel)" ];then
        sudo groupadd wheel
      fi
      sudo usermod -aG wheel $(whoami)
    else
      sudo dscl . append /Groups/wheel GroupMembership $(whoami)
    fi
  fi
  logs "sudo 免密配置完成"
fi

# 广告拦截
if ! sudo grep -q "# itszfung" "/etc/hosts"; then
  read -r -p "是否需要进行广告拦截？（服务端无必要）[y|N] " ans
  if [[ $ans =~ (yes|y|Y) ]];then
    sudo mv /etc/hosts /etc/hosts.bak
    sudo cp ${CONFIG_HOME}/adblock/hosts /etc/hosts
    success "/etc/hosts 文件已更新! 配置拦截成功，旧文件备份在 /etc/hosts.backup"
  fi
fi

# 字体安装
read -r -p "是否需要安装特殊字体？（非客户端不建议安装）[y|N] " ans
if [[ $ans =~ (yes|y|Y) ]];then
  if [[ `uname` == 'Darwin' ]]; then
    # MacOS
    font_dir="$HOME/Library/Fonts"
    # nerdfont
    git clone https://github.com/ryanoasis/nerd-fonts ~/nerd-fonts
    pushd ~/nerd-fonts && ./install.sh && popd && rm -rf ~/nerd-fonts
  else
    # Linux
    font_dir="$HOME/.local/share/fonts"
    mkdir -p $font_dir
  fi

  find "${CONFIG_HOME}/fonts" -name "*.[o,t]tf" -type f | while read -r file; do
    cp -v "$file" "$font_dir"
  done
  # 字体缓存
  if command -v fc-cache @>/dev/null; then
      logs "正在重置字体缓存..."
      fc-cache -f $font_dir
  fi
fi

# 依赖安装
if [ "$(uname -s)" != "Darwin" ];then
    read -r -p "是否配置阿里云源（非客户端不建议安装）[y|N] " ans
    if [[ $ans =~ (yes|y|Y) ]];then
      if [ "$(cat /etc/issue | cut -d ' ' -f 1)" == "Ubuntu" ];then
        version_name=$(cat /etc/os-release |grep VERSION_ID |cut -d'"' -f 2)
        sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
        sudo cp -r ${CONFIG_HOME}/apt/sources.list.$version_name /etc/apt/sources.list
      fi
    fi
  # source "${CONFIG_HOME}/apt-get/Package"
  #   linux_install "$essential_package"
  #   read -r -p "是否需要安装开发者工具？[y|N]" response
  #   if [[ $response =~ ^(y|yes|Y|YES) ]];then
  #     linux_install "$develop_package $extra_package"
  #   fi
  sudo apt-get update && sudo apt upgrade -y && sudo apt-get dist-upgrade -f
  sudo apt-get install -y git git-flow shellcheck gnupg tree htop bash-completion screen zsh curl wget vim
  # 安装 Docker
  sudo apt-get remove docker docker-engine docker.io containerd runc
  sudo apt-get purge docker-ce
  sudo rm -rf /var/lib/docker
  # 安装 docker
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker $USER
  # 安装 docker-compose
  sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo apt-get autoremove
  sudo apt-get autoclean
else
  read -r -p "安装依赖工具、App [y|N]" ans
  if [[ $ans =~ ^(y|yes|Y|YES) ]];then
    logs "正在安装软件，会很长时间..."
    if ! command -v xcodebuild @>/dev/null; then  # 安装命令行工具
        logs "安装 Xcode Command Line Tool"
        sudo xcode-select --install
    fi
    if [ ! -f "/Applications/Xcode.app/Contents/Resources/English.lproj/License.rtf" ];then  # 同意 协议
      sudo xcodebuild -license
    fi
    # if [ "$(sudo spctl --status)" == "assessments enabled" ];then
    #   read -r -p "是否允许安装任何来源 App？[y|N] " ans # 允许安装任何来源 App
    #   if [[ $response =~ (yes|y|Y) ]];then
    #     sudo spctl --master-disable
    #   fi
    # fi
    # 安装 pip
    if ! command -v pip @>/dev/null; then  # 安装命令行工具
      logs "安装 pip"
      sudo easy_install pip
      success "安装 pip 成功，检查 rvm"
    fi
    # 安装 rvm
    if [ ! -d "$HOME/.rvm" ]; then
      curl -sSL ${RVM_INSTALL_URL} | bash -s stable --ignore-dotfiles --with-default-gems='bundler rake git_remote_branch'
      echo "ruby_url=$RUBY_URL" > $HOME/.rvm/user/db
      [ -d "/Library/Ruby/Gems/2.3.0" ] && sudo chown -R $(whoami) /Library/Ruby/Gems/2.3.0
      success "安装 rvm 成功，检查 brew"
    fi
    # 安装 homebrew
    if ! command -v brew @>/dev/null; then
      ruby -e "$(curl -fsSL ${BREW_INSTALL_URL})"
      [ $? == 0 ] && success "安装 brew 成功，正在更新到最新版本.." || ( error "安装 brew 失败，退出" && exit 1 )
      /usr/local/bin/brew update
      brew analytics off
    fi
    BREW_FILE="${CONFIG_HOME}/brew/Brewfile"
    if [ -f "${BREW_FILE}" ];then
      brew bundle --file=${BREW_FILE} -v
    else
      error "文件${BREW_FILE}不存在！安装结束"
      exit -1
    fi
  fi
fi

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

# Zsh 配置
omzsh="${CONFIG_HOME}/zsh/oh-my-zsh"
if [ ! -d "${omzsh}" ];then
  read -r -p "配置 Zsh 么？[y|N] " ans
  if [[ $ans =~ (yes|y|Y) ]];then
    export ZSH=${omzsh}
    sync_repo ${omzsh} ${OMZSH_REPO_URL}
    sync_repo ${omzsh}/custom/themes/powerlevel9k ${POWERLEVEL9K_REPO_URL}
    if [ ! -L "$HOME/.zshenv" ];then
      echo "export DOTFILE_HOME=$SCRIPT_HOME" > ${CONFIG_HOME}/zsh/.zshenv
      lnif ${CONFIG_HOME}/zsh/.zshenv $HOME/.zshenv
    fi
  fi
fi

# 更改 Shell
read -r -p "更改为 Zsh 么？[y|N]" ans
if [ "$(uname -s)" != "Darwin" ];then
  change="zsh"
  current=$(expr "$SHELL" : '.*/\(.*\)')
  if [ "${current}" != "${change}" ]; then
  target=$(grep /${change}$ /etc/shells | tail -1)
  chsh_bin=$(which chsh) 2>&1 > /dev/null
    if [[ $? == 0 ]]; then
      sudo chsh -s ${target} $(whoami)
    fi
  logs "Shell 已修改为 ${change}...需要退出后重新登录"
  fi
else
  echo $(which zsh) >> /etc/shells
  sudo chsh -s $(which zsh) $(whoami)
  sudo dscl . -create /Users/$USER UserShell $(which zsh)
fi

# Vim
read -r -p "配置 vim 编辑器么？[y|N]" ans
if [[ $ans =~ (yes|y|Y) ]];then
  logs "下载 spf13-vim 配置..."
  sync_repo "$HOME/.vim.d" "$SPF13_REPO_URL" "3.0"
  sync_repo "$HOME/.vim/bundle/vundle" "$VUNDLE_REPO_URL"
  lnif "$HOME/.vim.d/.vimrc"         "$HOME/.vimrc"
  lnif "$HOME/.vim.d/.vimrc.bundles" "$HOME/.vimrc.bundles"
  lnif "$HOME/.vim.d/.vimrc.before"  "$HOME/.vimrc.before"
  lnif "$HOME/.vim.d/.vim"           "$HOME/.vim"
  lnif "$HOME/.vim.d/.vim"           "$CONFIG_HOME/nvim"
  lnif "$HOME/.vim.d/.vimrc"         "$CONFIG_HOME/nvim/init.vim"
  touch  "$HOME/.vimrc.local"
  vim  -u "$HOME/.vim.d/.vimrc.bundles.default" \
      "+set nomore" \
      "+BundleInstall!" \
      "+BundleClean" \
      "+qall"
fi

# emacs
if command -v emacs @>/dev/null && [ ! -d "$HOME/.emacs.d" ]; then
  read -r -p "配置 Space emacs 编辑器么？[y|N]" ans
  if [[ $ans =~ (yes|y|Y) ]];then
    logs "下载 spacemacs 配置..."
    sync_repo $HOME/.emacs.d ${SPACEMACS_REPO_URL}
  fi
fi

# 系统配置
if [ "$(uname -s)" == "Darwin" ];then
  read -r -p "基础设置？[y|N]" ans
  if [[ $ans =~ (yes|y|Y) ]];then
    # 检查所有完成之后，直接查设置。不再添加其他配置
    source $CONFIG_HOME/setup/osx.sh
  fi
  # 默认情况下，Terminal中使用 soldark 主题
  read -r -p "配置 terminal？[y|N] " ans
  if [[ $ans =~ (yes|y|Y) ]];then
    TERM_PROFILE='Solarized Dark xterm-256color'
    CURRENT_PROFILE="$(defaults read com.apple.terminal 'Default Window Settings')"
    if [ "${CURRENT_PROFILE}" != "${TERM_PROFILE}" ]; then
      open "$CONFIG_HOME/terminal/${TERM_PROFILE}.terminal"
      sleep 1; # Wait a bit to make sure the theme is loaded
      defaults write com.apple.terminal 'Default Window Settings' -string "${TERM_PROFILE}"
      defaults write com.apple.terminal 'Startup Window Settings' -string "${TERM_PROFILE}"
    fi
  fi

  # iterm2 配置
  if [ -d "$HOME/Library/Application Support/iTerm2" ]; then
    read -r -p "配置 iterm2？[y|N] " ans
    if [[ $ans =~ (yes|y|Y) ]];then
      curl -L $ITERM_SHELL_INTERGRATION_URL | bash
      wget -q $ITERM_COLOR_SCHEMES_URL -o - | tar -xzv -C ${SCRIPT_HOME}/iterm/schemes \
      --strip-components=1 --exclude='{.gitignore}'
      # logs "安装 iterm2  配置【注意，主题颜色在 $SCRIPT_HOME/iterm/schemes 目录下，请手动导入】"
      local folder=${SCRIPT_HOME}/iterm/schemes
      for scheme in $(ls -A $folder);
      do
        if [ -L "$folder/$scheme" ]; then
          open "$folder/$scheme"
        fi
      done
    fi
  fi

  # 配置 Xcode
  if [ ! -e "$HOME/Library/Developer/Xcode/UserData/FontAndColorThemes" ]; then
    read -r -p "配置 Xcode [y|N] " ans
    if [[ $ans =~ (yes|y|Y) ]];then
      mkdir -p $HOME/Library/Developer/Xcode/UserData/FontAndColorThemes
      pushd $HOME/Library/Developer/Xcode/UserData/FontAndColorThemes
      git clone $BASE_16_FOR_XCODE_URL Base16
      ln -s -- Base16/* ./
      popd
    fi
  fi

  # 配置 vscode
  if [ -d "$HOME/Library/Application Support/Code" ]; then
    read -r -p "配置 vscode？ [y|N] " ans
    if [[ $ans =~ (yes|y|Y) ]];then
      cp -f "${CONFIG_HOME}/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
    fi
    # Can be updated with:
    # code --list-extensions
    # CODE_EXTENSIONS=(
    #   alexdima.copy-relative-path
    #   alexkrechik.cucumberautocomplete
    #   EditorConfig.EditorConfig
    #   formulahendry.auto-close-tag
    #   mjmcloug.vscode-elixir
    #   ms-python.python
    #   octref.vetur
    #   stevejpurves.cucumber
    #   streetsidesoftware.code-spell-checker
    #   streetsidesoftware.code-spell-checker-russian
    #   teabyii.ayu
    #   WakaTime.vscode-wakatime
    # )

    # for ext in "$CODE_EXNTENSIONS"; do
    #   code --install-extension "$ext"
    # done
  fi

  # Node 配置
  if command -v npm @>/dev/null; then  # 安装命令行工具
    read -r -p "配置 Node 么？[y|N]" ans
    if [[ $ans =~ (yes|y|Y) ]];then
      GLOBAL_NPMRC="/usr/local/etc/npmrc"
      echo "userconfig=${CONFIG_HOME}/npm/.npmrc" > ${GLOBAL_NPMRC}
      echo "globalignorefile=${CONFIG_HOME}/npm/.npmignore" > ${GLOBAL_NPMRC}
      echo "cache=${CACHE_HOME}/npm" > ${GLOBAL_NPMRC}
      # 配置 JS
      ln_files_2_home $CONFIG_HOME/js
      # npm install cnpm vue vue-cli electron vue-electron
      pushd $CONFIG_HOME/yarn/global && yarn && popd

      # export NVM_DIR=~/.nvm
      # source $(brew --prefix nvm)/nvm.sh
    fi
  fi

  read -r -p "配置 便捷脚本？[y|N]" ans
  if [[ $ans =~ (yes|y|Y) ]];then
    lnif $CONFIG_HOME/bin /usr/local/share/scripts
    echo "export PATH=$PATH:/usr/local/share/scripts" > $CONFIG_HOME/zsh/custom/.zshenv
  fi

fi
