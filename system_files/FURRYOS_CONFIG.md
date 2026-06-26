# FurryOS Gaming Distro - System Configuration Guide

## Overview
FurryOS is a gaming-focused Fedora Atomic-based distribution built on Bazzite-NVIDIA. It includes Steam, Proton-GE, multiple emulators, and system optimizations for gaming performance.

## What's Included

### Gaming Essentials
- **Steam**: Full Steam client with native runtime
- **Proton-GE**: Bleeding-edge Proton version for maximum game compatibility
- **MangoHUD**: Real-time performance overlay (FPS counter, CPU/GPU usage)
- **GameMode**: Automatic performance optimization daemon for games
- **Protontricks/Winetricks**: Utilities for Windows game compatibility

### Emulators
- **RetroArch**: Multi-system emulator (NES, SNES, Genesis, PSX, N64, etc.)
- **PCSX2**: PlayStation 2 emulator
- **Dolphin**: GameCube and Wii emulator

### Performance Optimization

#### System Configuration Files
1. **`/etc/sysctl.d/99-furryos-gaming.conf`**
   - Kernel network parameters optimized for low-latency gaming
   - TCP buffer sizes increased for better throughput
   - VM swappiness reduced to minimize frame stutters
   - CPU scheduler tuning for better thread locality

2. **`/etc/security/limits.d/99-furryos-gaming.conf`**
   - Increased file descriptor limits for Steam and games
   - Higher max process count for multi-threaded games
   - Increased locked memory for audio performance
   - Realtime priority support for audio/gaming threads

3. **`/etc/gamemode.ini`**
   - GameMode daemon configuration
   - Automatic performance optimization when games launch
   - CPU governor switching to "performance" during gaming

#### KDE Plasma Theme (`~/.config/kdeglobals` and `~/.config/plasmarc`)
- Dark theme optimized for gaming (reduces eye strain during long sessions)
- Colors inspired by SteamOS 3 design
- Pre-configured for new users through `/etc/skel/`

### System Components
- **Audio**: PipeWire with PulseAudio compatibility for low-latency audio
- **Vulkan Support**: Full Vulkan stack (tools, libraries, drivers)
- **NVIDIA Support**: NVIDIA drivers included via Bazzite base image
- **Utilities**: kernel-tools, sysstat for performance monitoring

## Usage

### Launching Games
1. **Steam (Native)**
   ```bash
   steam
   ```
   - Use Proton-GE as your compatibility tool
   - Enable MangoHUD overlay: right-click game → Properties → Advanced → Launch Options → add `-mangohud`

2. **Emulators**
   - RetroArch: `retroarch`
   - PCSX2: `pcsx2`
   - Dolphin: `dolphin-emu`

### GameMode
GameMode automatically activates when launching Steam games. To manually enable:
```bash
gamemoderun <command>
```

### Performance Monitoring
- **Live FPS/Stats**: Use MangoHUD overlay (configured in-game or at launch)
- **System Stats**: `htop` or `sysstat` tools

## Building the Image

### Prerequisites
- bootc-enabled system or container engine (podman/docker)
- Cosign key pair for signing (already in place: `cosign.pub`)

### Build
```bash
just build  # Full image build
just iso-kde  # Build KDE Plasma ISO
```

### Verify Build
After building, verify components are present:
```bash
bootc image info <image-name>
podman run <image-name> which steam
podman run <image-name> which retroarch
```

## Customization

### Adding System Files
Place files in `system_files/` with the same directory structure as the root filesystem:
- System configs: `system_files/etc/`
- User defaults: `system_files/etc/skel/`
- Themes/assets: `system_files/usr/share/`

### Modifying build.sh
Edit `build_files/build.sh` to:
- Add/remove packages
- Enable additional COPR repositories
- Configure services
- Install additional emulators or tools

### Adjusting Performance Tuning
Edit `/etc/sysctl.d/99-furryos-gaming.conf` and `/etc/security/limits.d/99-furryos-gaming.conf` before rebuild.

## Known Considerations

- **PCSX2 COPR**: Requires `theofficialgman/pcsx2` COPR; enabled/disabled during build
- **Image Size**: Gaming packages increase image to ~3-4 GB; ensure 20 GB+ storage for full system
- **Proton-GE**: Updates independently of the image; Steam will manage versions
- **Kernel**: Uses Fedora Atomic default kernel; custom kernels not supported (bootc limitation)

## Troubleshooting

### Games won't launch
- Ensure Proton-GE is selected in Steam properties
- Run with Protontricks for Windows dependency setup: `protontricks <game-id>`
- Check MangoHUD output for driver/library issues

### Performance issues
- Verify GameMode is running: `systemctl --user status gamemoded`
- Check thermal throttling: `sensors` or use GPU monitoring tools
- Adjust sysctl settings if needed (requires rebuild or manual tuning)

### Emulator crashes
- Verify ROM format compatibility (RetroArch: check system database)
- PCSX2: May require PS2 BIOS files
- Dolphin: May require GameCube/Wii BIOS

## Additional Resources

- [Bazzite Project](https://github.com/ublue-os/bazzite)
- [Universal Blue Documentation](https://ublue.it/)
- [bootc Project](https://bootc.dev/)
- [Steam Proton Documentation](https://github.com/ValveSoftware/Proton)

---

**FurryOS**: A furry-friendly gaming distro for everyone! 🐾
