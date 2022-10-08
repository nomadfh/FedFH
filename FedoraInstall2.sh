#/bin/bash
# set default monitor for gdm login screen
sudo cp ~/.config/monitors.xml ~gdm/.config/ &&
# set tap to click on gdm login screen
xhost SI:localuser:gdm
sudo -u gdm gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true &&
# install enable and start touchegg 
sudo dnf copr enable -y joseexposito/touchegg &&
sudo dnf install touchegg &&
sudo systemctl enable -y touchegg.service &&
sudo systemctl start touchegg
# Install System 76 Task Scheduler
sudo dnf copr enable -y mjakeman/system76-scheduler &&
sudo dnf install system76-scheduler
# Install System 76 Pop Shell extension and exclude keyboard shortcut overrides
sudo dnf install -y --setopt=exclude=gnome-shell-extension-pop-shell-shortcut-overrides gnome-shell-extension-pop-shell &&
sudo systemctl start com.system76.Scheduler && systemctl enable com.system76.Scheduler
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
#Download MEGA cloud sync and Nautilus extension
wget https://mega.nz/linux/repo/Fedora_36/x86_64/megasync-Fedora_36.x86_64.rpm && wget https://mega.nz/linux/repo/Fedora_36/x86_64/nautilus-megasync-Fedora_36.x86_64.rpm
# Install MEGA
sudo dnf install -y megasync-* &&
# Install MEGA nautilus extension
sudo dnf install -y nautilus-megasync-*
echo "Good Job! Now install the DOD PKI certificates."
