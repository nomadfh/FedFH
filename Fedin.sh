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
sudo dnf install -y powertop protontricks htop gnome-tweaks wine neofetch vim timeshift cmatrix nss-tools pcsc-lite perl-pcsc pcsc-tools ccid opensc openrgb steam-devices &&
# install flatpak applications
flatpak install -y valvesoftware.Steam net.lutris.Lutris org.videolan.VLC flathub com.github.tchx84.Flatseal flathub org.standardnotes.standardnotes com.mattjakeman.ExtensionManager net.davidotek.pupgui2 com.spotify.Client org.gnome.FontManager org.qbittorrent.qBittorrent flathub org.onlyoffice.desktopeditors io.github.aandrew_me.ytdn &&
# Remove redundant graphical RPM applications
# perform a dnf update
sudo dnf update -y &&
# Install Microsoft Edge from their repositories
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc &&
sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge &&
sudo dnf install microsoft-edge-stable &&
# Create a hidden vimrc file and enable line number indicators in Vim
touch .vimrc &&
echo "set nu" >> .vimrc
# Add fractional scaling support to GNOME
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
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
