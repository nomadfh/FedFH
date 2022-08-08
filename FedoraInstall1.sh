#!/bin/bash
# Add dnf config modifications to config file
echo -e 'max_parallel_downloads=20\ndefaultyes=True' | sudo tee -a /etc/dnf/dnf.conf &&
# Change hostname
echo -e 'Sitara' | sudo tee /etc/hostname
# add flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo &&
# add rpm fusion repos
sudo dnf install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm &&
sudo dnf install -y \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm &&
# install rpm applications
sudo dnf install -y vlc htop gnome-tweaks steam wine lutris neofetch vim timeshift cmatrix google-chrome-stable nss-tools pcsc-lite perl-pcsc pcsc-tools ccid opensc &&
# install flatpak applications
flatpak install -y org.standardnotes.standardnotes com.mattjakeman.ExtensionManager net.davidotek.pupgui2 com.spotify.Client org.gnome.FontManager org.gnome.Extensions org.qbittorrent.qBittorrent flathub org.onlyoffice.desktopeditors org.yuzu_emu.yuzu xyz.z3ntu.razergenie &&
#Install Microsoft Edge
## Setup
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge
    sudo mv /etc/yum.repos.d/packages.microsoft.com_yumrepos_edge.repo /etc/yum.repos.d/microsoft-edge-beta.repo
    ## Install
    sudo dnf install microsoft-edge-stable &&
# Install Brave Browser rpm
sudo dnf install dnf-plugins-core

sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/

sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

sudo dnf install brave-browser &&
# download protonvpn-cli from website using wget
wget https://protonvpn.com/download/protonvpn-stable-release-1.0.1-1.noarch.rpm &&
# install protonvpn-cli
sudo dnf install protonvpn-stable-release-1.0.1-1.noarch.rpm -y &&
# perform a dnf update
sudo dnf update -y &&
# install protonvpn-cli
sudo dnf install protonvpn-cli &&
protonvpn-cli login nomadfh &&
rm protonvpn-stable-release-1.0.1-1.noarch.rpm &&
# install openrazer dependencies 
sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/hardware:razer/Fedora_36/hardware:razer.repo &&
sudo dnf install openrazer-meta &&
sudo dnf install openrazer-meta
sudo gpasswd -a $USER plugdev
# update dnf before installing Nvidia propietary drivers using akmod
sudo dnf update --refresh -y &&
sudo dnf install akmod-nvidia -y &&
sudo dnf install xorg-x11-drv-nvidia-cuda -y &&
shutdown -r now
