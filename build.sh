#!/bin/bash

set -euxo pipefail

echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
packages="iwd \
    git \
    go-md2man \
    rsync \
    sudo \
    cowsay \
    just \
    fastfetch \
    distrobox \
    plasma \
    plasma-desktop \
    gvfs \
    sddm \
    base \
    dracut \
    linux \
    linux-firmware \
    ostree \
    btrfs-progs \
    e2fsprogs \
    xfsprogs \
    dosfstools \
    skopeo \
    dbus \
    dbus-glib \
    glib2 \
    shadow"

steam_packages="steam \
    gamescope \
    mangohud \
    lib32-mangohud"
    
pacman -Syu --noconfirm $packages
pacman -S --noconfirm $steam_packages

pacman -S --clean --noconfirm

# rsync -rvK /ctx/sys-files /

systemctl enable sddm
systemctl enable iwd
systemctl enable NetworkManager
