#!/bin/bash

cat << EOF

	┌────────────────────────────────────────────────────────────┐
	│                                                            │
	│                  Snap Remover/Uninstaler                   │
	│                <https://github.com/h1toru>                 │
	│                                                            │
	└────────────────────────────────────────────────────────────┘

EOF

# detect distro
if [ "$(cat /etc/os-release | sed -n 's|^ID=||p')" != 'ubuntu' ]; then
	echo "This script only support Ubuntu."
	exit 1
fi

# detect root
if [ "$EUID" == '0' ]; then
cat << EOF

	┌──────────────────────────────────────────────────────────────────────┐
	│ Please don't run this script as root, it may break you system.       │
	│ Root access will be asked when it needed.                            │
	└──────────────────────────────────────────────────────────────────────┘

EOF
exit 1
fi

# confirmation-msg
while true; do
	read -p "Are you sure to remove Snap completely? [Y/n] " yn
	case $yn in
		[Yy]) break ;;
		[Nn]) exit ;;
		*) echo "Input [n] to abort." ;;
	esac
done

# remove snap packages
{	snap list | awk '!/^Name|^bare|^core|^snapd / {print $1}'
	snap list | awk '/^bare/ {print $1}'
	snap list | awk '/^core/ {print $1}'
	snap list | awk '/^snapd / {print $1}'
} | while read i; do sudo snap remove --purge $i; done

# stop snap services
sudo systemctl stop snapd
#sudo systemctl stop snapd.service
#sudo systemctl stop snapd.socket
sudo systemctl stop snapd.seeded.service

sudo systemctl disable snapd
#sudo systemctl disable snapd.service
#sudo systemctl disable snapd.socket
sudo systemctl disable snapd.seeded.service

# unmount snap partition(s) (mounted on /snap)
for i in $(df -h | awk '/snap/ {print $6}'); do
	sudo umount $i
done

# remove cache
sudo rm -rf /var/cache/snapd

# remove snap from apt
sudo apt -y purge --auto-remove snapd

# reinstall cups
sudo apt -y reinstall cups

# remove leftover files
rm -rf ~/snap
sudo rm -rf /snap
sudo rm -rf /var/snap
sudo rm -rf /var/lib/snapd

#sudo find / -type 'd' -iname '*snap' -o -iname '*snapd' 2>/dev/null |
#egrep -iv 'nosnap|snapshot|/media' |
#while read I; do sudo rm -rf $I; done

# block re-entry of snap on apt
sudo tee /etc/apt/preferences.d/nosnap << EOF > /dev/null
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

# output-msg
cat << EOF

	┌─────────────────────────────────────────────────────────────────────┐
	│ Snap successfully removed from your computer!                       │
	│ Please reboot to take effect.                                       │
	└─────────────────────────────────────────────────────────────────────┘

EOF

# cups
while true; do
	read -p "Did you also want to remove Cups? [Y/n] " yn
	case $yn in
		[Yy]) curl -fsSL https://raw.githubusercontent.com/h1toru/nosnap/master/nocups.sh | bash ;;
		[Nn]) break ;;
		*) echo "Please input [n] to cancel." ;;
	esac
done
