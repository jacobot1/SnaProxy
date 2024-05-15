#!/bin/bash

# Function for parsing y/n (courtesy of Tiago Lopo and John Kugelman on Stack Overflow)
function yes_or_no {
    while true; do
        read -p "$* (y/n): " yn
        case $yn in
            [Yy]*) return 0  ;;  
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}

# Function to set proxy
function proxyOn {
    read -p "Proxy address: " proxyaddress
    read -p "Proxy port: " proxyport
    read -p "Proxy username (leave blank if not applicable): " proxyusername
    read -p "Proxy password (leave blank if not applicable): " proxypassword
    if [ ! -z "$proxyusername" ] || [ ! -z "$proxypassword" ]; then
        proxypassword=":${proxypassword}@"
    fi
    sudo touch /etc/apt/apt.conf.d/10proxy
    sudo bash -c "echo 'Acquire::http::Proxy \"http://${proxyusername}${proxypassword}${proxyaddress}:${proxyport}\";' > /etc/apt/apt.conf.d/10proxy"
    sudo bash -c "echo 'http_proxy=\"http://${proxyusername}${proxypassword}${proxyaddress}:${proxyport}\"' > /etc/environment"
    echo 'Proxy set successfully'
    yes_or_no "You must reboot for changes to take effect. Reboot now?" && sudo reboot
}

# Function to remove proxy
function proxyOff {
    sudo rm -f /etc/apt/apt.conf.d/10proxy
    sudo bash -c "echo > /etc/environment"
    echo 'Proxy removed successfully'
    yes_or_no "You must reboot for changes to take effect. Reboot now?" && sudo reboot
}


if [ ! -f /etc/apt/apt.conf.d/10proxy ] && [ "$(cat /etc/environment)" = "" ]; then
# If required proxy setup code doesn't exist, ask for confirmation and put it where it goes.
    yes_or_no "No proxy is currently set. Set one?" && proxyOn
else
# Otherwise, if proxy setup code exists, ask for confirmation and remove it.
    yes_or_no "A proxy is currently set. Remove it?" && proxyOff
fi