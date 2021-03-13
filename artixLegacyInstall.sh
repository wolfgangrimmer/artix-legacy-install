#!/bin/sh

partition(){
    (
    echo o # Create a new empty DOS partition table

    ##wipe drive
    echo d      # Delete partition
    echo        # Partition numer
    echo d      # Delete partition
    echo        # Partition numer
    echo d      # Delete partition
    echo        # Partition numer
    echo d      # Delete partition
    echo        # Partition numer

    ##boot
    echo n      # Add a new partition
    echo p      # Primary partition
    echo 1      # Partition number
    echo        # First sector (Accept default: 1)
    echo +1G    # Last sector (Accept default: varies)

    ##swap
    echo n      # Add a new partition
    echo p      # Primary partition
    echo 2      # Partition number
    echo        # First sector
    echo +12G    # Last sector (Accept default: varies)

    ##root
    echo n      # Add a new partition
    echo p      # Primary partition
    echo 3      # Partition number
    echo        # First sector
    echo +32G   # Last sector (Accept default: varies)

    ##home
    echo n      # Add a new partition
    echo p      # Primary partition
    echo 4      # Partition number
    echo        # First sector
    echo 

    #Write Changes
    echo w 
    ) | sudo fdisk /dev/sd$1
}

makefilesystems(){
    mkfs.ext4 /dev/sd$11
    mkfs.ext4 /dev/sd$13
    mkfs.ext4 /dev/sd$14
    mkswap /dev/sd$12
    swapon /dev/sd$12
}

mountpartitions(){
    mkdir /mnt/home #possible problem with line endings here, rewrite those two mkdir lines in vim if necessary
    mkdir /mnt/boot
    mount /dev/sd$13 /mnt/
    mount /dev/sd$11 /mnt/boot
    mount /dev/sd$14 /mnt/home
}

generatefstab(){
    fstabgen -U /               # Displays fstab to user
    fstabgen -U / >> /etc/fstab # -U is for UUIDS
}

installarch(){
    basestrap /mnt base base-devel linux linux-firmware runit elogind-runit sudo vim networkmanager networkmanager-runit linux-headers
    echo "Now run postinstall.sh by typing : sh postinstall.sh"
    artix-chroot /mnt    # Switches to newly created arch as root
}

pacman -S archlinux-keyring && sudo pacman -Syu
lsblk
read -p "Which drive to format : " driveLetter
partition $driveLetter
makefilesystems $driveLetter
mountpartitions $driveLetter
curl -L https://raw.githubusercontent.com/wolfgangrimmer/artix-legacy-install/master/postinstall.sh > /mnt/postinstall.sh
curl -L https://raw.githubusercontent.com/wolfgangrimmer/artix-legacy-install/master/larbs.sh > /mnt/larbs.sh
generatefstab
installarch