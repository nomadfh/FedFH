#/bin/bash
# set default monitor for gdm login screen
sudo cp ~/.config/monitors.xml ~gdm/.config/ &&
# set tap to click on gdm login screen
xhost SI:localuser:gdm
sudo -u gdm gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true &&
# install enable and start touchegg 
sudo dnf copr enable joseexposito/touchegg &&
sudo dnf install touchegg &&
sudo systemctl enable touchegg.service &&
sudo systemctl start touchegg
# Install System 76 Task Scheduler
sudo dnf copr enable mjakeman/system76-scheduler &&
sudo dnf install system76-scheduler
# Install System 76 Pop Shell extension and excluse keyboard shortcut overrides
sudo dnf install -y --setopt=exclude=gnome-shell-extension-pop-shell-shortcut-overrides gnome-shell-extension-pop-shell && systemctl start com.system76.Scheduler systemctl enable com.system76.Scheduler
# Install tlp and start tlp service
sudo dnf install tlp tlp-rdw &&
sudo systemctl enable tlp.service &&
sudo systemctl start tlp.service
# Add some popular gnome-shell extensions
sudo dnf install gnome-shell-extension-caffeine.noarch gnome-shell-extension-appindicator.noarch gnome-shell-extension-sound-output-device-chooser.noarch gnome-shell-extension-user-theme.noarch
# Install MegaSync and its Nautilus extension
wget https://mega.nz/linux/repo/Fedora_36/x86_64/megasync-Fedora_36.x86_64.rpm && wget https://mega.nz/linux/repo/Fedora_36/x86_64/nautilus-megasync-Fedora_36.x86_64.rpm &&
sudo dnf install megasync-Fedora_36.x86_64.rpm && sudo dnf install nautilus-megasync-Fedora_36.x86_64.rpm 
echo "Good Job! Now install the DOD PKI certificates."
