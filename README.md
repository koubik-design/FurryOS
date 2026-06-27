# 🐾 FurryOS: The Immutable Gaming Experience

Welcome to the official repository for **FurryOS**, a next-generation, container-native operating system designed specifically for gamers, power users, and creators. 

Built on the rock-solid, immutable foundation of **Fedora 44** and heavily leveraging the architecture of **Bazzite (`bazzite-nvidia:stable`)**, FurryOS takes desktop Linux to the next level. By managing the entire operating system as an OCI container image, updates are atomic, rollbacks are instant, and your core system is virtually unbreakable.

This document serves as the complete master guide: from understanding the architecture and features, to setting up your build environment, compiling the ISO yourself, and troubleshooting common Git and OSBuild pipeline errors.

---

## 📑 Table of Contents

1. [Core Features & Philosophy](#-core-features--philosophy)
2. [System Requirements](#-system-requirements)
3. [Project Architecture & Directory Map](#-project-architecture--directory-map)
4. [Deep Dive: Configuration Files](#-deep-dive-configuration-files)
5. [How to Build FurryOS from Scratch](#-how-to-build-furryos-from-scratch)
6. [Flashing & Installation](#-flashing--installation)
7. [Post-Installation Setup](#-post-installation-setup)
8. [Troubleshooting & Git Conflicts](#-troubleshooting--git-conflicts)
9. [Development & Contributing](#-development--contributing)
10. [Frequently Asked Questions (FAQ)](#-frequently-asked-questions-faq)
11. [License & Acknowledgements](#-license--acknowledgements)

---

## 🌟 Core Features & Philosophy

FurryOS is not just another Linux distribution; it is an **image-based, atomic OS**. 

### 🛡️ Immutable Core
The root filesystem is read-only. Applications are installed via Flatpak, Distrobox, or inside user-space containers. This prevents software rot, accidental system bricking, and ensures that every boot is exactly as intended.

### 🎮 Gaming First
FurryOS is tuned for maximum framerates and minimum latency:
* **NVIDIA Native:** Built directly from the `bazzite-nvidia` upstream, meaning proprietary NVIDIA drivers are baked into the kernel image. No post-install driver hunting required.
* **Kernel Tuning:** Custom `sysctl.d` and `limits.d` configurations prioritize game processes and reduce input lag.
* **GameMode & MangoHud:** Feral Interactive's GameMode is pre-configured (`gamemode.ini`), and MangoHud is available out-of-the-box for performance telemetry.
* **Proton & Wine:** Pre-loaded with Proton-GE, protontricks, and winetricks for seamless Windows game compatibility.

### 🎨 Beautiful Desktop
* **KDE Plasma:** Powered by the highly customizable KDE Plasma desktop environment.
* **SteamOS Theme:** Includes the `steamos-kde` SDDM login theme for a console-like experience.
* **Custom Assets:** Unique default wallpapers (`default.png`) and configurations loaded directly into `/etc/skel/`.

---

## 💻 System Requirements

### To Run FurryOS (Target Hardware)
* **CPU:** 64-bit AMD or Intel processor (Quad-core or better recommended).
* **GPU:** NVIDIA GTX 10-series or newer (due to the `bazzite-nvidia` base).
* **RAM:** 8GB Minimum (16GB+ highly recommended for modern gaming).
* **Storage:** 64GB Minimum SSD/NVMe (BTRFS filesystem used by default).
* **Motherboard:** UEFI with Secure Boot (can be enrolled via MokManager).

### To Build FurryOS (Host Machine)
* **OS:** Windows 11 with WSL2 (Ubuntu/Debian) OR a native Linux environment.
* **Memory:** At least 8GB of RAM allocated to WSL/Linux.
* **Disk Space:** 40GB+ of free space for container caching and ISO output.
* **Tools Required:** `podman`, `git`, `just`, `rsync`, and `osbuild`.

---

## 🗺️ Project Architecture & Directory Map

FurryOS is structured like a software project rather than a traditional OS ISO. Here is the exact layout of the repository and what every component does:

```text
FurryOS/
├── .github/                       # CI/CD Pipeline Automation
│   └── workflows/                 
│       ├── build-disk.yml         # GitHub Action to compile the disk image remotely
│       ├── build.yml              # GitHub Action for standard container builds
│       └── dependabot.yml         # Automated dependency updates
├── renovate.json5                 # Renovate bot config for keeping upstream packages fresh
├── build_files/
│   └── build.sh                   # THE ENGINE: The main bash script executed inside the container
├── disk_config/                   # bootc-image-builder configurations
│   ├── disk.toml                  # Base disk layout and partitioning rules
│   ├── iso-kde.toml               # KDE-specific ISO deployment settings
│   └── iso.toml                   # Generic ISO deployment settings
├── system_files/                  # Files copied directly into the OS root filesystem
│   ├── etc/
│   │   ├── security/limits.d/
│   │   │   └── 99-furryos-gaming.conf # Unlocks memory/process limits for games
│   │   ├── skel/.config/          # Default settings applied to all NEW users
│   │   │   ├── kde.org/session    # KDE session initialization
│   │   │   ├── kdeglobals         # KDE global color/theme settings
│   │   │   └── plasmarc           # Plasma panel/widget layout defaults
│   │   ├── sysctl.d/
│   │   │   └── 99-furryos-gaming.conf # Kernel tweaks for network and CPU scheduling
│   │   ├── .gitkeep
│   │   └── gamemode.ini           # System-wide Feral GameMode config
│   └── usr/
│       ├── share/
│       │   └── backgrounds/
│       │       └── furryos/
│       │           └── default.png # The flagship desktop wallpaper
│       ├── .gitkeep
│       └── FURRYOS_CONFIG.md      # On-system documentation reference
├── .gitignore                     # Prevents output/ and temp files from being committed
├── artifacthub-repo.yml           # Metadata for container registry indexing
├── Containerfile                  # The blueprint that pulls Bazzite and applies build_files/
├── cosign.pub                     # Cryptographic public key for verifying image signatures
├── FurryOS.code-workspace         # VS Code workspace configuration file
├── image-template.env             # Environment variables for the image builder
├── IMPLEMENTATION_C...            # Project planning and implementation notes
└── Justfile                       # Command automation recipes (the `just` command)