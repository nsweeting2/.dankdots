#!/bin/bash

# setup.sh - Post-install setup for Fedora + DankMaterialShell/Hyprland
# Author: nsweeting2

# =============================================================================
# FEDORA | DMS | HYPRLAND : SETUP OUTLINE
# =============================================================================

# --- System Prep -------------------------------------------------------------
# [X] Install Fedora
# [ ] Set a hostname
# [ ] Confirm Timezone & locale are configured
# [ ] Enable RPM Fusion repos free and non-free
# [ ] Enable Flathub for flapaks
# [ ] Run DNF update

# --- Hyprland + Wayland Stack ----
# [ ] Add hyprland COPR repo
# [ ] Install hyprland
# [ ] Install kitty & ghostty
# [ ] Install xdg-desktop-portal-hyprland
# [ ] Install hyprpm dependancies

# --- DankMaterialShell Setup ----
# [ ] DankLinux COPR repos added
# [ ] Install DankMaterialShell

# [ ] DMS systemd user service enabled
# [ ] DMS settings.json copied in
# [ ] Hyprland config files copied in
# [ ] DMS Hyprland config files copied in



# --- Fonts & Theming ---------------------------------------------------------
# [ ] Nerd Font installed
# [ ] Font cache refreshed
# [ ] GTK & Qt colors via DMS + matugen
# [ ] Icon theme set
# [ ] Cursor theme set
# [ ] Qt env vars set if needed

# --- Terminal & Shell --------------------------------------------------------
# [ ] Terminal emulator installed
# [ ] Default shell set
# [ ] Shell framework configured
# [ ] Prompt configured
# [ ] tmux / zellij configured
# [ ] Core CLI tools installed
# [ ] Editor configured

# --- Applications ------------------------------------------------------------
# [ ] Web browser installed
# [ ] File manager installed
# [ ] Screenshots via DMS
# [ ] Clipboard via DMS
# [ ] Notifications via DMS
# [ ] Image viewer installed
# [ ] Media player installed
# [ ] Office / productivity apps installed
# [ ] Flatpak permissions reviewed

# --- Development -------------------------------------------------------------
# [ ] Git configured
# [ ] SSH key added to GitHub / GitLab
# [ ] Language runtimes installed
# [ ] Container tooling installed
# [ ] Editor extensions installed
# [ ] Dotfiles repo cloned & symlinked

# --- Security & Maintenance --------------------------------------------------
# [ ] LUKS disk encryption set up
# [ ] sudo / polkit rules reviewed
# [ ] DNF auto-updates configured
# [ ] Snapshots configured
# [ ] BTRFS subvolume layout clean
# [ ] Flatpak permissions reviewed
# [ ] Swap / zram configured

# --- QoL & Polish ------------------------------------------------------------
# [ ] Power management configured
# [ ] Bluetooth configured
# [ ] Printer / scanner set up
# [ ] USB auto-mount working
# [ ] Polkit agent running
# [ ] System tray working
# [ ] Keyboard layout & repeat rate set
# [ ] Touchpad gestures configured
# [ ] Night light configured
# [ ] Dotfiles backed up
# [ ] dgop.desktop
# [ ] bash completion and blesh


# =============================================================================

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

# [ ] Confirm Timezone & locale are configured
current_tz=$(timedatectl show --property=Timezone --value)
read -r -p "    Timezone [${BOLD}$current_tz${RESET}]: " new_tz
if [[ -n "$new_tz" ]]; then
    if timedatectl list-timezones | grep -qx "$new_tz"; then
        sudo timedatectl set-timezone "$new_tz"
        info "Timezone set to $new_tz"
    else
        sudo timedatectl set-timezone "America/New_York"
        issue "Invalid timezone — defaulting to America/New_York"
    fi
else
    info "Timezone kept as $current_tz"
fi

current_locale=$(localectl show --property=LANG --value)
read -r -p "    Locale [${BOLD}$current_locale${RESET}]: " new_locale
if [[ -n "$new_locale" ]]; then
    if localectl list-locales | grep -qx "$new_locale"; then
        sudo localectl set-locale LANG="$new_locale"
        info "Locale set to $new_locale"
    else
        sudo localectl set-locale LANG="en_US.UTF-8"
        issue "Invalid locale — defaulting to en_US.UTF-8"
    fi
else
    info "Locale kept as $current_locale"
fi

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

info " --- Hyprland + Wayland Stack ---- "

# [ ] Add hyprland COPR repo
sudo dnf copr enable -y sdegler/hyprland

# [ ] Install hyprland
sudo dnf install -y hyprland

# [ ] Install kitty & ghostty
sudo dnf install -y kitty ghostty

# [ ] Install xdg-desktop-portal-hyprland
sudo dnf install -y xdg-desktop-portal-hyprland

# [ ] Install hyprpm dependancies
sudo dnf install cmake cpio meson gcc-c++ hyprland-devel wayland-devel wayland-protocols-devel libinput-devel libicu-devel

success " --- Hyprland + Wayland Stack Installed --- "

info " --- DankMaterialShell Setup ---- "

exit 0  #Debug Exit




# --- DankMaterialShell ---
step "Installing DankMaterialShell"

sudo dnf copr enable -y avengemedia/dms
sudo dnf copr enable -y avengemedia/danklinux


sudo dnf install -y dms

sudo dnf install -y ghostty


dms setup --compositor hyprland

sudo dnf install -y dms-greeter
dms greeter enable

systemctl --user enable dms
success "DankMaterialShell installed"

# --- DNF packages ---
step "Installing additional dnf packages"
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
