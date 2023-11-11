#!/bin/bash
cd $HOME
clear
# Display the warning message and prompt for confirmation
echo "Linux Install Script 1.0  Updated July 4th, 2023"
read -p $'\n\nThis Install Script assumes you have both Mozilla Firefox and Chromium\ninstalled. Only the native versions of these packages are supported.\nIf you have the Snap, Flatpak, or Appimage versions of these browsers\ninstalled, install the native versions before running this script.\nThe Script will still run if you only have Firefox or Chromium installed,\nbut it will not complete successfully if you have yet to open the browser.\n\nEnsure that you have already opened both Mozilla Firefox and Chromium \nbefore continuing with this script, and that both programs are closed.\n\nDo you wish to continue? (yes/y): ' confirm

if [[ ! $confirm =~ ^[Yy][Ee]?[Ss]?$ ]]; then
  echo "Installation aborted."
  exit 0
fi

# Remove existing AllCerts.zip file
if [ -f AllCerts.zip ]; then
  echo "Removing existing AllCerts.zip file..."
  rm AllCerts.zip
fi

# Check for updates before downloading certificates
echo "Checking for updates..."
wget -N https://militarycac.com/maccerts/AllCerts.zip

# Unzip File and place it in a new DoDcerts Folder
echo "Unzipping the AllCerts.zip file..."
unzip -o AllCerts.zip -d DoDcerts
echo "Unzip complete."

# Change into the newly created DoDcerts folder
cd DoDcerts

# Import only updated or new certificates into the Firefox certificate database
echo "Importing individual .cer files into the Firefox certificate database..."
for n in *.cer; do
  cert_name="$(basename "$n" .cer)"
  # Check if the certificate is already imported or up to date
  if certutil -L -d ~/.mozilla/firefox/*default-release | grep -q "$cert_name" && [[ "$(certutil -V -u C -n "$cert_name" -d ~/.mozilla/firefox/*default-release | grep -c 'Not After')" -eq 0 ]]; then
    echo "Certificate $cert_name is already imported and up to date. Skipping..."
  else
    echo "Importing $n..."
    certutil -A -d ~/.mozilla/firefox/*default-release -i "$n" -n "$cert_name" -t "CT,C,C"
  fi
done
echo "Import into the Firefox certificate database complete."

# Remove expired certificates from the Firefox certificate database
echo "Removing expired certificates from the Firefox certificate database..."
for cert_name in $(certutil -L -d ~/.mozilla/firefox/*default-release | grep 'u,u,u' | awk '{print $3}'); do
  if certutil -V -u C -n "$cert_name" -d ~/.mozilla/firefox/*default-release | grep -q 'Not After'; then
    echo "Removing expired certificate $cert_name..."
    certutil -D -n "$cert_name" -d ~/.mozilla/firefox/*default-release
  fi
done
echo "Removal of expired certificates from the Firefox certificate database complete."

# Import only updated or new certificates into the NSSDB certificate database
echo "Importing individual .cer files into the NSSDB certificate database..."
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
echo "Import into the NSSDB certificate database complete."

# Remove expired certificates from the NSSDB certificate database
echo "Removing expired certificates from the NSSDB certificate database..."
for cert_name in $(certutil -L -d ~/.pki/nssdb | grep 'u,u,u' | awk '{print $3}'); do
  if certutil -V -u C -n "$cert_name" -d ~/.pki/nssdb | grep -q 'Not After'; then
    echo "Removing expired certificate $cert_name..."
    certutil -D -n "$cert_name" -d ~/.pki/nssdb
  fi
done
echo "Removal of expired certificates from the NSSDB certificate database complete."

# List the contents of the NSSDB certificate database
echo -e "\n\n\nHere's what's in the NSSDB (Chromium) certificate database..."
certutil -L -d ~/.pki/nssdb

# List the contents of the modified Firefox certificate database
echo -e "\n\n\nHere's what's in the Firefox Certificate Database..."
certutil -L -d ~/.mozilla/firefox/*default-release

echo -e "\n\n\nAll Done!"

