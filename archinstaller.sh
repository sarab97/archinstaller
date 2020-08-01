#!/bin/bash

timedatectl set-ntp true
(echo o; echo n; echo p; echo 1; echo ""; echo ""; echo w;) | fdisk /dev/vda
mkfs.ext4 /dev/vda1
mount /dev/vda1 /mnt
pacstrap /mnt base base-devel linux linux-firmware openssh dhcpcd syslinux
genfstab -U /mnt >> /mnt/etc/fstab

cat <<EOF > /mnt/root/part.sh

pacman -S ca-certificates-utils --noconfirm
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
sed -i '/#en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
sed -i '/#en_GB.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
locale-gen
echo LANG=en_GB.UTF-8 > /etc/locale.conf
echo arch > /etc/hostname
echo "" >> /etc/hosts
echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1    localhost" >> /etc/hosts
echo "127.0.0.1    arch    arch.lan" >> /etc/hosts
pacman -S mariadb python3 php vim php-fpm vi sudo bash-completion git php-gd php-intl php-tidy apache php-apache rsync nginx-mainline --noconfirm
systemctl enable dhcpcd sshd mariadb nginx php-fpm
mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
syslinux-install_update -i -a -m
sed -i 's/sda3/vda1/' /boot/syslinux/syslinux.cfg
sed -i 's/TIMEOUT 50/TIMEOUT 1/' /boot/syslinux/syslinux.cfg
sed -i 's/TIMEOUT 50/TIMEOUT 1/' /boot/syslinux/syslinux.cfg
sed -i '/#hostname/s/^#//g' /etc/dhcpcd.conf
useradd -m sarab
echo sarab:sarab | chpasswd
echo root:root | chpasswd
usermod -aG wheel sarab
sed -i '/%wheel/s/^#//g' /etc/sudoers
#(echo "create user 'sarab'@'%' identified by 'sarab';"; echo "create user 'sarab'@'localhost' identified by 'sarab';"; echo "grant all privileges on *.* to 'sarab'@'%';"; echo "grant all privileges on *.* to 'sarab'@'localhost';"; echo "flush privileges;"; echo "quit";) | mysql
mkdir -p /srv/http
chmod -R 0755 /srv/http
chown -R http:http /srv/http
cd /home/sarab
sudo -u sarab git clone https://aur.archlinux.org/yay.git
cd yay
sudo -u sarab makepkg -si --noconfirm
rm -rf yay
exit
exit
EOF

chmod +x /mnt/root/part.sh
arch-chroot /mnt /root/part.sh

rm /mnt/root/part.sh
umount /mnt
poweroff
