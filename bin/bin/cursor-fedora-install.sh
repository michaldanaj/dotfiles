#!/bin/bash

# Paths for installation
INST_DIR=$HOME/opt/cursor
DESKTOP_ENTRY_PATH="$HOME/.local/share/applications/cursor.desktop"

APPIMAGE_PATH="$INST_DIR/cursor.appimage"
ICON_PATH="$INST_DIR/cursor.png"

# URLs for Cursor AppImage and Icon
CURSOR_URL="https://downloads.cursor.com/production/53b99ce608cba35127ae3a050c1738a959750865/linux/x64/Cursor-1.0.0-x86_64.AppImage"
ICON_URL="https://registry.npmmirror.com/@lobehub/icons-static-png/latest/files/dark/cursor.png"

if ! [ -f $APPIMAGE_PATH ]; then
echo "Installing Cursor AI IDE..."

    # Create dir if not exists
    if [ ! -d "$INST_DIR" ]; then
        mkdir -p "$INST_DIR"
    fi
        
    # Install curl if not installed
    if ! command -v curl &> /dev/null; then
        echo "curl is not installed. Installing..."
        sudo dnf install -y curl
    fi

    # Download Cursor AppImage
    echo "Downloading Cursor AppImage..."
    curl -L $CURSOR_URL -o $APPIMAGE_PATH
    chmod +x $APPIMAGE_PATH

    # Download Cursor icon
    echo "Downloading Cursor icon..."
    curl -L $ICON_URL -o $ICON_PATH

    # Create a .desktop entry for Cursor
    echo "Creating .desktop entry for Cursor..."
    bash -c "cat > $DESKTOP_ENTRY_PATH" <<EOL
[Desktop Entry]
Name=Cursor AI IDE
Exec=$APPIMAGE_PATH --no-sandbox
Icon=$ICON_PATH
Type=Application
Categories=Development;
EOL

    echo "Adding cursor alias to .bashrc..."
    bash -c "cat >> $HOME/.local/bin/cursor" <<EOL

#!/bin/bash
$APPIMAGE_PATH --no-sandbox "${@}" > /dev/null 2>&1 & disown
EOL

    echo "Cursor AI IDE installation complete. You can find it in your application menu."
else
    echo "Cursor AI IDE is already installed."
fi

