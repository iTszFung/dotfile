#!/usr/bin/env bash
# https://www.cnblogs.com/zhengran/p/4802582.html
# http://blog.alutam.com/2012/04/01/optimizing-macos-x-lion-for-ssd/
# https://mths.be/macos
# http://www.osdata.com/programming/shell/defaults.html
# https://blog.csdn.net/cneducation/article/details/3851554
# http://osxdaily.com/category/mac-os-x/
# http://www.osdata.com/programming/shell/unixbook.pdf
# https://lists.apple.com/mailman/listinfo/security-announce

osascript -e 'tell application "System Preferences" to quit'

sudo -v
# 将 sudo 保持运行到脚本结束（60秒更新一次 sudo 时间戳）
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
# 关闭 系统设置面板

###############################################################################
# 通用设置、基本 UI
###############################################################################

# 启动、关机、重启、恢复、更新、休眠
# 设置计算机名称（系统首选项→共享）
# sudo scutil --set ComputerName "TszFungs MacBook Pro"
# sudo scutil --set HostName "TszFungs-MacBook-Pro.local"
# sudo scutil --set LocalHostName "antic"
# sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "TszFungs-MacBook-Pro"

# 使用 verbols 显示启动过程（总是以详细模式引导(而不是MacOS GUI模式），需要禁止去除 ="-v"
# sudo nvram boot-args="-v"
# 允许 'locate' 命令
# sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist > /dev/null 2>&1
# 禁用启动时的声音效果
# sudo nvram SystemAudioVolume=" "
# 在任何 Mac 电脑上启用 MacBook Air超级驱动器
# sudo nvram boot-args="mbasd=1"
# 禁用恢复系统
# defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false
# 永远不要进入电脑休眠模式
sudo systemsetup -setcomputersleep Off > /dev/null
# 如果计算机死机，则自动重启
sudo systemsetup -setrestartfreeze on
# 禁用崩溃报告程序
defaults write com.apple.CrashReporter DialogType -string "none"
# 禁用非活动应用程序的自动终止
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true
# 默认情况下保存到磁盘 而不是iCloud
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
# 打印作业完成后自动退出打印机应用程序
# defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
# 删除 “打开” 菜单中的重复项（也请参阅“lscleanup”别名）
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
# 将帮助查看器窗口设置为非浮动模式
defaults write com.apple.helpviewer DevMode -bool true
# 禁用通知中心并删除菜单栏图标
# launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist > /dev/null 2>&1
# 启动 SSH
sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist
# 提高蓝牙耳机/耳机的音质
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40
# 禁用橡胶滚动
# http://osxdaily.com/2012/05/10/disable-elastic-rubber-band-scrolling-in-mac-os-x/
# defaults write -g NSScrollViewRubberbanding -int 0
# 双击最大化窗口
defaults write -g AppleActionOnDoubleClick 'Maximize'

# 外观 石墨
# defaults write -g AppleAquaColorVariant -int 6
# 禁用平滑滚动（如果使用旧 Mac 会弄乱动画）
# defaults write NSGlobalDomain NSScrollAnimationEnabled -bool false
# 总是显示滚动条：`WhenScrolling`, `Automatic` and `Always`
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
# 设置高亮颜色为绿色
defaults write NSGlobalDomain AppleHighlightColor -string "0.764700 0.976500 0.568600"
# 设置侧边栏图标大小为中等
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

# 文本显示、字体渲染、窗口及对话框设置、菜单栏设置
# 在标准文本视图中使用插入符号显示 ASCII 控制字符
# e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true
# Mojave 渲染字体太细，使用常规的 pre-mojave 样式:
# defaults write -g CGFontRenderingFontSmoothingDisabled -bool NO
# 在非苹果 LCD 上启用亚像素字体呈现
defaults write NSGlobalDomain AppleFontSmoothing -int 2
# 增加 Cocoa 应用程序的窗口调整速度
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# 禁用显示 “是否打开此程序”
defaults write com.apple.LaunchServices LSQuarantine -bool false
# 总是使用展开保存/打印对话框:
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# 菜单栏和其他地方禁用透明度
# defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool false
defaults write com.apple.universalaccess reduceTransparency -bool true
# 菜单栏：隐藏时间机器、音量、用户和蓝牙图标
for domain in ~/Library/Preferences/ByHost/com.apple.systemuiserver.*; do
  defaults write "${domain}" dontAutoLoad -array \
    "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
    "/System/Library/CoreServices/Menu Extras/Volume.menu" \
    "/System/Library/CoreServices/Menu Extras/User.menu"
done;
defaults write com.apple.systemuiserver menuExtras -array \
  "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
  "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
  "/System/Library/CoreServices/Menu Extras/Battery.menu" \
  "/System/Library/CoreServices/Menu Extras/Clock.menu"

# 显示剩余电池时间 (10.8之前)
defaults write com.apple.menuextra.battery ShowPercent -string "YES"
# 显示电池百分比
defaults write com.apple.menuextra.battery ShowTime -string "YES"

# 自动隐藏菜单栏
# defaults write NSGlobalDomain _HIHideMenuBar -bool true
# 黑暗菜单栏 和 Dock
defaults write $HOME/Library/Preferences/.GlobalPreferences.plist AppleInterfaceTheme -string "Dark"

###############################################################################
# Spotlight
###############################################################################

# Spotlight 菜单快捷键：none
/usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.symbolichotkeys.plist" -c 'Delete AppleSymbolicHotKeys:64' > /dev/null 2>&1
/usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.symbolichotkeys.plist" -c 'Add AppleSymbolicHotKeys:64:enabled bool false'

# Spotlight 窗口快捷键：none
/usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.symbolichotkeys.plist" -c 'Delete AppleSymbolicHotKeys:65' > /dev/null 2>&1
/usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.symbolichotkeys.plist" -c 'Add AppleSymbolicHotKeys:65:enabled bool false'
# 隐藏Spotlight托盘图标和后续助手
sudo chmod 600 /System/Library/CoreServices/Search.bundle/Contents/MacOS/Search

# 为任何已挂载且尚未建立的 Volume 禁用 Spotlight 索引
# 使用 `sudo mdutil -i off "/Volumes/foo"` 停止索引任何 Volume
sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"
# 更改索引顺序并禁用某些文件类型
defaults write com.apple.spotlight orderedItems -array \
	'{"enabled" = 1;"name" = "APPLICATIONS";}' \
	'{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
	'{"enabled" = 1;"name" = "DIRECTORIES";}' \
	'{"enabled" = 1;"name" = "PDF";}' \
	'{"enabled" = 1;"name" = "FONTS";}' \
	'{"enabled" = 0;"name" = "DOCUMENTS";}' \
	'{"enabled" = 0;"name" = "MESSAGES";}' \
	'{"enabled" = 0;"name" = "CONTACT";}' \
	'{"enabled" = 0;"name" = "EVENT_TODO";}' \
	'{"enabled" = 0;"name" = "IMAGES";}' \
	'{"enabled" = 0;"name" = "BOOKMARKS";}' \
	'{"enabled" = 0;"name" = "MUSIC";}' \
	'{"enabled" = 0;"name" = "MOVIES";}' \
	'{"enabled" = 0;"name" = "PRESENTATIONS";}' \
	'{"enabled" = 0;"name" = "SPREADSHEETS";}' \
	'{"enabled" = 0;"name" = "SOURCE";}' \
	'{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
	'{"enabled" = 0;"name" = "MENU_OTHER";}' \
	'{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
	'{"enabled" = 0;"name" = "MENU_EXPRESSION";}' \
	'{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
	'{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'

# 禁用每个文件的上次访问时间记录
# echo '<?xml version="1.0" encoding="UTF-8"?>
# <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
# <plist version="1.0">
# 	<dict>
# 		<key>Label</key>
# 		<string>com.nullvision.noatime</string>
# 		<key>ProgramArguments</key>
# 		<array>
# 			<string>mount</string>
# 			<string>-vuwo</string>
# 			<string>noatime</string>
# 			<string>/</string>
# 		</array>
# 		<key>RunAtLoad</key>
# 		<true/>
# 	</dict>
# </plist>' | sudo tee /Library/LaunchDaemons/com.nullvision.noatime.plist
# sudo chown root:wheel /Library/LaunchDaemons/com.nullvision.noatime.plist

# 确保为 Main Volume 启用了索引
# sudo mdutil -i on / > /dev/null

###############################################################################
# 桌面和屏幕保护
###############################################################################

# 要求密码后立即睡觉或屏幕保护程序开始
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

defaults write com.apple.screencapture location -string "${HOME}/Desktop"
defaults write com.apple.screencapture type -string "png"
# 启用 HiDPI 显示模式(需要重启)
# sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

defaults write NSGlobalDomain com.apple.springing.enabled -bool true
defaults write NSGlobalDomain com.apple.springing.delay -float 0

###############################################################################
# Keyboard、Trackpad、mouse、Bluetooth accessories、input
###############################################################################

# Keyboard
# 为所有控件启用全键盘访问 (例如，在模式对话框中启用Tab)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
# 禁用键的按下和按住，以支持键重复
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# 设置快速键盘重复率
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# 禁用自动纠正
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
# 禁用智能引号，在输入代码时很烦人
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
# 禁用自动大写
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
# 禁用自动周期替换
# defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
# 打字时检查拼写
defaults write -g CheckSpellingWhileTyping -boolean true
# 在任何地方启用连续拼写检查（不知道这是什么意思）
defaults write -g WebContinuousSpellCheckingEnabled -boolean true
# 不要在低光下照射内置键盘
defaults write com.apple.BezelServices kDim -bool false
# 当电脑不使用5分钟时，关闭键盘高光
defaults write com.apple.BezelServices kDimTime -int 300

# Trackpad
# 为该用户和登录屏幕启用 tap 单击
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
# 右键单击右下角的轨迹板
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
# defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
# defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
# 用三根手指在书页间滑动
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerHorizSwipeGesture -int 1
# Three-finger 拖动
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# Mouse
# 允许鼠标行为
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
# 禁用鼠标加速器
defaults write .GlobalPreferences com.apple.mouse.scaling -1

# 为辅助设备启用访问
echo -n 'a' | sudo tee /private/var/db/.AccessibilityAPIEnabled > /dev/null 2>&1
sudo chmod 444 /private/var/db/.AccessibilityAPIEnabled
# TODO: 以某种方式避免GUI密码提示 (http://apple.stackexchange.com/q/60476/4408)
#sudo osascript -e 'tell application "System Events" to set UI elements enabled to true'

# 禁用 'natural 滚动'(Lion 风格)
# defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
# defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
# defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true
# defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
# 禁用多点触扫动
# defaults write -g AppleEnableSwipeNavigateWithScrolls -int 0

# 停止iTunes响应键盘媒体键
# launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null
# 添加键盘快捷键 ⌘+ Enter Mail发送一封电子邮件
defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" -string "@\\U21a9"


##############################################################################
# Security
# https://github.com/drduh/macOS-Security-and-Privacy-Guide
# https://benchmarks.cisecurity.org/tools2/osx/CIS_Apple_OSX_10.12_Benchmark_v1.0.0.pdf
##############################################################################

# 启用防火墙
#   0 = off
#   1 = on for specific sevices
#   2 = on for essential services
# 打开防火墙 stealth 模式 (no response to ICMP / ping requests)
# Source: https://support.apple.com/kb/PH18642
sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
sudo defaults write /Library/Preferences/com.apple.alf stealthenabled -int 1

# 启用防火墙日志记录
#sudo defaults write /Library/Preferences/com.apple.alf loggingenabled -int 1

# 不自动允许已签名的软件接收传入连接
#sudo defaults write /Library/Preferences/com.apple.alf allowsignedenabled -bool false

# 记录防火墙 90 天内事件
#sudo perl -p -i -e 's/rotate=seq compress file_max=5M all_max=50M/rotate=utc compress file_max=5M ttl=90/g' "/etc/asl.conf"
#sudo perl -p -i -e 's/appfirewall.log file_max=5M all_max=50M/appfirewall.log rotate=utc compress file_max=5M ttl=90/g' "/etc/asl.conf"
# 记录90天的身份验证事件
#sudo perl -p -i -e 's/rotate=seq file_max=5M all_max=20M/rotate=utc file_max=5M ttl=90/g' "/etc/asl/com.apple.authd"
# 记录一年的安装事件
#sudo perl -p -i -e 's/format=bsd/format=bsd mode=0640 rotate=utc compress file_max=5M ttl=365/g' "/etc/asl/com.apple.install"
# 增加 system.log 和 secure.log 的保留时间
#sudo perl -p -i -e 's/\/var\/log\/wtmp.*$/\/var\/log\/wtmp   \t\t\t640\ \ 31\    *\t\@hh24\ \J/g' "/etc/newsyslog.conf"
# 将内核事件记录 30 天
#sudo perl -p -i -e 's|flags:lo,aa|flags:lo,aa,ad,fd,fm,-all,^-fa,^-fc,^-cl|g' /private/etc/security/audit_control
#sudo perl -p -i -e 's|filesz:2M|filesz:10M|g' /private/etc/security/audit_control
#sudo perl -p -i -e 's|expire-after:10M|expire-after: 30d |g' /private/etc/security/audit_control

# 重新加载防火墙
launchctl unload /System/Library/LaunchAgents/com.apple.alf.useragent.plist
sudo launchctl unload /System/Library/LaunchDaemons/com.apple.alf.agent.plist
sudo launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist
launchctl load /System/Library/LaunchAgents/com.apple.alf.useragent.plist

# 禁用红外（IR）遥控
#sudo defaults write /Library/Preferences/com.apple.driver.AppleIRController DeviceEnabled -bool false

# 彻底关闭蓝牙
#sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 0
#sudo launchctl unload /System/Library/LaunchDaemons/com.apple.blued.plist
#sudo launchctl load /System/Library/LaunchDaemons/com.apple.blued.plist

# 禁用专属 wifi 端口
#sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control Active -bool false

# 关闭远程 apple 事件
sudo systemsetup -setremoteappleevents off
# 关闭远程登录
# sudo systemsetup -setremotelogin off
# 关闭 wake-on 模式
# sudo systemsetup -setwakeonmodem off
# 关闭 wake-on LAN
# sudo systemsetup -setwakeonnetworkaccess off
# 禁止通过 AFP or SMB 分享
# sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist
# sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.smbd.plist

# 显示登录窗口的名称和密码
sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true
# 不显示密码提示
sudo defaults write /Library/Preferences/com.apple.loginwindow RetriesUntilHint -int 0
# 禁用客户帐户登录
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false
# 在登录窗口点击时钟时显示IP地址、主机名、操作系统版本等
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
# 禁用 “重新登录时重新打开窗口”
# defaults write com.apple.loginwindow TALLogoutSavesState -bool false
# defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false

# 自动锁定登录密钥链为不活动后6小时
#security set-keychain-settings -t 21600 -l ~/Library/Keychains/login.keychain
# 进入待机模式时销毁FileVault密钥，强制重新验证
# Source: https://web.archive.org/web/20160114141929/http://training.apple.com/pdf/WP_FileVault2.pdf
#sudo pmset destroyfvkeyonstandby 1
# 禁用Bonjour多播广告
sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true
# 禁用诊断报告
# sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.SubmitDiagInfo.plist

###############################################################################
# SSD-specific tweaks
###############################################################################

# 禁用休眠(加速进入睡眠模式)
sudo pmset -a hibernatemode 0

# 删除休眠映像文件以节省磁盘空间
sudo rm -rf /Private/var/vm/sleepimage
# 创建一个零字节的文件
sudo touch /Private/var/vm/sleepimage
# 确保它不会被重写
sudo chflags uchg /Private/var/vm/sleepimage

# 禁用 sudden motion sensor，因为它对 ssd 没有用处
# sudo pmset -a sms 0

###############################################################################
# 语言和文本格式
###############################################################################

# 设置语言和文本格式
# Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
# `Inches`, `en_GB` with `en_US`, and `true` with `false`.
# defaults write NSGlobalDomain AppleLanguages -array "en"
# defaults write NSGlobalDomain AppleLocale -string "en_US@currency=USD"
# defaults write NSGlobalDomain AppleMeasurementUnits -string "Inches"
# defaults write NSGlobalDomain AppleMetricUnits -bool false

###############################################################################
# 时间、日期、时区
###############################################################################

# 设置 timezone
# 查看其他值：sudo systemsetup -listtimezones
sudo systemsetup -settimezone "Asia/Shanghai" > /dev/null

# Custom DateFormat
defaults write com.apple.menuextra.clock DateFormat "EEE MMM d  H:mm"

###############################################################################
# 节能设置
###############################################################################

# # 将待机延迟设置为24小时（默认1小时）
# sudo pmset -a standbydelay 86400
# # 10 分钟之后睡眠
# sudo pmset -b sleep 10
# # 5 分钟后显示睡眠
# sudo pmset -b displaysleep 5
# # 10 分钟后硬盘休眠
# sudo pmset -b disksleep 10
# # 使用此电源时，请将显示器调暗
# sudo pmset -b lessbright 1
# # 在显示器休眠前自动降低亮度
# sudo pmset -b halfdim 1
# # 如果计算机死机，则自动重启
# sudo pmset -b panicrestart 15
# # 网络接入唤醒
# sudo pmset -c womp 0
# # 断电后自动启动
# sudo pmset -c autorestart 1

###############################################################################
# Finder 配置
###############################################################################

# Finder: 显示路径
defaults write com.apple.finder ShowPathbar -bool true
# 执行搜索时，默认情况下搜索当前文件夹
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# 在所有Finder窗口中默认使用列表视图
# 视图模式: `icnv`, `clmv`, `Flwv`, `Nlsv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# 展开以下文件信息窗格： “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true
# 按名称排序时，将文件夹放在顶部(Sierra 以上)
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# 设置桌面为新查找器窗口的默认位置
# 对于其他路径, use 'PfLo' 和 'file:///full/path/here/'
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"
# 显示隐藏文件夹
defaults write com.apple.finder AppleShowAllFiles -bool true
# 允许通过 ⌘ + Q 退出 Finder 这样做也会隐藏桌面图标
defaults write com.apple.finder QuitMenuItem -bool true
# 禁用获取动画 ⌘ + i
# defaults write com.apple.finder DisableAllAnimations -bool true
# 在桌面上显示硬盘驱动器、服务器和移动硬盘等图标
#defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
#defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
#defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
#defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
# 在Finder中显示所有文件名扩展名
# defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# 在Finder中显示状态栏
defaults write com.apple.finder ShowStatusBar -bool true
# 允许文本选择在快速查看
defaults write com.apple.finder QLEnableTextSelection -bool true
# 禁用磁盘映像验证
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true
# 安装卷时自动打开一个新的查找器窗口
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true
# 显示完整的 POSIX 路径作为 Finder 窗口标题
# defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
# 避免在网络卷上创建 .DS_Store 文件
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
# 在更改文件扩展名时禁用警告
# defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# 在桌面图标下面显示项目信息
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
# 在桌面和其他图标视图的图标下方显示项目信息
#/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
#/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
# 为桌面和其他图标视图中的图标启用 snap-to-grid
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
# 增加桌面和其他图标视图中图标的网格间距
#/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
#/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
#/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
# 增加桌面和其他图标视图中图标的大小
#/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
#/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
#/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
# 插入移动硬盘时自动打开新窗口
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true
# 禁用声音
# defaults write com.apple.finder FinderSounds -boolean false
# 在清空垃圾之前禁用警告
# defaults write com.apple.finder WarnOnEmptyTrash -bool false
# 默认情况下安全清空垃圾
defaults write com.apple.finder EmptyTrashSecurely -bool true
# 在以太网和 不支持 AirDrop 的 Lion 上启用 AirDrop
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true
# 显示 ~/Library 文件夹
chflags nohidden ~/Library
# 显示 /Volumes
sudo chflags nohidden /Volumes

###############################################################################
# Time Machine、Activity Monitor（活动监视器）、Quick Look
###############################################################################

# 防止 Time Machine 提示使用新的硬盘驱动器作为备份卷
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
hash tmutil &> /dev/null && sudo bash -c "tmutil disable local"

# 启动 Activity Monitor 时显示主窗口
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
# 在 Activity Monitor Dock icon 中可视化CPU使用情况
defaults write com.apple.ActivityMonitor IconType -int 5
# 显示 Activity Monitor 中的所有流程
defaults write com.apple.ActivityMonitor ShowCategory -int 0
# 根据CPU使用情况对 Activity Monitor 结果进行排序
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0
# 启用磁盘实用程序中的debug菜单
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true

# 禁用 Quick Look 动画
defaults write -g QLPanelAnimationDuration -float 0

# 自动播放视频时，打开与QuickTime播放器
# defaults write com.apple.QuickTimePlayerX MGPlayMovieOnOpen -bool true

###############################################################################
# Dock 、Dashboard、Hot corners、启动台、Mission Control
###############################################################################

# Hot corners
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# 左上角
# defaults write com.apple.dock wvous-tl-corner -int 2
# defaults write com.apple.dock wvous-tl-modifier -int 0
# 左下角 → Start screen saver
# defaults write com.apple.dock wvous-bl-corner -int 5
# defaults write com.apple.dock wvous-bl-modifier -int 0
# 右上角 → Desktop
# defaults write com.apple.dock wvous-tr-corner -int 4
# defaults write com.apple.dock wvous-tr-modifier -int 0
# 右下角 → Launchpad
# defaults write com.apple.dock wvous-br-corner -int 11
# defaults write com.apple.dock wvous-br-modifier -int 0

# 为 Dock 图标启用滚动手势
defaults write com.apple.dock scroll-to-open -bool true
# 不要根据最近的使用自动重新排列空格
defaults write com.apple.dock mru-spaces -bool false
# Dock 更加透明
defaults write com.apple.dock hide-mirror -bool true
# 为堆栈的网格视图启用高亮悬停效果 (Dock)
defaults write com.apple.dock mouse-over-hilite-stack -bool true
# 为所有停靠项启用弹簧加载
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true
# 为 Dock 上打开的应用程序显示指示灯
defaults write com.apple.dock show-process-indicators -bool true
# 不要从 Dock 中激活打开的应用程序
# defaults write com.apple.dock launchanim -bool false
# 移除自动隐藏 Dock 延迟
# defaults write com.apple.Dock autohide-delay -float 0
# 隐藏/显示 Dock 时动画时间 (删除动画使用 0)
defaults write com.apple.dock autohide-time-modifier -float 0.25
# 使用 2D Dock
# defaults write com.apple.dock no-glass -bool true
# 使隐藏应用程序的 Dock 图标半透明
defaults write com.apple.dock showhidden -bool true
# 自动隐藏 Dock
# defaults write com.apple.dock autohide -bool true
# 在 Dock 中启用 iTunes 跟踪通知
# defaults write com.apple.dock itunes-notifications -bool true
# 从 Dock 中删除所有(默认)应用图标，只有在安装新 Mac 电脑，或者不使用 Dock 启动应用程序时，这才真正有用。
# defaults write com.apple.dock persistent-apps -array
# 在 Dock 左侧添加一个分隔符 (应用程序所在的位置)
# defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
# 在 Dock 右侧 (垃圾桶所在位置) 加一个间隔
# defaults write com.apple.dock persistent-others -array-add '{tile-data={}; tile-type="spacer-tile";}'
# 禁用启动板手势(用拇指和三个手指捏)
# defaults write com.apple.dock showLaunchpadGestureEnabled -int 0
# 禁用打开和关闭窗口动画
# defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
# 更改最小化/最大化窗口效果
defaults write com.apple.dock mineffect -string "scale"

# 在 Dock 中只显示打开的应用程序
# defaults write com.apple.dock static-only -bool true
# 将窗口最小化到应用程序的图标中
defaults write com.apple.dock minimize-to-application -bool true
# 禁用 Dock 放大
# defaults write com.apple.dock magnification -bool false
# Dock 尺寸和位置
defaults write com.apple.Dock size-immutable -bool false
# 将停靠项的图标大小设置为60像素
defaults write com.apple.dock tilesize -int 60
# 禁用图标跳跃（好像不能用）
# defaults write com.apple.dock no-bouncing -bool true
# 启用 Command-Tab 中的空格开关
defaults write com.apple.dock workspaces-auto-swoosh -bool true

# 禁用 Mission Control 动画
defaults write com.apple.dock expose-animation-duration -float 0.1
# 按应用程序将 Mission Control 窗口分组
defaults write com.apple.dock expose-group-by-app -bool true

# 禁用 Dashboard
# defaults write com.apple.dashboard mcx-disabled -bool true
# 不要将 Dashboard 显示为空格
defaults write com.apple.dock dashboard-in-overlay -bool true
# 开启 Dashboard 开发模式 允许在桌面上保存小部件
defaults write com.apple.dashboard devmode -bool true

# 禁用截图中的阴影
# defaults write com.apple.screencapture disable-shadow -bool true

# 添加 iOS & Watch 模拟器到启动台
sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" "/Applications/Simulator.app"
sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator (Watch).app" "/Applications/Simulator (Watch).app"

# 重置启动板，但要保持桌面壁纸完好无损
find "${HOME}/Library/Application Support/Dock" -name "*-*.db" -maxdepth 1 -delete

###############################################################################
# iTunes、Photos、Mac App Store、Address Book、iCal、TextEdit、Mail
###############################################################################

# ⌘ + F 在 iTunes 中的搜索输入，在其他语言中使用这些命令, 浏览 iTunes’s package 的 Contents
# 打开 `Contents/Resources/your-language.lproj/Localizable.strings` 以及 查找 `kHiddenMenuItemTargetSearch`
defaults write com.apple.iTunes NSUserKeyEquivalents -dict-add "Target Search Field" "@F"
# 禁用 iTunes 中的 Ping 侧边栏
defaults write com.apple.iTunes disablePingSidebar -bool true
# 禁用 iTunes 中所有其他 Ping 功能
defaults write com.apple.iTunes disablePing -bool true
# 禁用 iTunes 商店链接箭头
defaults write com.apple.iTunes show-store-link-arrows -bool false
# 禁用 iTunes 中的 Genius 侧边栏
defaults write com.apple.iTunes disableGeniusSidebar -bool true
# 禁用 iTunes 中的电台
defaults write com.apple.iTunes disableRadio -bool true

# 当设备插入电源时，防止照片自动打开
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

# 在 AppStore 启用 debug 菜单
defaults write com.apple.appstore WebKitDeveloperExtras -bool true
defaults write com.apple.appstore ShowDebugMenu -bool true

# 启用自动更新检查
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# 每天检查软件更新，而不是每周检查一次
# defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# 在后台下载最新可用的更新
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# 安装系统数据文件和安全更新
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# 自动下载在其他mac电脑上购买的应用程序
# defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1

# 打开app自动更新
defaults write com.apple.commerce AutoUpdate -bool true

# 允许App Store在macOS更新时重启机器
defaults write com.apple.commerce AutoUpdateRestartRequired -bool true


# 在 Address Book 启用 debug 菜单
defaults write com.apple.addressbook ABShowDebugMenu -bool true

# 在 iCal 启用 debug 菜单 (10.8 之前)
defaults write com.apple.iCal IncludeDebugMenu -bool true
# Show 24 hours a day
defaults write com.apple.ical "number of hours displayed" 24
# Week should start on Monday
defaults write com.apple.ical "first day of the week" 1
# Day starts at 9AM
defaults write com.apple.ical "first minute of work hours" 540

# 为新的 TextEdit 文档使用纯文本模式
defaults write com.apple.TextEdit RichText -int 0
# 在 TextEdit 中打开并保存 UTF-8 文件
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# 禁用 Mail 中的发送和回复动画
# defaults write com.apple.Mail DisableReplyAnimations -bool true
# defaults write com.apple.Mail DisableSendAnimations -bool true
# 在 Mail 中复制电子邮件地址为 `foo@example.com`，而不是 `Foo Bar <foo@example.com>`
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false
# 禁用内联附件（只显示图标）
defaults write com.apple.mail DisableInlineAttachmentViewing -bool true
# 禁用自动拼写检查
defaults write com.apple.mail SpellCheckingBehavior -string "NoSpellCheckingEnabled"

# 以线程模式显示电子邮件，按日期排序(最老的在顶部)
defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "yes"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"

###############################################################################
# WebKit、Safari、Google Chrome、Google Chrome Canary、Opera & Opera Developer
###############################################################################

# 添加用于在 Web 视图中显示 Web 检查器的上下文菜单项
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Safari
# 启用 Safari 的 debug 菜单
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
# 从 Safari 的 bofinishedmarks 栏中删除无用的图标
# defaults write com.apple.Safari ProxiesInBofinishedmarksBar "()"
# 从Safari的书签栏中删除无用的图标
# defaults write com.apple.Safari ProxiesInBookmarksBar "()"
# 为历史和热门网站禁用 Safari 的缩略图缓存
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2
# 使 Safari 的搜索横幅默认为包含而不是开始
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false
# 将Safari的主页设置为 about:blank
defaults write com.apple.Safari HomePage -string "about:blank"
# 防止Safari在下载后自动打开文件
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
# 允许按退格键进入历史的前一页
# defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true
# 默认情况下隐藏 Safari 书签栏
defaults write com.apple.Safari ShowFavoritesBar -bool false
# 在 Safari 中启用开发菜单和 Web 检查器
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
# 隐私:不要向苹果发送搜索查询
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true
# 在 Top Site 中隐藏 Safari 的侧边栏
defaults write com.apple.Safari ShowSidebarInTopSites -bool false
# 禁用呈现 web 页面时的延迟
defaults write com.apple.Safari WebKitInitialTimedLayoutDelay 0.25
# 禁用Safari中的自动更正
defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false
# 屏蔽 pop-up 窗口
defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false
# 启动 “不跟踪”
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true
# 禁用自动播放视频
#defaults write com.apple.Safari WebKitMediaPlaybackAllowsInline -bool false
#defaults write com.apple.SafariTechnologyPreview WebKitMediaPlaybackAllowsInline -bool false
#defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false
#defaults write com.apple.SafariTechnologyPreview com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false

# Chrome
# 允许通过 GitHub、Userscripts.org 安装用户脚本
defaults write com.google.Chrome ExtensionInstallSources -array "https://*.github.com/*" "http://userscripts.org/*"
defaults write com.google.Chrome.canary ExtensionInstallSources -array "https://*.github.com/*" "http://userscripts.org/*"
# 禁用 Chrome 的滑动控件
# defaults write com.google.Chrome.plist AppleEnableSwipeNavigateWithScrolls -bool FALSE
# 禁用轨迹板上过于敏感的反向滑动
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false

# 禁用魔术鼠标上所有过于敏感的反向滑动
defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableMouseSwipeNavigateWithScrolls -bool false

# 使用系统本机打印预览对话框
defaults write com.google.Chrome DisablePrintPreview -bool true
defaults write com.google.Chrome.canary DisablePrintPreview -bool true

# 默认情况下展开打印对话框
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true

# 默认情况下展开打印对话框
defaults write com.operasoftware.Opera PMPrintingExpandedStateForPrint2 -boolean true
defaults write com.operasoftware.OperaDeveloper PMPrintingExpandedStateForPrint2 -boolean true

###############################################################################
# Terminal & iTerm 2
###############################################################################

# Terminal 中只用 UTF8
defaults write com.apple.terminal StringEncodings -array 4
# 在 Terminal 和所有的 X11 apps 启用 “focus follows mouse”
# 可以将鼠标悬停在窗口上并开始在其中键入内容，而无需首先单击
#defaults write com.apple.terminal FocusFollowsMouse -bool true
#defaults write org.x.X11 wm_ffm -bool true
# 在 Terminal 中启用安全键盘输入
# See: https://security.stackexchange.com/a/47786/8918
defaults write com.apple.terminal SecureKeyboardEntry -bool true
# 禁用烦人的行标记
defaults write com.apple.Terminal ShowLineMarks -int 0

# 退出 iTerm 时不要显示提示
defaults write com.googlecode.iterm2 PromptOnQuit -bool false
# 隐藏 Tab
defaults write com.googlecode.iterm2 HideTab -bool true
defaults write com.googlecode.iterm2 Hotkey -bool true
# 设置 system-wide 热键 `^\`来显示或隐藏 iterm
defaults write com.googlecode.iterm2 HotkeyChar -int 96
defaults write com.googlecode.iterm2 HotkeyCode -int 50
defaults write com.googlecode.iterm2 HotkeyModifiers -int 262401
# 在拆分窗格中隐藏窗格标题
defaults write com.googlecode.iterm2 ShowPaneTitles -bool false
# split-terminal 变暗动画
defaults write com.googlecode.iterm2 AnimateDimming -bool true
defaults write com.googlecode.iterm2 "Normal Font" -string "Hack-Regular 12";
defaults write com.googlecode.iterm2 "Non Ascii Font" -string "RotipoMonoForPowerline-Regular 12";
/usr/libexec/PlistBuddy -c "set \"New Bookmarks\":0:\"Custom Directory\" Recycle" ~/Library/Preferences/com.googlecode.iterm2.plist
# 指定首选项目录
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$CONFIG_HOME/iterm"
# 告诉 iTerm2 使用目录中的自定义首选项
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
defaults read -app iTerm > /dev/null 2>&1

###############################################################################
# Messages
###############################################################################

# 禁用自动表情符号替换（i.e. 使用纯文本笑脸）
# defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false
# 禁用智能引号
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false
# 禁用连续拼写检查
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false

###############################################################################
# Optional / Experimental
###############################################################################

# 禁用恢复系统
# TODO: might want to enable this again and set specific apps that this works great for
# e.g. defaults write com.microsoft.word NSQuitAlwaysKeepsWindows -bool true
# Fix for the ancient UTF-8 bug in QuickLook (http://mths.be/bbo)
# Commented out, as this is known to cause problems in various Adobe apps :(
# See https://github.com/mathiasbynens/dotfiles/issues/237
# echo "0x08000100:0" > ~/.CFUserTextEncoding

# 删除 Dropbox 在 Finder 中的绿色复选标记图标
# file=/Applications/Dropbox.app/Contents/Resources/emblem-dropbox-uptodate.icns
# file=/Applications/Dropbox.app/Contents/Resources/check.icns
# [ -e "${file}" ] && mv -f "${file}" "${file}.bak"
# unset file

# 重置 Launchpad
[ -e ~/Library/Application\ Support/Dock/*.db ] && rm ~/Library/Application\ Support/Dock/*.db
# 关闭应用程序
for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
    "Dock" "Finder" "Mail" "Messages" "Photos" "Safari" "SystemUIServer" "SizeUp" \
    "Terminal" "Tweetbot" "iCal" "iTunes" "mds" "Opera"; do
    killall "${app}" &> /dev/null
done

echo "macOS Hacks Done. Note that some of these changes require a logout/restart to take effect."


