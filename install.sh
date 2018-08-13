#!/bin/bash

readonly HOME_LAUNCH_AGENT_PATH=~/Library/LaunchAgents


#######
## 関数定義
#######

# 自動起動設定用のplistファイルをコピーする
# $1: brewのパッケージ名
CpPlistToLaunchAgent() {
  echo "CpPlistToLaunchAgent $1"
  # コピー先のディレクトリ存在チェック
  if [ -e $HOME_LAUNCH_AGENT_PATH ]; then
    echo "plist path exist."
  else
    echo "create $HOME_LAUNCH_AGENT_PATH"
    mkdir -p $HOME_LAUNCH_AGENT_PATH
    if [ $? -eq 1 ]; then
      echo "$1 mkdir failed"
      return 1
    fi
  fi

  # plistのパスを取得
  local package_path=$(brew info $1 | grep Cellar | cut -d ' ' -f 1)
  echo "package_path: $package_path"
  if [ -z $package_path ]; then
    echo "package_path is empty"
    return 1
  fi
  local plist_filename=$(ls -1 $package_path | grep plist)
  if [ -z $plist_filename ]; then
    echo "plist_filename is empty"
    return 1
  fi
  echo "plist_path: $package_path/$plist_filename"

  cp "$package_path/$plist_filename" $HOME_LAUNCH_AGENT_PATH
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
  launchctl load -w "$HOME_LAUNCH_AGENT_PATH/$(ls -1 $HOME_LAUNCH_AGENT_PATH | grep php)"


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
  launchctl load -w "$HOME_LAUNCH_AGENT_PATH/$(ls -1 $HOME_LAUNCH_AGENT_PATH | grep nginx)"


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

  CpPlistToLaunchAgent 'mysql@5.7'
  if [ $? -eq 1 ]; then
    return 1
  fi

  # 自動起動設定から起動
  launchctl load -w "$HOME_LAUNCH_AGENT_PATH/$(ls -1 $HOME_LAUNCH_AGENT_PATH | grep mysql@5.7)"


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
  launchctl load -w "$HOME_LAUNCH_AGENT_PATH/$(ls -1 $HOME_LAUNCH_AGENT_PATH | grep memcached)"


  echo 'memcached install success'
  echo $(memcached --version)
  return 0
}


#######
## メイン処理
#######

debug_flag=0
# 引数が1つでも指定されたらデバッグモードにする
if [ $# -ge 1 ]; then
  debug_flag=1
fi

echo 'check installed...'
if [ -z $(which php) ] || [ $debug_flag -eq 1 ]; then
  echo "------------------------------------"
  echo 'run php install'
  InstallPhp
fi

if [ -z $(which nginx) ] || [ $debug_flag -eq 1 ]; then
  echo "------------------------------------"
  echo 'run nginx install'
  InstallNginx
fi

if [ -z $(which mysql) ] || [ $debug_flag -eq 1 ]; then
  echo "------------------------------------"
  echo 'run mysql install'
  InstallMysql
fi

if [ -z $(which memcached) ] || [ $debug_flag -eq 1 ]; then
  echo "------------------------------------"
  echo 'run memcached install'
  InstallMemcache
fi
echo 'install finished!'
