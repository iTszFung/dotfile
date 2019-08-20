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
# Created by TszFung Lam on 2018-07-29
# Modify by TszFung Lam on 2018-07-29
# run v0.1.0 一键安装

# sh -c "$(curl -fsSL https://raw.githubusercontent.com/iTszFung/dotfile/master/run.sh)"

RUN_REPO_URL="https://codeload.github.com/iTszFung/dotfile/zip/master"
DOT_DIR="$HOME/.dotfile"
[[ -x `command -v wget` ]] && CMD="wget --no-check-certificate -O -" || CMD="curl -fsSL"
mkdir -p ${DOT_DIR} && \
eval "$CMD $RUN_REPO_URL | tar -xzv -C ${DOT_DIR} --strip-components=1 --exclude='{.gitignore}'"
bash ${DOT_DIR}/install

