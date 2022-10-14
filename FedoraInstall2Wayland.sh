/bin/bash
# set default monitor for gdm login screen
sudo cp ~/.config/monitors.xml ~gdm/.config/ &&
# set tap to click on gdm login screen
xhost SI:localuser:gdm
sudo -u gdm gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true &&
# Install System 76 Pop Shell extension and exclude keyboard shortcut overrides
sudo dnf install -y --setopt=exclude=gnome-shell-extension-pop-shell-shortcut-overrides gnome-shell-extension-pop-shell &&
# Install tlp and start tlp service
sudo dnf install tlp tlp-rdw &&
sudo systemctl enable tlp.service &&
sudo systemctl start tlp.service
# Add some popular gnome-shell extensions
sudo dnf install -y gnome-shell-extension-caffeine.noarch gnome-shell-extension-appindicator.noarch gnome-shell-extension-sound-output-device-chooser.noarch gnome-shell-extension-user-theme.noarch &&
# Download virtualbox using wget
wget https://download.virtualbox.org/virtualbox/6.1.38/VirtualBox-6.1-6.1.38_153438_fedora36-1.x86_64.rpm &&
# Install virtualbox
sudo dnf install -y VirtualBox-*
# Download virtualbox extension pack
wget https://download.virtualbox.org/virtualbox/6.1.38/Oracle_VM_VirtualBox_Extension_Pack-6.1.38.vbox-extpack &&
# Add user to vboxusers group to enable usb passthrough
sudo usermod -a -G vboxusers $USER
read -p "Okay to restart? (yes/no) " yn

case $yn in
        yes ) shutdown -r now;;
        no ) echo "standing by";
                exit;;
        * ) echo invalid response;
                exit 1;;
esac	
