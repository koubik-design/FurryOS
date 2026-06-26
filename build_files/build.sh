#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# 1. Base Utilities
dnf5 install -y tmux neovim htop

# 2. Enable RPM Fusion repos (free + nonfree)
dnf5 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm || true

# 3. Core Gaming & Performance Tools
# Removed 'gamemode-daemon', 'pipewire-pulseaudio-free', and missing steam elements.
# Added --skip-unavailable safely across the whole block.
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

# 4. Optional Emulators (via DNF if available, safely skipped if missing)
dnf5 install -y --skip-unavailable retroarch dolphin-emu || true

#### System Unit Enablement

# Enable container socket
systemctl enable podman.socket

# Enable GameMode daemon for performance optimization
# systemctl enable gamemoded.service

# Enable container socket
systemctl enable podman.socket

# Cleanup
rpm-ostree cleanup -m