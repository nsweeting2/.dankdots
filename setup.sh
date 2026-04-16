#!/bin/bash

# setup.sh - Post-install setup for Fedora + DankMaterialShell/Hyprland
# Author: nsweeting2

#####
# This script is intended to be run once after a fresh Fedora install.
# It installs DankMaterialShell (Hyprland + Ghostty via the DankLinux
# installer), upgrades the system, installs development dependencies and
# applications via dnf and flatpak, and symlinks dotfiles from this repo
# into their expected config locations.
#####

set -e

# --- Terminal formatting ---
BOLD=$(tput bold 2>/dev/null || true)
RESET=$(tput sgr0 2>/dev/null || true)
GREEN=$(tput setaf 2 2>/dev/null || true)
YELLOW=$(tput setaf 3 2>/dev/null || true)
CYAN=$(tput setaf 6 2>/dev/null || true)

step() {
    echo ""
    echo "${BOLD}${GREEN}==>${RESET}${BOLD} $1${RESET}"
}

info() {
    echo "    ${CYAN}·${RESET} $1"
}

success() {
    echo "    ${GREEN}✓${RESET} $1"
}

# --- Banner ---
echo ""
echo "${BOLD}${GREEN}  ·  dankdots${RESET}"
echo "${YELLOW}     Fedora · DankMaterialShell · Hyprland${RESET}"
echo ""

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- DankMaterialShell ---
step "Installing DankMaterialShell"
info "Compositor: Hyprland  |  Terminal: Ghostty"
curl -fsSL https://install.danklinux.com -o /tmp/dms_install.sh
COMPOSITOR=hyprland TERMINAL=ghostty sh /tmp/dms_install.sh
rm -f /tmp/dms_install.sh
success "DankMaterialShell installed"

# --- Third-party repositories ---
step "Checking third-party repositories"

if ! flatpak remotes | grep -q flathub; then
    info "Enabling Flathub..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    success "Flathub enabled"
else
    success "Flathub already enabled"
fi

if ! rpm -q rpmfusion-free-release &>/dev/null; then
    info "Enabling RPM Fusion Free..."
    sudo dnf install -y "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
    success "RPM Fusion Free enabled"
else
    success "RPM Fusion Free already enabled"
fi

if ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
    info "Enabling RPM Fusion Nonfree..."
    sudo dnf install -y "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
    success "RPM Fusion Nonfree enabled"
else
    success "RPM Fusion Nonfree already enabled"
fi

# --- System upgrade ---
step "Upgrading system packages"
sudo dnf upgrade -y
success "System up to date"

# --- DNF packages ---
step "Installing dnf packages"
sudo dnf install -y \
    btop \
    cmake \
    cpio \
    meson \
    gcc-c++ \
    hyprland-devel \
    wayland-devel \
    wayland-protocols-devel \
    libinput-devel \
    libicu-devel \
    freerdp \
    btrfs-assistant
success "dnf packages installed"

# --- Flatpak apps ---
step "Installing flatpak apps"
flatpak install -y flathub com.github.tchx84.Flatseal
flatpak install -y flathub com.brave.Browser
flatpak install -y flathub us.zoom.Zoom
flatpak install -y flathub com.devolutions.RDM
flatpak install -y flathub org.gnome.World.PikaBackup
flatpak install -y flathub com.vscodium.codium
success "Flatpak apps installed"

# --- Symlink dotfiles ---
step "Symlinking dotfiles"
mkdir -p ~/.config/DankMaterialShell
ln -sf "$DOTFILES_DIR/dotfiles/config/DankMaterialShell/settings.json" \
    ~/.config/DankMaterialShell/settings.json
info "DankMaterialShell settings → ~/.config/DankMaterialShell/settings.json"

mkdir -p ~/.config/hypr
ln -sf "$DOTFILES_DIR/dotfiles/config/hypr/hyprland.conf" \
    ~/.config/hypr/hyprland.conf
info "Hyprland config    → ~/.config/hypr/hyprland.conf"
success "Dotfiles symlinked"

# --- Wallpapers ---
step "Copying wallpapers"
mkdir -p ~/Wallpapers
cp -rp "$DOTFILES_DIR/Wallpapers/"* ~/Wallpapers/
success "Wallpapers copied to ~/Wallpapers"

echo ""
echo "${BOLD}${GREEN}  ✓  Setup complete. Reboot when ready.${RESET}"
echo ""
