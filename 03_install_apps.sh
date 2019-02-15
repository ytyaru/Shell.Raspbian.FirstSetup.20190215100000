#!/bin/bash
# ===================================================
# 題名: アプリケーションのインストール自動化バッチ
# 対象OS: Raspbian stretch 9.0 2018-11-13
# 作成日: 2019-02-15
# 作成者: ytyaru
# 実行タイミング: 02_raspbian_first_setup.sh の実行後
# 概要: 
#   * 汎用系
#		* テキストエディタ: pluma
#		* 画像エディタ: gimp
#		* オフィス: libreoffice
#   * 開発系
#		* C#
#			* mono-devel
#			* monodevelop
# ===================================================

# アプリケーションのインストール
install_apps() {
	install_general
	install_sdk
}
# 汎用系アプリケーションインストール
install_general() {
	sudo apt install -y pluma
	sudo apt install -y gimp
#	install_libreoffice
}
install_libreoffice() {
	sudo apt install libreoffice
	sudo apt install libreoffice-help-ja
}
# 開発系アプリケーションインストール
install_sdk() {
	install_sdk_mono
	install_sdk_monodevelop
}
install_sdk_mono() {
	time sudo apt install -y apt-transport-https dirmngr
	time sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
	echo "deb https://download.mono-project.com/repo/debian stable-raspbianstretch main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
	time sudo apt install -y mono-devel
}
install_sdk_monodevelop() {
	time sudo apt install -y monodevelop
# MonoDevelop拡張機能のインストール
# https://github.com/picoe/Eto/releases
}
# ブラウザの設定
# * 起動時：`前回開いていたページを開く`
# * ダウンロード 保存先：`/tmp`
# ブラウザ拡張機能のインストール
# [ublock-origin](https://chrome.google.com/webstore/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm?hl=ja)|広告ブロック
# [stylus](https://chrome.google.com/webstore/detail/stylus/clngdbkpkpeebahjckkjfobafhncgmne)|ユーザスタイルシート
# [authenticator](https://chrome.google.com/webstore/detail/authenticator/bhghoamapcdpbohphigoooaddinpkbai?hl=ja)|二段階認証アプリ

# 実行する
install_apps

