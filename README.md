# このソフトウェアについて

　Raspbian初期セットアップ自動化バッチ（Raspbian stretch 2018-11-13版）。

ファイル|概要
--------|----
02_raspbian_first_setup.sh|システム設定
03_install_apps.sh|アプリのインストール

　いずれ以下を追記したい。

ファイル|概要
--------|----
00_create_new_raspbian_HDD.sh|01〜03のファイルをすべて順に実行する
01_download_and_write_raspbian.sh|RaspbianのOSイメージファイルをダウンロード＆HDD書込

　前回のは以下。

* [Raspbian stretch 2018-06-27版](https://github.com/ytyaru/Shell.Raspbian.FirstSetup.20181012100000)

# 狙い

* システム更新の高速化
* 日本語化
* フリーズの改善
	* Swap拡張(2GB)
		* Raspbian を HDD にインストールして USB boot する
		* SDカードをやめてHDDにしたことにより書込上限の考慮不要になりSwap拡張した

## セットアップ概要

* スワップ(拡張 or 停止)
* RAMディスク設定
* aptのソースを日本サーバに設定
* ログ出力の抑制
* .bashrcに自作スクリプト呼出を追記
* システム更新
* 日本語フォント＋日本語入力のインストール
* アプリのインストール

# 前提

1. Raspbian stretch 2018-11-13をSDカードやHDDに書き込む
1. 初回ブートする
1. ダイアログに従い、セットアップする（ただしシステム更新はスキップする）
1. 再起動する
1. 本バッチを1度だけ実行する

# 使い方

```bash
$ ./raspbian_first_setup.sh
```

# 課題

　OSイメージのダウンロードから書込まで自動化するバッチがほしい。以下ディスプレイ設定は初回ブート前に自動設定したい。

* ディスプレイ設定（解像度などディスプレイに応じて）
* 音声出力設定（本体 or HDMI）

　以下もできればオプションで。

* 自作ツール一式コピー
* Chromiumのプロファイル
    * Chromiumの拡張機能を追加したい（stylus, authenticator）
    * stylusのユーザスタイルを追加したい
    * authenticatorにデータをインポートしたい

## 解決した課題

* フォント、もっといいのないか？　なぜかアンダーバーが見えない
	* VLゴシックを追加でインストールする

# ライセンス

このソフトウェアはCC0ライセンスである。

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png "CC0")](http://creativecommons.org/publicdomain/zero/1.0/deed.ja)
