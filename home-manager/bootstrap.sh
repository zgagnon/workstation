#!/bin/bash

set -e

echo "<� Home Manager Bootstrap Script"
echo "================================"

# Check if Nix is installed
if ! command -v nix &>/dev/null; then
    echo "L Nix is not installed. Please install Nix first."
    echo "Visit: https://nixos.org/download.html"
    exit 1
fi

# Enable flakes if not already enabled
echo "=' Configuring Nix with flakes support..."
mkdir -p ~/.config/nix
if ! grep -q "experimental-features" ~/.config/nix/nix.conf 2>/dev/null; then
    echo "experimental-features = nix-command flakes" >>~/.config/nix/nix.conf
    echo " Enabled experimental Nix features (nix-command flakes)"
else
    echo " Nix flakes already enabled"
fi

# Detect system and user
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ $(uname -m) == "arm64" ]]; then
        SYSTEM="aarch64-darwin"
    else
        SYSTEM="x86_64-darwin"
    fi
else
    SYSTEM="x86_64-linux"
fi

USER=$(whoami)
echo "=�  Detected system: $SYSTEM"
echo "=d User: $USER"

# Determine home configuration
if [[ "$USER" == "zell" ]]; then
    HOME_CONFIG="zell"
elif [[ "$USER" == "coder" ]]; then
    HOME_CONFIG="coder"
else
    echo "L Unknown user '$USER'. This flake supports 'zell' and 'coder' configurations."
    echo "You may need to add a configuration for your user in flake.nix"
    exit 1
fi

echo "<�  Using home configuration: $HOME_CONFIG"

# Get the directory containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "=� Working directory: $SCRIPT_DIR"

# Check for and remove conflicting packages
echo "=🧹 Checking for package conflicts..."
if nix profile list | grep -q "direnv"; then
    echo "  Found conflicting direnv package, removing..."
    nix profile remove direnv
    echo "  ✅ Removed conflicting direnv package"
fi

# Build and activate home-manager configuration
echo "=( Building Home Manager configuration..."
cd "$SCRIPT_DIR"
nix build ".#homeConfigurations.${HOME_CONFIG}.activationPackage"

echo "=� Activating Home Manager configuration..."
./result/activate

echo " Home Manager bootstrap complete!"
echo ""
echo "=� Next steps:"
echo "   Future updates: run 'home-manager switch --flake .' from this directory"
echo "   Edit your configuration in: $SCRIPT_DIR/home.nix"
echo "   Add programs by editing: $SCRIPT_DIR/flake.nix"
echo ""
echo "🎉 Bootstrap complete! The activation script will handle Doom Emacs setup."
