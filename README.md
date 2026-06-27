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
```

# 🔍 Deep Dive: Configuration Files

To understand how FurryOS shapes its environment, you need to look at the custom injected configurations.

### 1. `system_files/etc/sysctl.d/99-furryos-gaming.conf`
This file applies kernel-level parameters the moment the OS boots. It adjusts the virtual memory swappiness (preventing stuttering when RAM fills up) and tweaks the network stack for lower ping in multiplayer games.

### 2. `disk_config/iso-kde.toml`
When `bootc-image-builder` generates the ISO, it reads this file to understand how to format the user's hard drive. FurryOS defaults to a BTRFS layout. This allows for transparent filesystem compression (saving space on massive game installs) and instant filesystem snapshots.

### 3. `Containerfile`
This is the heart of the project. It starts with `FROM ghcr.io/ublue-os/bazzite-nvidia:stable`, copies the `system_files` folder into the root `/` directory, and then executes `build_files/build.sh` to install extra packages (like `htop`, `tmux`, `neovim`) and force kernel updates.

---

## 🔨 How to Build FurryOS from Scratch

Want to compile your own custom version of the OS? Follow these steps exactly.

### Step 1: Prepare the Host Environment
Ensure you are running inside a Linux environment (or WSL2 on Windows). Install the necessary dependencies:

```bash
# For Ubuntu/Debian based hosts
sudo apt update
sudo apt install podman git rsync curl

```

Install `just` (the command runner):

```bash
curl --proto '=https' --tlsv1.2 -sSf [https://just.systems/install.sh](https://just.systems/install.sh) | bash -s -- --to ~/bin
export PATH="$PATH:$HOME/bin"

```

### Step 2: Clone the Repository

```bash
git clone [https://github.com/YourUsername/FurryOS.git](https://github.com/YourUsername/FurryOS.git)
cd FurryOS

```

### Step 3: Build the Container Image

Before making an ISO, you must build the OS as a local container image. This downloads the upstream Bazzite image, applies your custom files, and runs the `build.sh` script.

```bash
podman build --no-cache -t localhost/furryos:latest .

```

> ☕ **Note:** This process downloads several gigabytes of data. Grab a coffee.

### Step 4: Compile the ISO

Once the container is built locally, use the `just` recipe to trigger the `bootc-image-builder` pipeline. This translates the container into a bootable `.iso` file.

```bash
just build-iso

```

If successful, the final ISO will be deposited in the `output/` directory.

### Step 5: Sync to Host (For WSL Users)

If you built this inside WSL2 and need to move the ISO to your Windows desktop, run this custom `rsync` command to bypass permission locks:

```bash
sudo rsync -av --no-perms --no-owner --no-group --chmod=777 --exclude='_build_*' ~/FurryOS/ "/mnt/c/Users/YourUsername/Desktop/FurryOS/"

```

---

## 💿 Flashing & Installation

Once you have your compiled `FurryOS.iso`, you need to put it on a USB drive.

1. Download **Rufus** (Windows) or **BalenaEtcher** (Mac/Linux/Windows).
2. Insert a USB drive (8GB or larger). **Warning: All data on the USB will be destroyed.**
3. Select the `FurryOS.iso` file and flash it to the drive.
4. Reboot your computer and enter your BIOS/UEFI settings (usually `F2`, `F12`, or `DEL`).
5. Disable **Fast Boot**.
6. Set the USB drive as the primary boot device.
7. Save and exit. Follow the Anaconda installer prompts to install FurryOS to your hard drive.

---

## ⚙️ Post-Installation Setup

Because FurryOS is immutable, you do not use `dnf` to install daily applications like Discord, Spotify, or Web Browsers.

### Installing GUI Apps

Use the pre-installed **Discover** software center to browse and install Flatpaks. Flatpaks run cleanly isolated from the system root.

### Installing CLI Tools

If you need developer tools (like Node.js, Python environments, or specific compilers), do not try to layer them onto the root system. Instead, use **Distrobox**:

```bash
# Create an Ubuntu-based container integrated with your home folder
distrobox create -i ubuntu:latest -n dev-box
distrobox enter dev-box

# Now you can use 'apt install' safely!

```

---

## 🚨 Troubleshooting & Git Conflicts

Development is messy. Here are solutions to the most common roadblocks you will hit while building FurryOS.

### ❌ Issue 1: Git Merge Conflicts (`fatal: Exiting because of an unresolved conflict`)

If you see the error in VS Code stating *"Git: fatal: Exiting because of an unresolved conflict,"* accompanied by a red `!M` next to your `Justfile` or `.github` workflows, it means Git tried to pull updates from a remote repository, but your local files have clashing edits.

#### How to Fix It:

1. **Open the Conflicted File:** Click on the `Justfile` (or any file with the red `!`) in the VS Code source control tab.
2. **Locate the Conflict Markers:** Scroll through the file looking for strange symbols like this:
```text
build-iso:
    sudo podman run --rm -it ...
```

3. **Resolve:** VS Code will give you clickable buttons above the conflict: *Accept Current Change*, *Accept Incoming Change*, or *Accept Both*. Click the one that has the correct code you want to keep.
4. **Mark as Resolved:** Once the file is clean, save it. Then, open your terminal and tell Git you fixed it:
```bash
git add Justfile
git commit -m "Resolved merge conflict in Justfile"

```



You can now continue your work!

### ❌ Issue 2: Osbuild 404 Errors (Kernel Sync Failure)

If `just build-iso` crashes around the 22% mark complaining that it cannot download `kernel-modules-core` with a `404 URL returned error`, your container kernel version is out of sync with the live Fedora mirrors.

#### How to Fix It:

Open `build_files/build.sh` and ensure this line is present so the container forces a kernel update before the ISO builder looks for the packages:

```bash
dnf5 install -y kernel kernel-core kernel-modules kernel-modules-core

```

Rebuild the container (`podman build --no-cache...`) and then run `just build-iso` again.

### ❌ Issue 3: Permission Denied (Error 13) on Output

Because `podman` and `osbuild` run as root, the ISO files generated in the `output/` folder will be locked to the root user, preventing you from moving or deleting them.

#### How to Fix It:

Take back ownership of the folder with:

```bash
sudo chown -R $USER:$USER ~/FurryOS/output/

```

---

## 🛠️ Development & Contributing

We welcome pull requests! If you want to add a feature to FurryOS:

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/cool-new-tweak`).
3. If adding a system-wide file, place it in the correct path under `system_files/`.
4. If adding a package, add it to the `dnf5 install` list inside `build_files/build.sh`.
5. Test your build locally using the steps in Section 5.
6. Submit a Pull Request.

> 📝 **Note on `.github/workflows/`:** Any changes pushed to the `main` branch will automatically trigger the GitHub Actions defined in `build.yml` and `build-disk.yml`. Ensure your code passes locally before pushing to save CI/CD minutes!

---

## ❓ Frequently Asked Questions (FAQ)

* **Q: Can I use `rpm-ostree install` instead of `dnf`?**
* **A:** FurryOS is based on standard OCI containers, not traditional `rpm-ostree`. Package additions should be done inside the `Containerfile` or `build.sh` during the build process, not on the live booted system.


* **Q: Why does my screen flicker on boot?**
* **A:** The NVIDIA drivers are initializing. This is normal behavior for `bazzite-nvidia` base images before SDDM loads.


* **Q: Will this delete my Windows install?**
* **A:** If you select "Erase Disk" during the Anaconda installer, YES. If you want to dual-boot, you must manually partition your drive inside the installer, ensuring you do not overwrite your Windows EFI or NTFS partitions.


* **Q: Why is the build taking 30 minutes?**
* **A:** Image building is highly IO-bound and CPU intensive. Compressing the squashfs filesystem for the ISO and downloading gigabytes of RPM packages takes time. Running on an NVMe SSD dramatically reduces this.



---

## 📜 License & Acknowledgements

* **Base System:** Built upon the incredible work of the Ublue-OS Project and Bazzite.
* **OS Framework:** Utilizes Fedora Linux and `bootc`.
* **License:** This project is open-source. (Insert specific license like MIT or GPLv3 here).

*Happy Gaming! Stay fast, stay immutable.* 🐾