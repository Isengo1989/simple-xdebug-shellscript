#!/bin/bash

function comment() {
    test=${#1}
    init="###"

    while [ $test -gt 0 ]; do
        init=$init"#"
        test=$((test - 1))
    done

    echo -e "\n"$init"###"
    echo -e "## $1 ##"
    echo -e $init"###\n"
}

function enable_xdebug_mod() {
  sudo phpenmod xdebug
}

function disable_xdebug_mod() {
  sudo phpdismod xdebug
}


function disable_CLI() {
  sudo sed -i '/xdebug.remote_enable=1/d' /etc/php/${PHP_VERSION}/cli/php.ini
  sudo sed -i '/xdebug.remote_autostart=1/d' /etc/php/${PHP_VERSION}/cli/php.ini
}

function disable_FPM() {
  sudo sed -i '/xdebug.remote_enable=1/d' /etc/php/${PHP_VERSION}/fpm/php.ini
  sudo sed -i '/xdebug.remote_autostart=1/d' /etc/php/${PHP_VERSION}/fpm/php.ini
}

function disable_BOTH() {
  disable_CLI
  disable_FPM
}

function enable_CLI() {
  sudo sed -i '/xdebug.remote_enable=1/d' /etc/php/${PHP_VERSION}/cli/php.ini
  sudo sed -i '/xdebug.remote_autostart=1/d' /etc/php/${PHP_VERSION}/cli/php.ini
  sudo echo "xdebug.remote_enable=1"  >> /etc/php/${PHP_VERSION}/cli/php.ini
  sudo echo "xdebug.remote_autostart=1"  >> /etc/php/${PHP_VERSION}/cli/php.ini

  export XDEBUG_MODE=debug XDEBUG_SESSION=1 XDEBUG_CONFIG="idekey=PHPSTORM"
}

function enable_FPM() {
  sudo sed -i '/xdebug.remote_enable=1/d' /etc/php/${PHP_VERSION}/fpm/php.ini
  sudo sed -i '/xdebug.remote_autostart=1/d' /etc/php/${PHP_VERSION}/fpm/php.ini
  sudo echo "xdebug.remote_enable=1"  >> /etc/php/${PHP_VERSION}/fpm/php.ini
  sudo echo "xdebug.remote_autostart=1"  >> /etc/php/${PHP_VERSION}/fpm/php.ini
}

function enable_BOTH() {
  enable_CLI
  enable_FPM
}

function restart_php_service() {
  sudo service php${PHP_VERSION}-fpm restart
}


read -p "Enter PHP Version (e.g. 7.4): " PHP_VERSION

if [ ! -d "/etc/php/${PHP_VERSION}" ]
then
    echo "Directory /etc/php/${PHP_VERSION} DOES NOT exists."
    exit 404
fi


comment "You want to enable Xdebug for the CLI or FPM?"
ESC=$(printf "\e")
PS3="$ESC[41m $ESC[97m $ESC[1m Please choose your options: $ESC[0m"
options=("CLI" "FPM" "BOTH" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "CLI")
            TYPE=$opt
            break
            ;;
        "FPM")
            TYPE=$opt
            break
            ;;
        "BOTH")
            TYPE=$opt
            break
            ;;
        "Quit")
            echo "Bye,bye..."
            exit
            ;;
        *) echo invalid option;;
    esac
done

comment "You want to ENABLE or DISABLE Xdebug?"
ESC=$(printf "\e")
PS3="$ESC[41m $ESC[97m $ESC[1m Please choose your options: $ESC[0m"
options=("ENABLE" "DISABLE" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "ENABLE")
            enable_xdebug_mod
            enable_${TYPE}

            break
            ;;
        "DISABLE")
            disable_xdebug_mod
            disable_${TYPE}
            break
            ;;
        "Quit")
            echo "Bye,bye..."
            exit
            ;;
        *) echo invalid option;;
    esac
done

sudo service php${PHP_VERSION}-fpm restart
