#!/bin/sh

postinstallation(){
    ln -s /etc/runit/sv/NetworkManager/ /run/runit/service    # NetworkManager enabled at startup, alternative route (only during system install) is /etc/runit/runsvdir/current
    read -p "Hostname : " hostname
    installgrub $1
    generatelocale
    settimezone
    sethostname $hostname
    sethosts $hostname
    setRootPswd
}

installgrub(){
    pacman -Sy grub os-prober
    grub-install --recheck /dev/sd$1
    grub-mkconfig -o /boot/grub/grub.cfg
}

generatelocale(){
    sed -i -e 's/#en_US/en_US/g' /etc/locale.gen
    locale-gen
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
}

settimezone(){
    ln -sf /usr/share/zoneinfo/Poland /etc/localtime
}

sethostname(){
    echo $hostname > /etc/hostname
}

sethosts(){
    "127.0.0.1  localhost" >> /etc/hosts
    "::1  localhost" >> /etc/hosts
    "127.0.0.1  $1.localdomain $1" >> /etc/hosts
}

setRootPswd(){
    echo "Set root password"
    passwd
}

addNewUser(){
    read -p "User : " user
    useradd -m $user
    passwd $user
}

lsblk
read -p "Drive letter : " driveLetter
postinstallation $driveLetter
echo "Run larbs.sh after reboot"