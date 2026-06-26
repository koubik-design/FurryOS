# FurryOS Gaming Distro - Implementation Checklist

## ✅ Completed Tasks

### Phase 1: Metadata & Configuration
- [x] Updated `image-template.env`:
  - IMAGE_NAME: `furryos`
  - REPO_ORGANIZATION: `furryos`
  - IMAGE_DESC: Updated to gaming distro description
  - IMAGE_KEYWORDS: Added gaming-related keywords

### Phase 2: Gaming Package Installation
- [x] Updated `build_files/build.sh` with:
  - **Core gaming**: Steam packages, steam-devices, steam-firmware, steam-native-runtime
  - **Proton**: proton-ge-latest-bin for bleeding-edge compatibility
  - **Tools**: mangohud, gamemode, gamemode-daemon, protontricks, winetricks
  - **Audio**: pipewire-pulseaudio-free, pipewire-alsa (PipeWire optimization)
  - **Emulators**: 
    - RetroArch (multi-system)
    - Dolphin (GameCube/Wii)
    - PCSX2 (PlayStation 2) via COPR
  - **Performance**: kernel-tools, sysstat
  - **Graphics**: vulkan-tools, glxinfo, mesa-demos
  - **Services**: GameMode daemon enabled, Podman socket enabled
  - **Cleanup**: rpm-ostree cleanup included

### Phase 3: System Configuration
- [x] Created `/system_files/etc/skel/.config/kdeglobals`:
  - Dark color scheme optimized for gaming
  - SteamOS 3-inspired colors (blues and dark grays)
  - Font configuration for system consistency

- [x] Created `/system_files/etc/skel/.config/plasmarc`:
  - Plasma desktop configuration template
  - Default desktop layout

- [x] Created `/system_files/etc/sysctl.d/99-furryos-gaming.conf`:
  - Network optimization (TCP buffers, socket options)
  - Kernel scheduler tuning
  - VM swappiness reduction
  - IO scheduler hints for SSD gaming

- [x] Created `/system_files/etc/security/limits.d/99-furryos-gaming.conf`:
  - Increased file descriptor limits (524288)
  - Higher max process count (65535)
  - Unlimited locked memory and stack
  - Realtime priority support (rtprio=99)

- [x] Created `/system_files/etc/gamemode.ini`:
  - GameMode daemon configuration
  - Performance governor settings
  - Audio configuration
  - Whitelist for Steam/Proton/Protontricks

- [x] Created `/system_files/FURRYOS_CONFIG.md`:
  - Comprehensive guide for system components
  - Usage instructions
  - Build process documentation
  - Customization guidelines
  - Troubleshooting section

## 📋 Verification Checklist

### Before Building
- [ ] Verify `image-template.env` contains correct GitHub org name (if different from "furryos")
- [ ] Review `build_files/build.sh` for any package compatibility issues
- [ ] Confirm all gaming packages are available in RPMfusion/COPR repos
- [ ] Check Containerfile is ready (verified as-is, no changes needed)

### Build Process
- [ ] Run `just build` to compile image
- [ ] Check for build errors (especially PCSX2 COPR availability)
- [ ] Verify image boots successfully
- [ ] Confirm KDE Plasma launches with correct theme

### Post-Build Testing
- [ ] Test Steam launches and connects to network
- [ ] Verify Proton-GE is available in Steam settings
- [ ] Test RetroArch launches
- [ ] Verify GameMode daemon is running: `systemctl --user status gamemoded`
- [ ] Check MangoHUD installation: `mangohud --help`
- [ ] Test one game via Proton (if possible)
- [ ] Generate ISO via `just iso-kde` if needed

## 📦 Next Steps for User

1. **Update GitHub organization** (if different from "furryos"):
   - Edit `image-template.env`, line 6: `REPO_ORGANIZATION="your-org"`

2. **Build the image**:
   - Run `just build` from workspace root
   - Wait for completion (may take 10-30 minutes depending on system)

3. **Test the image**:
   - Boot VM or install on test hardware
   - Verify Steam, emulators, and performance tools are present

4. **Customize further** (optional):
   - Add custom wallpapers to `system_files/usr/share/backgrounds/`
   - Add custom icons/themes to `system_files/usr/share/icons/`
   - Modify `build_files/build.sh` to add more packages
   - Adjust `sysctl` and `limits` configs for specific hardware

5. **Publish**:
   - Set up GitHub Actions for automated builds (if using GitHub)
   - Push to container registry (Quay.io, ghcr.io, etc.)
   - Update ArtifactHub with image metadata

## 🔍 File Structure Summary

```
FurryOS/
├── image-template.env ..................... [✅ Updated] FurryOS branding
├── Containerfile .......................... [✅ Verified] No changes needed
├── build_files/
│   └── build.sh ........................... [✅ Updated] Gaming packages + optimizations
├── system_files/
│   ├── FURRYOS_CONFIG.md .................. [✅ Created] Comprehensive guide
│   ├── etc/
│   │   ├── skel/.config/
│   │   │   ├── kdeglobals ................ [✅ Created] Dark gaming theme
│   │   │   └── plasmarc .................. [✅ Created] Plasma config
│   │   ├── sysctl.d/
│   │   │   └── 99-furryos-gaming.conf .... [✅ Created] Kernel tuning
│   │   ├── security/limits.d/
│   │   │   └── 99-furryos-gaming.conf .... [✅ Created] Resource limits
│   │   └── gamemode.ini .................. [✅ Created] GameMode config
│   └── usr/
│       └── [ready for themes/assets]
├── Justfile ............................... [No changes needed]
├── disk_config/ ........................... [No changes needed]
└── cosign.pub ............................. [✅ Already present]
```

---

**Status**: 🟢 Implementation Complete - Ready for Build Testing

**Summary**: FurryOS gaming distro now has:
- Steam + Proton-GE + Protontricks
- RetroArch + PCSX2 + Dolphin emulators
- GameMode + MangoHUD + performance tools
- KDE Plasma with gaming-optimized dark theme
- System kernel tuning for low-latency gaming
- Resource limits optimized for heavy gaming workloads
- Comprehensive documentation

All core configuration is in place. Next step: Build and test!
