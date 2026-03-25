#!/bin/bash

# ── If not running in a terminal, relaunch in one ────────────────────────────
if [ ! -t 1 ]; then
    SCRIPT="$(realpath "$0")"
    if command -v konsole &>/dev/null; then
        konsole -e bash -c "$SCRIPT"
    elif command -v gnome-terminal &>/dev/null; then
        gnome-terminal -- bash -c "$SCRIPT; exec bash"
    elif command -v xfce4-terminal &>/dev/null; then
        xfce4-terminal --hold -e "bash -c '$SCRIPT'"
    elif command -v kitty &>/dev/null; then
        kitty bash -c "$SCRIPT; exec bash"
    elif command -v alacritty &>/dev/null; then
        alacritty -e bash -c "$SCRIPT; exec bash"
    elif command -v xterm &>/dev/null; then
        xterm -hold -e bash -c "$SCRIPT"
    else
        echo "❌ No terminal emulator found. Please run this script from a terminal."
        exit 1
    fi
    exit
fi

# ── Variables ─────────────────────────────────────────────────────────────────
# Eden uses a Gitea instance — API is compatible with GitHub's release format
EMULATOR_NAME="Eden"
INSTALL_DIR="$HOME/Emulators/$EMULATOR_NAME"
VERSION_FILE="$INSTALL_DIR/version.txt"
ICON_DIR="$HOME/.local/share/icons"
DESKTOP_DIR="$HOME/.local/share/applications"
DIR_DIR="$HOME/.local/share/desktop-directories"
MENU_DIR="$HOME/.config/menus/applications-merged"
LINK="$HOME/.local/share/eden"
API_URL="https://git.eden-emu.dev/api/v1/repos/eden-emu/eden/releases?limit=5"
ICON_URL="https://git.eden-emu.dev/eden-emu/eden/raw/branch/master/dist/dev.eden_emu.eden.svg"
ICON_FALLBACK_URL="https://raw.githubusercontent.com/eden-emulator/eden-emulator.github.io/main/public/icon.svg"
DESKTOP_FILE="$DESKTOP_DIR/eden.desktop"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "          Eden (Switch) Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── Step 1: Fetch latest release info from Gitea ──────────────────────────────
echo "🔍 Fetching latest release info..."

RELEASE_JSON=$(curl -s "$API_URL")

LATEST_VERSION=$(echo "$RELEASE_JSON" | python3 -c "
import sys, json
releases = json.load(sys.stdin)
for r in releases:
    tag = r.get('tag_name', '').strip()
    if tag:
        print(tag)
        sys.exit()
")

# Target: Linux amd64 GCC standard AppImage
DOWNLOAD_URL=$(echo "$RELEASE_JSON" | python3 -c "
import sys, json
releases = json.load(sys.stdin)
for r in releases:
    for a in r.get('assets', []):
        name = a['name'].lower()
        if name.endswith('.appimage') and 'linux' in name and 'gcc' in name and 'amd64' in name:
            print(a['browser_download_url'])
            sys.exit()
")

if [ -z "$LATEST_VERSION" ] || [ -z "$DOWNLOAD_URL" ]; then
    echo "❌ Could not fetch release info. Check your internet connection and try again."
    sleep 10
    exit 1
fi

echo "🏷️  Latest version: $LATEST_VERSION"

# ── Step 2: Compare with installed version ────────────────────────────────────
NEEDS_DOWNLOAD=true

if [ -f "$VERSION_FILE" ]; then
    INSTALLED_VERSION=$(cat "$VERSION_FILE" | tr -d '[:space:]')
    echo "📦 Installed version: $INSTALLED_VERSION"

    if [ "$INSTALLED_VERSION" = "$LATEST_VERSION" ]; then
        echo "✅ Already up to date. Skipping download."
        NEEDS_DOWNLOAD=false
    else
        echo "🔄 Update available ($INSTALLED_VERSION → $LATEST_VERSION). Updating..."
    fi
else
    echo "🆕 No existing installation found. Installing..."
    mkdir -p "$INSTALL_DIR"
fi

# ── Step 3: Download if needed ────────────────────────────────────────────────
if [ "$NEEDS_DOWNLOAD" = true ]; then
    APPIMAGE_NAME=$(basename "$DOWNLOAD_URL" | cut -d'?' -f1)
    echo ""
    echo "📥 Downloading $APPIMAGE_NAME..."

    # Remove old AppImage
    find "$INSTALL_DIR" -maxdepth 1 -type f -name "Eden*.AppImage" -delete

    curl -L "$DOWNLOAD_URL" -o "$INSTALL_DIR/$APPIMAGE_NAME"

    if [ $? -ne 0 ]; then
        echo "❌ Download failed."
        sleep 10
        exit 1
    fi

    chmod +x "$INSTALL_DIR/$APPIMAGE_NAME"

    # Save the new version
    echo "$LATEST_VERSION" > "$VERSION_FILE"
    echo "✅ Version $LATEST_VERSION saved to version.txt"
else
    # Find existing AppImage for desktop entry
    APPIMAGE_NAME=$(find "$INSTALL_DIR" -maxdepth 1 -type f -name "Eden*.AppImage" | head -n1 | xargs basename)
fi

# ── Step 4: Verify AppImage exists ───────────────────────────────────────────
if [ -z "$APPIMAGE_NAME" ]; then
    echo "❌ Could not find Eden AppImage in $INSTALL_DIR."
    sleep 10
    exit 1
fi

echo "✅ AppImage: $APPIMAGE_NAME"

# ── Step 5: Symlink config folder ─────────────────────────────────────────────
echo ""
echo "🔗 Linking user data folder..."

if [ -d "$LINK" ] && [ ! -L "$LINK" ]; then
    echo "📦 Existing data found at $LINK, migrating to $INSTALL_DIR..."
    cp -r "$LINK/." "$INSTALL_DIR/"
    rm -rf "$LINK"
fi

mkdir -p "$(dirname "$LINK")"
ln -sfn "$INSTALL_DIR" "$LINK"
echo "✅ $LINK → $INSTALL_DIR"

# ── Step 6: Fetch icon ────────────────────────────────────────────────────────
echo ""
echo "🖼️  Downloading icon..."
mkdir -p "$ICON_DIR"

curl -L --fail --silent "$ICON_URL" -o "$ICON_DIR/eden.svg"
if [ $? -ne 0 ]; then
    echo "⚠️  Primary icon URL failed, trying fallback..."
    curl -L --fail --silent "$ICON_FALLBACK_URL" -o "$ICON_DIR/eden.svg"
    if [ $? -ne 0 ]; then
        echo "⚠️  Icon download failed. The app will still work without it."
    else
        echo "✅ Icon saved (fallback)"
    fi
else
    echo "✅ Icon saved"
fi

# ── Step 7: Create Emulators category if not exists ───────────────────────────
echo ""
echo "📁 Setting up Emulators category..."

mkdir -p "$DIR_DIR" "$MENU_DIR"

cat > "$DIR_DIR/emulators.directory" << EOF
[Desktop Entry]
Type=Directory
Name=Emulators
Icon=applications-games
EOF

cat > "$MENU_DIR/emulators.menu" << EOF
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
  "http://www.freedesktop.org/standards/menu-spec/menu-1.0.dtd">
<Menu>
  <Name>Applications</Name>
  <Menu>
    <Name>Emulators</Name>
    <Directory>emulators.directory</Directory>
    <Include>
      <Category>Emulators</Category>
    </Include>
  </Menu>
</Menu>
EOF

echo "✅ Emulators category ready"

# ── Step 8: Create desktop entry ──────────────────────────────────────────────
echo ""
echo "🖥️  Creating menu entry..."

rm -f "$DESKTOP_DIR"/eden*.desktop
rm -f "$DESKTOP_DIR"/Eden*.desktop

cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Eden
Comment=Nintendo Switch Emulator
Exec=$INSTALL_DIR/$APPIMAGE_NAME
Icon=$ICON_DIR/eden.svg
Type=Application
Categories=Emulators;
Terminal=false
EOF

update-desktop-database "$DESKTOP_DIR" 2>/dev/null
kbuildsycoca6 &>/dev/null || kbuildsycoca5 &>/dev/null || true
echo "✅ Menu entry created under Emulators"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$NEEDS_DOWNLOAD" = true ]; then
    echo "   🎮 Eden $LATEST_VERSION installed!"
else
    echo "   🎮 Eden is already up to date!"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⏳ This window will close in 5 seconds..."
sleep 5
