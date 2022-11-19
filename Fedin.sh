#!/bin/bash
# Add dnf config modifications to config file
echo -e 'max_parallel_downloads=20\ndefaultyes=True' | sudo tee -a /etc/dnf/dnf.conf &&
# Change hostname
echo -e 'Sitara' | sudo tee /etc/hostname
# Save display configs in gnome display manager settings
sudo cp ~/.config/monitors.xml ~gdm/.config/ &&
# set tap to click on gdm login screen
xhost SI:localuser:gdm
sudo -u gdm gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
# add flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo &&
# add rpm fusion repos
sudo dnf install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm &&
sudo dnf install -y \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm &&
# install rpm applications
sudo dnf install -y vlc htop gnome-tweaks steam wine lutris neofetch vim timeshift cmatrix nss-tools pcsc-lite perl-pcsc pcsc-tools ccid opensc &&
# install flatpak applications
flatpak install -y flathub com.github.tchx84.Flatseal flathub org.standardnotes.standardnotes com.mattjakeman.ExtensionManager net.davidotek.pupgui2 com.spotify.Client org.gnome.FontManager org.gnome.Extensions org.qbittorrent.qBittorrent flathub org.onlyoffice.desktopeditors org.yuzu_emu.yuzu xyz.z3ntu.razergenie &&
# perform a dnf update
sudo dnf update -y &&
# perform a dnf update
sudo dnf update -y &&
# Install yumex-dnf (dnf GUI frontend) from COPR
sudo dnf copr enable timlau/yumex-dnf -y
sudo dnf install yumex-dnf -y &&
# install openrazer dependencies 
sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/hardware:razer/Fedora_36/hardware:razer.repo &&
sudo dnf install -y openrazer-meta &&
sudo dnf install -y openrazer-meta
sudo gpasswd -a $USER plugdev
# update dnf before installing Nvidia propietary drivers using akmod
sudo dnf update --refresh -y &&
sudo dnf install akmod-nvidia -y &&
sudo dnf install xorg-x11-drv-nvidia-cuda -y &&
read -p "Okay to restart? (yes/no) " yn

case $yn in
	yes ) shutdown -r now;;
	no ) echo "standing by";
		exit;;
	* ) echo invalid response;
		exit 1;;
esac
