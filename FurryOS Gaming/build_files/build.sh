#!/bin/bash
set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

# 1. Clear DNF5 cache and override broken live mirrors with global archive mirrors
dnf5 clean all

if [ -d /etc/yum.repos.d ]; then
    # Force the updates repository to look at the permanent Fedora Project archive instead of a regional mirror
    sed -i 's|^metalink=.*|baseurl=https://fedoraproject-updates-archive.fedoraproject.org/fedora/44/x86_64/|g' /etc/yum.repos.d/fedora-updates.repo || true
    sed -i 's|^#baseurl=.*|baseurl=https://fedoraproject-updates-archive.fedoraproject.org/fedora/44/x86_64/|g' /etc/yum.repos.d/fedora-updates.repo || true
fi

dnf5 clean all

# 2. Install kernel stack and system utilities from the fixed mirror location
dnf5 install -y \
    kernel \
    kernel-core \
    kernel-modules \
    kernel-modules-core \
    htop \
    tmux \
    neovim

# 3. Enable RPM Fusion repos (free + nonfree)
dnf5 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm || true

# 4. Core Gaming & Performance Tools
dnf5 install -y --skip-unavailable \
    steam \
    steam-devices \
    proton-ge-latest-bin \
    mangohud \
    gamemode \
    protontricks \
    winetricks \
    kernel-tools \
    sysstat \
    vulkan-tools \
    glxinfo \
    mesa-demos

# 5. Optional Emulators
dnf5 install -y --skip-unavailable retroarch dolphin-emu || true

#### System Unit Enablement

# Enable container socket
systemctl enable podman.socket

# Cleanup
rpm-ostree cleanup -m
