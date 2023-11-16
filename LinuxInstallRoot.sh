cd $HOME
clear
# Display the warning message and prompt for confirmation
echo "Linux Installroot (unofficial)  Updated NOV 14 2023"
read -p $'\n\nThis Install Script assumes you have Mozilla Firefox and/or a Chromium based browser, such as Google Chrome or Microsoft Edge,\ninstalled. The Script will still run if you only have one of either installed,but it will not complete successfully if you\nhave yet to open the browser. Only native packages (not snap,flatpak, or appimage) are supported.\n\nEnsure that you have already opened your preferred browser(s) \nbefore continuing with this script, and that the browsers are closed.\n\nDo you wish to continue? (yes/y): ' confirm


if [[ ! $confirm =~ ^[Yy][Ee]?[Ss]?$ ]]; then
  echo "Installation aborted."
  exit 0
fi

clear
echo "Installing smart card and certificate dependencies."
sleep 2
# Check if apt is installed
if [ -x /usr/bin/apt ]; then
    # Install Ubuntu-specific packages
    sudo apt-get install pcsc-tools libccid libpcsc-perl libpcsclite1 pcscd opensc opensc-pkcs11 vsmartcard-vpcd libnss3-tools
    echo "These packages have been installed on your Ubuntu system."
else
    # Check if yum is installed
    if [ -x /usr/bin/yum ]; then
        # Install Red Hat/CentOS-specific packages
        sudo yum install nss-tools pcsc-lite perl-pcsc pcsc-tools ccid opensc
        echo "These packages have been installed on your Red Hat/CentOS/Fedora system."
    # Check if zypper is installed
    elif [ -x /usr/bin/zypper ]; then
        # Install openSUSE-specific packages
        sudo zypper install nss-tools pcsc-lite perl-pcsc pcsc-tools ccid opensc
        echo "These packages have been installed on your openSUSE system."
    # Check if pacman is installed
    elif [ -x /usr/bin/pacman ]; then
        # Install Arch Linux-specific packages
        sudo pacman -S nss pcsc-tools libccid libpcsc-perl libpcsclite1 pcscd opensc opensc-pkcs11 vsmartcard-vpcd libnss3-tools 
        echo "These packages have been installed on your Arch Linux system."
    else
        echo "This is an unknown distribution."
    fi
fi
echo
echo
echo
sleep 2
# remove any prexisting bundles
rm -f AllCerts.zip*
# Download individual certs from MilitaryCAC's Mac bundle
echo "Downloading individual certificates from MilitaryCAC's Mac bundle..."
wget https://militarycac.com/maccerts/AllCerts.zip
echo "Download complete."
# Unzip File and place it in a new DoDcerts Folder
echo "Unzipping the AllCerts.zip file..."
unzip AllCerts.zip -d DoDcerts && rm AllCerts.zip
echo
echo "Unzip complete."
echo
# Change into the newly created DoDcerts folder
cd DoDcerts
# Import all individual .cer files into the Firefox certificate database
echo "Importing individual .cer files into the Firefox certificate database..."
for n in *.cer; do
  cert_name="$(basename "$n" .cer)"
 # Check if the certificate is already imported
  if certutil -L -d ~/.mozilla/firefox/*default-release | grep -q "$cert_name"; then
    echo "Certificate $cert_name is already imported. Skipping..."
else
    echo "Importing $n..."
    certutil -A -d ~/.mozilla/firefox/*default-release -i "$n" -n "$cert_name" -t "CT,C,C"
  fi
done
echo
echo "Import into the Firefox certificate database complete."
echo
# Remove expired certificates from the Firefox certificate database
echo
echo
echo
echo "Removing expired certificates from the Firefox certificate database..."
for cert_name in $(certutil -L -d ~/.mozilla/firefox/*default-release | grep 'u,u,u' | awk '{print $3}'); do
  if certutil -V -u C -n "$cert_name" -d ~/.mozilla/firefox/*default-release | grep -q 'Not After'; then
    echo "Removing expired certificate $cert_name..."
    certutil -D -n "$cert_name" -d ~/.mozilla/firefox/*default-release
  fi
done
echo
echo
echo
echo "Removal of expired certificates from the Firefox certificate database complete."
echo
# Import only updated or new certificates into the NSSDB certificate database
echo "Importing individual .cer files into the Chromium certificate database..."
for n in *.cer; do
  cert_name="$(basename "$n" .cer)"
 # Check if the certificate is already imported or up to date
  if certutil -L -d ~/.pki/nssdb | grep -q "$cert_name" && [[ "$(certutil -V -u C -n "$cert_name" -d ~/.pki/nssdb | grep -c 'Not After')" -eq 0 ]]; then
    echo "Certificate $cert_name is already imported and up to date. Skipping..."
  else
    echo "Importing $n..."
    certutil -A -d ~/.pki/nssdb -i "$n" -n "$cert_name" -t "CT,CT,C"
  fi
done
echo
echo "Import into the NSSDB certificate database complete."
echo
echo
echo
# Remove expired certificates from the NSSDB certificate database
echo "Removing expired certificates from the NSSDB certificate database..."
for cert_name in $(certutil -L -d ~/.pki/nssdb | grep 'u,u,u' | awk '{print $3}'); do
  if certutil -V -u C -n "$cert_name" -d ~/.pki/nssdb | grep -q 'Not After'; then
    echo "Removing expired certificate $cert_name..."
    certutil -D -n "$cert_name" -d ~/.pki/nssdb
  fi
done
echo
echo
echo
echo "Removal of expired certificates from the NSSDB certificate database complete."
# List the contents of the NSSDB certificate database
echo -e "\n\n\nHere's what's in the NSSDB (EDGE) certificate database..."
echo -e "\n\n\nHere's what's in the NSSDB (Chromium) certificate database..."
certutil -L -d ~/.pki/nssdb

# List the contents of the modified Firefox certificate database
echo -e "\n\n\nHere's what's in the Firefox Certificate Database..."
certutil -L -d ~/.mozilla/firefox/*default-release
echo -e "\n\n\nAll Done!"

