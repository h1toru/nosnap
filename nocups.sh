#!/bin/bash

#########################
# https://askubuntu.com/questions/754197/how-to-disable-cups-printer-server-permanently
# https://null-byte.wonderhowto.com/how-to/locking-down-linux-using-ubuntu-as-your-primary-os-part-2-network-attack-defense-0185709/
# https://unix.stackexchange.com/questions/177458/remove-cupsd-completly
#########################

# stop cups services
sudo systemctl stop cups
sudo systemctl disable cups

sudo systemctl stop cups-browsed
sudo systemctl disable cups-browsed

# remove cups
sudo apt -y purge --auto-remove cups
sudo rm -rf /etc/cups

# remove other cups package
sudo apt -y purge --auto-remove cups-*

# disable start script as root
echo 'manual' | sudo tee /etc/init/cups.override >/dev/null
echo 'manual' | sudo tee /etc/init/cups-browsed.override >/dev/null
