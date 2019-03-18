# dotfile

> _"you are your dotfiles"_.

## 概述

> 任何以 `.` 开头的文件或目录名都被认为是隐藏的，默认不会显示

本 dotfile 摘取许多大师的 dotfile

Unix 世界中，程序通常以两种不同的方式配置：以 shell 参数或基于文本的配置文件。
具有许多选项的程序：如窗口管理器、文本编辑器等，是根据每个用户配置的，文件在主目录 `~` 中。

`.` 文件决定了系统外观和功能，参见[ricers](http://unixporn.net)和[beaners](http://nixers.net)
这些文件非常重要，需要备份和共享。创建自定义主题的人还面临着管理多个版本的挑战。

## 内容

macOSX 以及 Linux 自动开发环境集成。macOS 为客户端，Debian 为服务端配置

1. 设置 spf-vim-13、Spacemacs 等文本编辑器
2. macOS X 系统偏好设置
3. Debian Base

## 配置

```bash
curl -fsSL https://raw.githubusercontent.com/iTszFung/dotfung/master/run | sh -c
或者
git clone https://github.com/iTszFung/dotfung.git ~/.dotfung
cd ~/.dotfung && ./install
```

## Reference

- [Brew Website](https://brew.sh/index_zh-cn)
- [Brew Github](https://github.com/Homebrew/brew)
- [Debian Dotfile](https://wiki.debian.org/DotFilesList)
- [XDG Directories](<https://wiki.archlinux.org/index.php/XDG_user_directories_(简体中文)>)
- [Hack](https://github.com/source-foundry/Hack)
- [Source Code Pro](https://github.com/adobe-fonts/source-code-pro)
