#!/usr/bin/env bash

set -e

OS_TYPE=$(uname -s)

case "$OS_TYPE" in
Darwin) OS=macOS ;;
Linux)
    if [ ! -f /etc/os-release ]; then
        echo "Not able to detect Linux distro. Stopping"
        exit 1
    fi

    . /etc/os-release

    case "$ID" in
    ubuntu) OS=Ubuntu ;;
    *)
        echo "Linux distro $NAME not supported. Stopping"
        exit 1
        ;;
    esac
    ;;
*)
    echo "OS $OS_TYPE not yet supported. Stopping"
    exit 1
    ;;
esac

ascii_art='
 _                             _       _                           ___ 
| |                           | |     (_)                         / __)
| | _____  ___   ____ ___   __| | ____ _  ____ _   _ _____  ___ _| |__ 
| || ___ |/ _ \ / ___) _ \ / _  |/ ___) |/ _  | | | | ___ |/___|_   __)
| || ____| |_| | |  | |_| ( (_| | |   | ( (_| | |_| | ____|___ | | |   
 \_)_____)\___/|_|   \___/ \____|_|   |_|\___ |____/|_____|___/  |_|   
                                        (_____|                        
'

echo -e "$ascii_art"
echo "=> Installation starting (or abort with ctrl+c)..."

echo -e "\n$OS detected"
echo "Installing $OS dependencies"

case "$OS" in
macOS)
    # Keep sudo alive
    sudo -v

    # Prevent the system from sleeping while the script is running
    caffeinate -s -u -w $$ &

    if [ ! -f /opt/homebrew/bin/brew ]; then
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    if ! command -v brew >/dev/null; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    if ! command -v python3 >/dev/null; then
        brew install python3
    fi

    if ! command -v ansible >/dev/null; then
        brew install ansible
    fi
    ;;
Ubuntu)

    if [ "$(id -u)" -eq 0 ]; then
        alias sudo=""
    fi

    sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target &>/dev/null

    sudo apt-get update

    export DEBIAN_FRONTEND=noninteractive

    if ! command -v git >/dev/null; then
        sudo apt-get install git -y
    fi

    if ! command -v python3 >/dev/null; then
        sudo apt-get install python3 -y
    fi

    if ! command -v ansible >/dev/null; then
        sudo apt install software-properties-common -y
        sudo add-apt-repository --yes --update ppa:ansible/ansible
        sudo apt install ansible -y
    fi

    sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target &>/dev/null
    ;;
esac

echo -e "\n=> $OS dependencies installed"
