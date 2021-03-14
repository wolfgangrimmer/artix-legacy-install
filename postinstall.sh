#!/bin/sh

wait(){
    read -p "Press enter to continue"
}

installgrub(){
    pacman -Sy grub os-prober
    grub-install --recheck /dev/sd$1
    grub-mkconfig -o /boot/grub/grub.cfg
    wait
}

generatelocale(){
    sed -i -e 's/#en_US/en_US/g' /etc/locale.gen
    locale-gen
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    wait
}

settimezone(){
    ln -sf /usr/share/zoneinfo/Poland /etc/localtime
    echo "Timezone set to /usr/share/zoneinfo/Poland"
    wait
}

sethostname(){
    echo $hostname > /etc/hostname
    echo "cat /etc/hostname : "
    cat /etc/hostname
    wait
}

sethosts(){
    echo -e "\n" >> /etc/hosts
    echo "127.0.0.1  localhost" >> /etc/hosts
    echo "::1  localhost" >> /etc/hosts
    echo "127.0.0.1  $1.localdomain $1" >> /etc/hosts
    echo "cat /etc/hosts"
    cat /etc/hosts
    wait
}

setRootPswd(){
    echo "Set root password"
    passwd
    wait
}

addNewUser(){
    read -p "User : " user  
    useradd -m $user
    passwd $user
    usermod –aG wheel $user
    echo "User $user created and added to wheel"
    wait
}

postinstallation(){
    ln -s /etc/runit/sv/NetworkManager/ /etc/runit/runsvdir/current   # NetworkManager enabled at startup, alternative route (only during system install) is /etc/runit/runsvdir/current
    read -p "Hostname : " hostname
    installgrub $1
    generatelocale
    settimezone
    sethostname $hostname
    sethosts $hostname
    setRootPswd
    #addNewUser already in larbs
}

sudo pacman -Syyu archlinux-keyring && sudo pacman -Syyu
lsblk
read -p "Drive letter : " driveLetter
postinstallation $driveLetter
echo "Run larbs.sh after reboot"