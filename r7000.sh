#!/bin/bash

# Archlinux installation script for Lenovo LEGION R7000

# Enable ssh
# https://unix.stackexchange.com/questions/352139/how-to-setup-ssh-access-to-arch-linux-iso-livecd-booted-computer

# Set console font
setfont /usr/share/kbd/consolefonts/LatGrkCyr-12x22.psfu.gz

# Ensure the system clock is accurate
timedatectl set-ntp true

# Set system partition
mkfs.ext4 /dev/nvme0n1p5
mount /dev/nvme0n1p5 /mnt

# Set boot partition
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot

# Select the mirrors
mirror1='Server = https://mirrors.aliyun.com/archlinux/$repo/os/$arch'
mirror2='Server = https://mirrors.cloud.tencent.com/archlinux/$repo/os/$arch'
mirror3='Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch'
mirror4='Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch'
mirror5='Server = https://mirrors.zju.edu.cn/archlinux/$repo/os/$arch'
sed -i "1i $mirror5" /etc/pacman.d/mirrorlist
sed -i "1i $mirror4" /etc/pacman.d/mirrorlist
sed -i "1i $mirror3" /etc/pacman.d/mirrorlist
sed -i "1i $mirror2" /etc/pacman.d/mirrorlist
sed -i "1i $mirror1" /etc/pacman.d/mirrorlist

# Install base, linux, linux-firmware packages and base-devel package groups
pacstrap /mnt base linux linux-firmware base-devel

# Generate an fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Configure the system
cat << EOF | arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc
sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
sed -i "s/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g" /etc/locale.gen
sed -i "s/#zh_HK.UTF-8 UTF-8/zh_HK.UTF-8 UTF-8/g" /etc/locale.gen
sed -i "s/#zh_TW.UTF-8 UTF-8/zh_TW.UTF-8 UTF-8/g" /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 >> /etc/locale.conf
echo "arch" >> /etc/hostname
echo root:' ' | chpasswd
pacman -S --noconfirm xorg plasma dolphin kate kdialog efibootmgr keditbookmarks kfind khelpcenter kwrite ark gwenview grub nano git wget konsole networkmanager sddm os-prober ntfs-3g noto-fonts-cjk bluez bluez-utils pulseaudio-bluetooth sudo

# Install grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg

#Set user
useradd -m -G wheel toy
echo toy:' ' | chpasswd
sed -i "s/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g" /etc/sudoers
systemctl enable sddm
systemctl enable bluetooth.service
systemctl enable NetworkManager
echo -e 'load-module module-bluetooth-policy\nload-module module-bluetooth-discover' >> /etc/pulse/system.pa

# Set archlinuxcn mirror
#curl https://gitee.com/toyohama/arch_install/raw/master/archlinuxcnmirrorlist >> /etc/pacman.conf
pacman -Sy --noconfirm archlinuxcn-keyring

#Install some software
pacman -S --noconfirm yay
yay -Sy --noconfirm pamac-aur firefox monaco v2raya google-chrome fcitx-qt4 fcitx-qt5 fcitx-configtool xsettingsd visual-studio-code-bin netease-cloud-music 

#Set swap (32G)
dd if=/dev/zero of=/swapfile bs=1G count=20 status=progress 
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo /swapfile none swap defaults 0 0 >> /etc/fstab
EOF

# Unmount
umount /mnt/boot
umount /mnt

# Enjoy
