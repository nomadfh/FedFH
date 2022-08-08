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
sudo dnf install system76-scheduler
# Install System 76 Pop Shell extension and excluse keyboard shortcut overrides
sudo dnf install -y --setopt=exclude=gnome-shell-extension-pop-shell-shortcut-overrides gnome-shell-extension-pop-shell

echo "Good Job! Now install the DOD PKI certificates."
