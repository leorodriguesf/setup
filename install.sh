#!/usr/bin/env bash

set -e

OS_TYPE=$(uname -s)

echo -n "=> "

case "$OS_TYPE" in
Darwin)
    echo "macOS detected"
    ;;
Linux)
    if [ ! -f /etc/os-release ]; then
        echo "Not able to detect Linux distro. Stopping"
        exit 1
    fi

    . /etc/os-release

    case "$ID" in
    ubuntu)
        echo "Ubuntu detected"
        ;;
    *)
        exit 1
        ;;
    esac
    ;;
*)
    echo "OS not yet supported. Stopping"
    exit 1
    ;;
esac

echo -e "\nBegin installation (or abort with ctrl+c)..."
