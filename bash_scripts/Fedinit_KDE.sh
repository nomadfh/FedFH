#!/bin/bash
# Add dnf config modifications to config file
echo -e 'max_parallel_downloads=20\ndefaultyes=True' | sudo tee -a /etc/dnf/dnf.conf &&

# Change hostname
echo "Name your computer"
read hostname
echo $hostname | sudo tee /etc/hostname &&
echo "Your hostname will change to $hostname after a reboot" &&
sleep 3 &&

# Add Vim as default Text Editor by editing user bashrc
echo -e "export VISUAL=/usr/bin/vim\nexport EDITOR=/usr/bin/vim" | tee -a ~/.bashrc &&

# copy default pipewire configuration to system for custom configurations
sudo cp -r /usr/share/pipewire /etc &&
echo copied pipewire config to etc directory &&
# Create custom pipewire configuration file in pipewire.conf.d directory
sudo tee /etc/pipewire/pipewire.conf.d/pipewire_modifications.conf > /dev/null << EOF
# Configuration properties for Pipewire
context.properties = {
    default.clock.quantum       = 2048
    default.clock.min-quantum   = 2048
}
EOF

echo "Pipewire configuration has been copied and modified successfully." &&


# Add flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo &&

# Add rpm fusion repos
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm &&
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm &&

# Install rpm applications
sudo dnf install -y VirtualBox tldr powertop htop fastfetch vim timeshift cmatrix nss-tools pcsc-lite perl-pcsc pcsc-tools ccid opensc openrgb steam-devices &&

# Install multimedia codecs
# sudo dnf group install -y --allowerasing Multimedia &&

# Install flatpak applications
flatpak install -y flathub org.libreoffice.LibreOffice com.github.avojak.warble org.videolan.VLC flathub com.github.tchx84.Flatseal flathub org.standardnotes.standardnotes net.davidotek.pupgui2 com.spotify.Client org.qbittorrent.qBittorrent io.github.aandrew_me.ytdn com.obsproject.Studio &&

# Remove unwanted graphical RPM applications
sudo dnf remove -y libreoffice* &&

# Add user to vboxusers group to enable usb passthrough in VirtualBox
sudo usermod -aG vboxusers $USER &&

# Perform a dnf update
sudo dnf update -y &&

# Create a hidden vimrc file and enable line number indicators in Vim
touch ~/.vimrc &&

# Read user input to restart the system
read -p "Okay to restart? (yes/no) " yn

case $yn in
        yes ) sudo shutdown -r now;;
        no ) echo "Standing by";;
        * ) echo "Invalid response"; exit 1;;
esac

