#!/bin/sh

wait(){
    read -p "Press enter to continue"
}

important(){
    echo "---------------------------------------------------------"
    echo "-----------------------!IMPORTANT!-----------------------"
    echo "---------------------------------------------------------"
}

partition(){
    (
    echo g # Create a new empty DOS partition table

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
    echo Y      # Do you want to remove signature

    ##swap
    echo n      # Add a new partition
    echo p      # Primary partition
    echo 2      # Partition number
    echo        # First sector
    echo +12G    # Last sector (Accept default: varies)
    echo Y      # Do you want to remove signature

    ##root
    echo n      # Add a new partition
    echo p      # Primary partition
    echo 3      # Partition number
    echo        # First sector
    echo +32G   # Last sector (Accept default: varies)
    echo Y      # Do you want to remove signature

    ##home
    echo n      # Add a new partition
    echo p      # Primary partition
    echo 4      # Partition number
    echo        # First sector
    echo        # Last sector
    echo Y      # Do you want to remove signature

    #Write Changes
    echo w 
    ) | sudo fdisk /dev/sd$1
}

makefilesystems(){
    sudo mkfs.fat -F 32 /dev/sd$11
    fatlabel /dev/sd$11 BOOT
    wait
    sudo mkfs.ext4 /dev/sd$13
    wait
    sudo mkfs.ext4 /dev/sd$14
    wait
    sudo mkswap /dev/sd$12
    sudo swapon /dev/sd$12
    wait
}

mountpartitions(){
    sudo mount /dev/sd$13 /mnt/
    sudo mkdir /mnt/home
    sudo mkdir /mnt/boot
    echo "ls /mnt after mkdir home and boot on mounted root"
    ls /mnt
    wait
    sudo mount /dev/sd$11 /mnt/boot
    sudo mount /dev/sd$14 /mnt/home
    lsblk
    wait
}

installarch(){
    sudo basestrap /mnt base base-devel runit elogind-runit linux linux-firmware  linux-headers sudo vim networkmanager networkmanager-runit
    wait
    artix-chroot /mnt    # Switches to newly created arch as root
}

generatefstab(){
    sudo fstabgen -U /                      # Displays fstab to user
    sudo fstabgen -U / >> /mnt/etc/fstab    # -U is for UUIDS
    echo "cat /mnt/etc/fstab"
    cat /mnt/etc/fstab
    important
    wait
}

finalize(){
    echo "Now run postinstall.sh by typing : sh postinstall.sh"
    artix-chroot /mnt    # Switches to newly created arch as root
}

#sudo pacman -Syyu archlinux-keyring && sudo pacman -Syyu --overwrite "*"
lsblk
read -p "Which drive to format : " driveLetter
partition $driveLetter
makefilesystems $driveLetter
mountpartitions $driveLetter
sudo curl -L https://raw.githubusercontent.com/wolfgangrimmer/artix-legacy-install/master/postUefiInstall.sh > /mnt/postinstall.sh
sudo curl -L https://raw.githubusercontent.com/wolfgangrimmer/artix-legacy-install/master/larbs.sh > /mnt/larbs.sh
installarch
generatefstab
finalize