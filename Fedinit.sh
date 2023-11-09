#!/bin/bash
# Add dnf config modifications to config file
echo -e 'max_parallel_downloads=20\ndefaultyes=True' | sudo tee -a /etc/dnf/dnf.conf &&
# Change hostname
echo 'Sitara' | sudo tee /etc/hostname
# Add Vim as default Text Editor by editing user bashrc
echo -e "export VISUAL=/usr/bin/vim\nexport EDITOR=/usr/bin/vim" | sudo tee -a ~/.bashrc
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
sudo dnf install -y VirtualBox steam lutris wine protontricks tldr powertop htop gnome-tweaks wine neofetch vim timeshift cmatrix nss-tools pcsc-lite perl-pcsc pcsc-tools ccid opensc openrgb steam-devices &&
# install flatpak applications
flatpak install -y flathub org.libreoffice.LibreOffice io.github.realmazharhussain.GdmSettings com.github.avojak.warble org.gnome.Aisleriot org.gnome.Mines org.gnome.Chess org.gnome.SoundRecorder org.videolan.VLC flathub com.github.tchx84.Flatseal flathub org.standardnotes.standardnotes com.mattjakeman.ExtensionManager net.davidotek.pupgui2 com.spotify.Client org.gnome.FontManager org.qbittorrent.qBittorrent io.github.aandrew_me.ytdn com.obsproject.Studio &&
# Remove unwanted graphical RPM applications
sudo dnf remove -y gnome-boxes gnome-extensions-app libreoffice*  
# Add user to vboxusers group to enable usb passthrough in VirtualBox
sudo usermod -aG vboxusers $USER
# perform a dnf update
sudo dnf update -y &&
# Add gnome shell extensions
sudo dnf install -y gnome-shell-extension-caffeine gnome-shell-extension-appindicator
# Create a hidden vimrc file and enable line number indicators in Vim
touch .vimrc
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

