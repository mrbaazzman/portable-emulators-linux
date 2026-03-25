# 🎮 Emulator Setup Scripts

> **Vibe-coded** — these scripts were written with AI assistance. They work great, but read them before running if you're the cautious type.

A collection of Bash scripts that install, configure, and keep up-to-date the best Linux emulators — all in a clean, portable way under `~/Emulators/`.

Each script:
- Checks for updates automatically (safe to re-run anytime)
- Installs the emulator as an AppImage or portable binary under `~/Emulators/<Name>/`
- Symlinks the config/data folder so everything stays in one place
- Creates a desktop entry under an **Emulators** category in your app launcher
- Works on KDE, GNOME, XFCE, and most other desktop environments

---

## 📦 Emulators Included

| Script | Emulator | System |
|---|---|---|
| `dolphin_setup.sh` | [Dolphin](https://dolphin-emu.org/) | Nintendo GameCube / Wii |
| `duckstation_setup.sh` | [DuckStation](https://github.com/stenzek/duckstation) | Sony PlayStation 1 |
| `eden_setup.sh` | [Eden](https://git.eden-emu.dev/eden-emu/eden) | Nintendo Switch |
| `pcsx2_setup.sh` | [PCSX2](https://pcsx2.net/) | Sony PlayStation 2 |
| `ppsspp_setup.sh` | [PPSSPP](https://www.ppsspp.org/) | Sony PlayStation Portable |
| `rpcs3_setup.sh` | [RPCS3](https://rpcs3.net/) | Sony PlayStation 3 |
| `shadps4_setup.sh` | [shadPS4](https://shadps4.net/) | Sony PlayStation 4 |
| `xemu_setup.sh` | [Xemu](https://xemu.app/) | Microsoft Xbox (OG) |
| `xenia_setup.sh` | [Xenia Canary](https://github.com/xenia-canary/xenia-canary) | Microsoft Xbox 360 |

---

## 🖥️ Requirements

- Linux x86_64
- `bash`, `curl`, `python3` (available on virtually every distro by default)
- `unzip` (for shadPS4 only)

---

## 🚀 Usage

### Run a single script

```bash
chmod +x dolphin_setup.sh
./dolphin_setup.sh
```

If you run it from a file manager or without a terminal, it will automatically open one for you.

### Update an emulator

Just run the same script again — it checks the installed version against the latest release and skips the download if already up to date.

---

## 📁 File Structure

After installation, your home directory will look like this:

```
~/Emulators/
├── Dolphin/
│   ├── Dolphin-*.AppImage
│   └── version.txt
├── DuckStation/
│   ├── DuckStation-x64.AppImage
│   └── version.txt
├── ...
```

Each emulator's config and save data lives inside its own `~/Emulators/<Name>/` folder. A symlink is created at the path the emulator normally uses (e.g. `~/.config/PCSX2`) pointing there, so the emulator doesn't know the difference.

---

## ⚠️ Notes

- **Dolphin** uses an [unofficial AppImage by pkgforge-dev](https://github.com/pkgforge-dev/Dolphin-emu-AppImage) that tracks official releases, since the official repo doesn't publish AppImages directly.
- **DuckStation** uses a rolling `latest` tag — the version is tracked by release date.
- **Xenia Canary** is a **Windows-first** emulator. The Linux build is experimental and may not run all games.
- **shadPS4** is early in development — expect limited game compatibility.
- ROMs, BIOSes, and firmware files are **not included** and must be sourced legally.

---

## 📄 License

MIT — see [LICENSE](LICENSE) for details.
