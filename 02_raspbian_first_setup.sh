#!/bin/bash
# ===================================================
# 題名: Raspbian stretch 初期セットアップ自動化バッチ
# 対象OS: Raspbian stretch 9.0 2018-11-13
# 作成日: 2019-02-15
# 作成者: ytyaru
# セットアップ概要: 
#   * スワップ(拡張 or 停止)
#   * RAMディスク設定
#   * aptのソースを日本サーバに設定
#   * ログ出力の抑制
#   * .bashrcに自作スクリプト呼出を追記
#   * システム更新
#   * 日本語フォント＋日本語入力のインストール
# 実行タイミング:
#   SDカードにRaspbianをインストールし、
#   初回ブートし、
#   ダイアログに従ってセットアップ
#   した後に1度だけ実行する。
#   なお、システム更新はダイアログの時点ではスキップし、このバッチで行うほうが高速に完了するはず。
# ===================================================

# コマンドをsudo権限で実行する
# $1: some linux command.
run_sudo() {
    sudo sh -c "${1}"
}
# 指定したテキストを指定したファイルに追記する
# $1: text: new line text.
# $2: file: target file path.
# http://yut.hatenablog.com/entry/20111013/1318436872
# https://qiita.com/b4b4r07/items/e56a8e3471fb45df2f59
# http://wannabe-jellyfish.hatenablog.com/entry/2015/01/10/004554
# http://pooh.gr.jp/?p=6311
write_line() {
    for i in "${1}"; do
        local command="echo '${i}'"
        sudo sh -c "${command} >> \"${2}\""
    done
}
# 指定ファイルのうち先頭が指定テキストの場合、先頭に#を付与する
# $1: file: target file path.
# $2: text: target text（ヒアドキュメントで複数行指定されることを想定）
#http://linux-bash.com/archives/3745148.html
write_sharp() {
    #IFS_backup=IFS
    #IFS=$'\n'
    for i in ${2}; do
        # 末尾の改行を除去（しないと次のエラーが出る。"sed: -e expression #1, char 2: アドレスregexが終了していません"）
        local line=`echo ${i} | sed -e "s/[\r\n]\+//g"`
        local sed_script="/^${line}/s/^/#/"
        local sed_cmd="sed -e \"${sed_script}\" -i.bak \"${1}\""
        run_sudo "${sed_cmd}"
    done
    #IFS=IFS_backup
}

# スワップ停止（SDカード書込上限対策）
stop_swap() {
    sudo swapoff --all
    sudo systemctl stop dphys-swapfile
    sudo systemctl disable dphys-swapfile
}
# スワップのサイズを100MBから2GBに変更する
setup_swap() {
	local SwapFilePath=/etc/dphys-swapfile
    write_sharp "${SwapFilePath}" "CONF_SWAPSIZE=100"
    write_line "CONF_SWAPSIZE=2048" "${SwapFilePath}"
	sudo systemctl stop dphys-swapfile
	sudo systemctl start dphys-swapfile
}
# RAMディスク作成（SDカード書込上限対策）
write_fstab() {
    text='
tmpfs /tmp            tmpfs   defaults,size=768m,noatime,mode=1777      0       0
tmpfs /var/tmp        tmpfs   defaults,size=16m,noatime,mode=1777      0       0
tmpfs /var/log        tmpfs   defaults,size=32m,noatime,mode=0755      0       0
tmpfs /home/pi/.cache/chromium/Default/  tmpfs  defaults,size=768m,noatime,mode=1777  0  0
tmpfs /home/pi/.cache/lxsession/LXDE-pi  tmpfs  defaults,size=1m,noatime,mode=1777  0  0
'
    write_line "${text}" "/etc/fstab"
}
# システム更新の高速化（日本用）
write_apt_sources_list() {
    text='
deb http://ftp.jaist.ac.jp/raspbian/ stretch main contrib non-free rpi
deb http://ftp.tsukuba.wide.ad.jp/Linux/raspbian/raspbian/ stretch main contrib non-free rpi
deb http://ftp.yz.yamagata-u.ac.jp/pub/linux/raspbian/raspbian/ stretch main contrib non-free rpi
deb http://mirrordirector.raspbian.org/raspbian/ stretch main contrib non-free rpi
# firmwar update
deb http://mirrors.ustc.edu.cn/archive.raspberrypi.org/debian/ stretch main ui
'
    write_line "${text}" "/etc/apt/sources.list"
}

# ログ出力を抑制する（SDカード書込上限対策）
#http://linux-bash.com/archives/3745148.html
#http://momijiame.tumblr.com/post/92049916671/%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%81%AE%E7%89%B9%E5%AE%9A%E8%A1%8C%E3%82%92-sed-%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89%E3%81%A7%E3%82%B3%E3%83%A1%E3%83%B3%E3%83%88%E3%82%A2%E3%82%A6%E3%83%88%E3%81%99%E3%82%8B
#/etc/rsyslog.conf
comment_out_rsyslog_conf() {
    text='
auth,authpriv.*
*.*;auth,authpriv.none
cron.*
daemon.*
kern.*
lpr.*
mail.*
user.*
mail.info
mail.warn
mail.err
*.=debug;\
	auth,authpriv.none;\
	news.none;mail.none	-/var/log/debug
*.=info;*.=notice;*.=warn;\
	auth,authpriv.none;\
	cron,daemon.none;\
	mail,news.none		-/var/log/messages
'

    write_sharp "/etc/rsyslog.conf" "${text}"
}

# .bashrcに自作スクリプト呼出を追記
append_bashrc() {
	timestamp=`date +"%Y-%m-%d %H:%M:%S"`
#    text='
## ${timestamp} 自作スクリプト呼出
#. "$HOME/root/script/sh/_called/bash/bashrc.sh"
#'
	text=$(cat <<EOS
# ${timestamp} 自作スクリプト呼出
. "$HOME/root/script/sh/_called/bash/bashrc.sh"
EOS
)
    write_line "${text}" "/${HOME}/.bashrc"
}
# システム＆ファームウェア更新
update_system() {
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt dist-upgrade -y
}
# 日本語化
japanese() {
    sudo apt install -y fonts-vlgothic fonts-ipafont fonts-ipaexfont
    sudo apt install -y fcitx-mozc
}

# 実行する
#stop_swap
setup_swap
write_fstab
write_apt_sources_list
comment_out_rsyslog_conf
append_bashrc
update_system
japanese
install_apps
# 再起動する
reboot
