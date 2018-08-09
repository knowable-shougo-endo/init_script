#!/bin/bash

readonly HOME_LAUNCH_AGENT_PATH="~/Library/LaunchAgents"


#######
## 関数定義
#######

# 自動起動設定用のplistファイルをコピーする
# $1: brewのパッケージ名
CpPlistToLaunchAgent () {
  echo "CpPlistToLaunchAgent $1"
  # コピー先のディレクトリ存在チェック
  if [-e $HOME_LAUNCH_AGENT_PATH]; then
  else
    echo "create $HOME_LAUNCH_AGENT_PATH"
    mkdir $HOME_LAUNCH_AGENT_PATH
  fi

  # plistのパスを取得
  local package_path=(brew info $1 | grep Cellar | cut -d ' ' -f 1)
  echo "package_path: $package_path"
  local plist_path=$(ls -1 $package_path | grep plist > nginx_plist_path)
  echo "plist_path: $plist_path"

  cp $plist_path $HOME_LAUNCH_AGENT_PATH
  if [ $? -eq 0 ]; then
    echo "$1 plist copy success"
    return 0
  else
    echo "$1 plist copy failed"
    return 1
  fi
}

# php
InstallPhp() {
  brew install php

  if [ -z $(which php)  ]; then
    echo 'php install failed'
    return 1
  fi

  CpPlistToLaunchAgent 'php'
  if [ $? -eq 1 ]; then
    return 1
  fi

  # 自動起動設定から起動
  launchctl load -w $(ls -1 $HOME_LAUNCH_AGENT_PATH | grep $1)


  echo 'php install success'
  echo $(php -v | head -n 1)
  return 0
}

# nginx
InstallNginx() {
  brew install nginx

  if [ -z $(which nginx)  ]; then
    echo 'nginx install failed'
    return 1
  fi

  CpPlistToLaunchAgent 'nginx'
  if [ $? -eq 1 ]; then
    return 1
  fi

  # 自動起動設定から起動
  launchctl load -w $(ls -1 $HOME_LAUNCH_AGENT_PATH | grep $1)


  echo 'nginx install success'
  echo $(nginx -v)
  return 0
}

# mysql
InstallMysql() {
  brew install mysql@5.7

  if [ -z $(which mysql)  ]; then
    echo 'mysql install failed'
    return 1
  fi

  CpPlistToLaunchAgent 'mysql'
  if [ $? -eq 1 ]; then
    return 1
  fi

  # 自動起動設定から起動
  launchctl load -w $(ls -1 $HOME_LAUNCH_AGENT_PATH | grep $1)


  echo 'mysql install success'
  echo $(mysql --version)
  return 0
}




# memcached
# PHP用のモジュールも一緒にインストールする
InstallMemcache() {
  ## peclがインストールされているか確認
  if [ -z $(which pecl)  ]; then
    echo 'pecl not installed'
    return 1
  fi

  brew install pkg-config
  pecl install memcached 
  brew install memcached

  if [ -z $(which memcached)  ]; then
    echo 'memcached install failed'
    return 1
  fi

  CpPlistToLaunchAgent 'memcached'
  if [ $? -eq 1 ]; then
    return 1
  fi

  # 自動起動設定から起動
  launchctl load -w $(ls -1 $HOME_LAUNCH_AGENT_PATH | grep $1)


  echo 'memcached install success'
  echo $(memcached --version)
  return 0
}


#######
## メイン処理
#######

echo 'check installed...'
if [ -z $(which php)  ]; then
  echo 'run php install'
  InstallPhp
fi

if [ -z $(which nginx)  ]; then
  echo 'run nginx install'
  InstallNginx
fi

if [ -z $(which mysql)  ]; then
  echo 'run mysql install'
  InstallMysql
fi

if [ -z $(which memcached)  ]; then
  echo 'run memcached install'
  InstallMemcache
fi
