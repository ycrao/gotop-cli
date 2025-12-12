#!/bin/bash
# DDL to Object Installer
# curl -fsSL https://raw.githubusercontent.com/ycrao/gotop-cli/main/install.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Config
REPO="ycrao/gotop-cli"
INSTALL_DIR="$HOME/.local/bin"

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Detect platform
detect_platform() {
    local os arch
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    arch=$(uname -m)
    
    case "$os" in
        linux*) PLATFORM="linux" ;;
        darwin*) 
            PLATFORM="mac"
            [ "$arch" = "arm64" ] && PLATFORM="mac-arm64"
            ;;
        *) error "Unsupported OS: $os" ;;
    esac
    
    info "Detected platform: $PLATFORM"
}

# Get latest release
get_latest_release() {
    info "Fetching latest release..."
    
    local api_url="https://api.github.com/repos/${REPO}/releases/latest"
    local release_info
    
    release_info=$(curl -fsSL "$api_url") || error "Failed to fetch release info"
    VERSION=$(echo "$release_info" | grep '"tag_name"' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')
    
    [ -z "$VERSION" ] && error "Failed to parse version"
    
    DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/gotop-${PLATFORM}-${VERSION}.tar.gz"
    
    info "Latest version: $VERSION"
}

# Install
install() {
    info "Installing gotop-cli..."

    # Download and extract
    local temp_dir
    temp_dir=$(mktemp -d)
    trap "rm -rf '$temp_dir'" EXIT
    
    info "Downloading from GitHub..."
    curl -fsSL -o "$temp_dir/release.tar.gz" "$DOWNLOAD_URL" || error "Download failed"
    
    tar -xzf "$temp_dir/release.tar.gz" -C "$temp_dir"
    
    # Install files
    local src_dir="$temp_dir/$PLATFORM"
    [ ! -d "$src_dir" ] && error "Invalid archive structure"
    
    # Binary
    cp "$src_dir/gotop" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/gotop"
    success "Binary installed: $INSTALL_DIR/gotop"
}

# Update PATH
update_path() {
    # Check if already in PATH
    [[ ":$PATH:" == *":$INSTALL_DIR:"* ]] && return
    
    # Add to shell configs
    for config in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
        if [ -f "$config" ] && ! grep -q "$INSTALL_DIR" "$config"; then
            echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$config"
            success "Updated $(basename "$config")"
        fi
    done
    
    warn "Please reload your shell: source ~/.bashrc or source ~/.zshrc or source ~/.profile"
}

# Main
main() {
    echo "🚀 GOTOP CLI Installer"
    echo "=========================="
    
    # Check dependencies
    for cmd in curl tar; do
        command -v "$cmd" >/dev/null || error "$cmd is required but not installed"
    done
    
    detect_platform
    get_latest_release
    install
    update_path
    
    echo
    success "Installation completed!"
    echo
    echo "Usage:"
    echo "  gotop -v"
    echo "  gotop -h"
    echo "  gotop -p sina -s xag"
    echo
    echo "Documentation: https://github.com/$REPO"
}

main "$@"