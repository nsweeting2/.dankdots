#!/bin/bash

# setup.sh - Post-install setup for Fedora|DankMaterialShell|Hyprland
# Author: nsweeting2

# ============== #
# SETUP OUTLINE  #
# ============== #

# --- System Prep ---
# [X] Install Fedora
# [ ] Set a hostname
# [ ] Enable RPM Fusion repos free and non-free
# [ ] Enable Flathub for flapaks
# [ ] Run DNF update

# --- Hyprland + Wayland Stack ----
# [ ] Add hyprland COPR repo
# [ ] Install hyprland
# [ ] Add ghostty COPR repo
# [ ] Install kitty & ghostty
# [ ] Install xdg-desktop-portal-hyprland
# [ ] Install hyprpm dependancies

# --- DankMaterialShell Setup ----
# [ ] Add DankLinux COPR repos
# [ ] Install DankMaterialShell
# [ ] Enable dms as a systemd user service
# [ ] Install dms-greeter
# [ ] Enable dms-greeter with dms-cli
# [ ] DMS settings.json copied in

# --- Terminal & Shell ---
# [ ] Confirm we have kitty & ghostty
# [ ] Install bash-completion & blesh
# [ ] Install zfz, bat, ripgrep, eza
# [ ] Add alaiases to .bashrc

# --- Applications ----
# [ ] Install with DNF
#  -  btop
#  -  freerdp
#  -  btrfs-assistant
# [ ] Install Flatpaks
#  -  com.github.tchx84.Flatseal
#  -  com.brave.Browser
#  -  us.zoom.Zoom
#  -  com.devolutions.remotedesktopmanager
#  -  org.gnome.World.PikaBackup
#  -  com.vscodium.codium

# --- Security & Maintenance ---
# [ ] sudo / polkit rules reviewed
# [ ] DNF auto-updates configured
# [ ] Snapshots configured

# --- Misc Configuration ---
# [ ] My hypr/hyprland.conf file copied in
# [ ] My hypr/dms/*.conf files copied in


# --- Exit if we error on anything ---
set -e

# --- Terminal formatting ---
BOLD=$(tput bold 2>/dev/null || true)
RESET=$(tput sgr0 2>/dev/null || true)
GREEN=$(tput setaf 2 2>/dev/null || true)
YELLOW=$(tput setaf 3 2>/dev/null || true)
CYAN=$(tput setaf 6 2>/dev/null || true)

# --- Functions for colorful output. ---
step() {
    echo ""
    echo "${BOLD}${GREEN}==>${RESET}${BOLD} $1${RESET}"
}

info() {
    echo "    ${CYAN}·${RESET} $1"
}

issue() {
    echo "    ${YELLOW}·${RESET} $1"
}

success() {
    echo "    ${GREEN}✓${RESET} $1"
}

# ---
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Grab sudo upfront and keep it alive for the duration of the script ---
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

step "Beginning setup.sh script"

info " ---- System Prep ---- "

# [ ] Set a hostname
while true; do
    read -r -p "    Enter hostname (lowercase only): " hostname
    if [[ "$hostname" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
        break
    fi
    issue "Hostname must be lowercase letters, numbers, and hyphens only."
done
sudo hostnamectl set-hostname "$hostname"
info "Hostname set to $hostname"


# [ ] Enable RPM Fusion repos free and nonfree
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

# [ ] Enable Flathub for flapaks
if ! flatpak remotes | grep -q flathub; then
    info "Enabling Flathub..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    success "Flathub enabled"
else
    success "Flathub already enabled"
fi

# [ ] Run DNF update
step "Upgrading system packages"
sudo dnf upgrade -y

success " --- System Prep Complete --- "

# exit 0  # Debug Exit
info " --- Hyprland + Wayland Stack ---- "

# [ ] Add hyprland COPR repo
sudo dnf copr enable -y sdegler/hyprland

# [ ] Install hyprland
sudo dnf install -y hyprland

# [ ] Add ghostty COPR repo
sudo dnf copr enable -y scottames/ghostty

# [ ] Install kitty & ghostty
sudo dnf install -y kitty ghostty

# [ ] Install xdg-desktop-portal-hyprland
sudo dnf install -y xdg-desktop-portal-hyprland

# [ ] Install hyprpm dependancies
sudo dnf install -y cmake cpio meson gcc-c++ hyprland-devel wayland-devel wayland-protocols-devel libinput-devel libicu-devel

success " --- Hyprland + Wayland Stack Installed --- "

# exit 0  # Debug Exit
info " --- DankMaterialShell Setup ---- "

# [ ] Add DankLinux COPR repos
sudo dnf copr enable -y avengemedia/dms
sudo dnf copr enable -y avengemedia/danklinux

# [ ] Install DankMaterialShell
sudo dnf install -y dms

# [ ] Enable dms as a systemd user service
systemctl --user enable dms

# [ ] Install dms-greeter
sudo dnf install -y dms-greeter

# [ ] Enable dms-greeter with dms-cli
dms greeter enable

success " --- DankMaterialShell Setup Complete --- "

# exit 0  # Debug Exit
info " --- Terminal & Shell ---- "

# [ ] Confirm we have kitty ghostty &
sudo dnf install -y kitty ghostty

# [ ] Install bash-completion & blesh
sudo dnf install -y bash-completion blesh

# [ ] Install fzf, bat, ripgrep, eza
sudo dnf install -y fzf bat ripgrep eza

# [ ] Add alias' to .bashrc
declare -A aliases=(
    ["ls"]="eza --icons --group-directories-first"
    ["ll"]="eza -lbhF --git --icons --group-directories-first"
    ["la"]="eza -abgh --icons --group-directories-first"
    ["tree"]="eza --tree --icons"
    ["cat"]="bat --style=plain --paging=never"
    ["grep"]="rg"
    ["rm"]="rm -i"
)

for name in "${!aliases[@]}"; do
    if ! grep -q "alias ${name}=" ~/.bashrc; then
        echo "alias ${name}='${aliases[$name]}'" >> ~/.bashrc
        info "Added alias: ${name}='${aliases[$name]}'"
    else
        info "Alias already set: ${name}"
    fi
done

info " --- Terminal & Shell Configured ---- "

# exit 0  # Debug Exit
info " --- Applications ---- "





# --- DNF packages ---
step "Installing additional dnf packages"
sudo dnf install -y \
    btop \
    freerdp \
    btrfs-assistant \
success "dnf packages installed"

# --- Flatpak apps ---
step "Installing flatpaks"
flatpak install -y flathub com.github.tchx84.Flatseal
flatpak install -y flathub com.brave.Browser
flatpak install -y flathub us.zoom.Zoom
flatpak install -y flathub com.devolutions.remotedesktopmanager
flatpak install -y flathub org.gnome.World.PikaBackup
flatpak install -y flathub com.vscodium.codium
success "Flatpak apps installed"

# --- Copy dotfiles ---
step "Copying dotfiles"

mkdir -p ~/.config/DankMaterialShell
cp "$DOTFILES_DIR/.config/DankMaterialShell/settings.json" \
    ~/.config/DankMaterialShell/settings.json
info "Copied ~/.config/DankMaterialShell/settings.json"

mkdir -p ~/.config/hypr/dms
cp "$DOTFILES_DIR/.config/hypr/hyprland.conf" \
    ~/.config/hypr/hyprland.conf
info "Copied ~/.config/hypr/hyprland.conf"

for conf in "$DOTFILES_DIR/.config/hypr/dms/"*.conf; do
    cp "$conf" ~/.config/hypr/dms/"$(basename "$conf")"
    info "Copied ~/.config/hypr/dms/$(basename "$conf")"
done

success "Dotfiles copied"

echo ""
echo "${BOLD}${GREEN}  ✓  Setup complete.${RESET}"
echo ""
read -r -p "    Reboot now? (N/y, default: N): " response
response=${response:-N}
if [[ "${response,,}" == "y" ]]; then
    sudo reboot
fi
