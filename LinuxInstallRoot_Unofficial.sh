#!/bin/bash

# Function to display information with a timeout
display_info_with_timeout() {
  zenity --info --text="$1" --timeout=3
}

# Function to display information with a "Click OK to proceed" message
display_info_with_prompt() {
  zenity --info --text="$1\n\nClick OK to proceed"
}

# Display a graphical dialog for confirmation
zenity --question --title="Install Script" --text="This Install Script assumes you have both Mozilla Firefox and Chromium installed. Only the native versions of these packages are supported. If you have the Snap, Flatpak, or Appimage versions of these browsers installed, install the native versions before running this script. The Script will still run if you only have Firefox or Chromium installed, but it will not complete successfully if you have yet to open the browser.\n\nEnsure that you have already opened both Mozilla Firefox and Chromium before continuing with this script, and that both programs are closed." --width=600

# Check the exit status of the zenity dialog
if [ $? != 0 ]; then
  display_info_with_timeout "Installation aborted."
  exit 0
fi

cd $HOME
clear

# Remove existing AllCerts.zip file
if [ -f AllCerts.zip ]; then
  display_info_with_timeout "Removing existing AllCerts.zip file..."
  rm AllCerts.zip
fi

# Check for updates before downloading certificates
display_info_with_timeout "Checking for updates..."
wget -N https://militarycac.com/maccerts/AllCerts.zip

# Unzip File and place it in a new DoDcerts Folder
display_info_with_timeout "Unzipping the AllCerts.zip file..."
unzip -o AllCerts.zip -d DoDcerts
display_info_with_timeout "Unzip complete."

# Change into the newly created DoDcerts folder
cd DoDcerts

# Import only updated or new certificates into the Firefox certificate database
display_info_with_timeout "Importing individual .cer files into the Firefox certificate database..."

for n in *.cer; do
  cert_name="$(basename "$n" .cer)"
  # Check if the certificate is already imported or up to date
  if certutil -L -d ~/.mozilla/firefox/*default-release | grep -q "$cert_name" && [[ "$(certutil -V -u C -n "$cert_name" -d ~/.mozilla/firefox/*default-release | grep -c 'Not After')" -eq 0 ]]; then
    continue
  else
    certutil -A -d ~/.mozilla/firefox/*default-release -i "$n" -n "$cert_name" -t "CT,C,C"
  fi
done

display_info_with_timeout "Import into the Firefox certificate database complete."

# Remove expired certificates from the Firefox certificate database
display_info_with_timeout "Removing expired certificates from the Firefox certificate database..."

for cert_name in $(certutil -L -d ~/.mozilla/firefox/*default-release | grep 'u,u,u' | awk '{print $3}'); do
  if certutil -V -u C -n "$cert_name" -d ~/.mozilla/firefox/*default-release | grep -q 'Not After'; then
    certutil -D -n "$cert_name" -d ~/.mozilla/firefox/*default-release
  fi
done

display_info_with_timeout "Removal of expired certificates from the Firefox certificate database complete."

# Import only updated or new certificates into the NSSDB certificate database
display_info_with_timeout "Importing individual .cer files into the NSSDB certificate database..."

for n in *.cer; do
  cert_name="$(basename "$n" .cer)"
  # Check if the certificate is already imported or up to date
  if certutil -L -d ~/.pki/nssdb | grep -q "$cert_name" && [[ "$(certutil -V -u C -n "$cert_name" -d ~/.pki/nssdb | grep -c 'Not After')" -eq 0 ]]; then
    continue
  else
    certutil -A -d ~/.pki/nssdb -i "$n" -n "$cert_name" -t "CT,CT,C"
  fi
done

display_info_with_timeout "Import into the NSSDB certificate database complete."

# Remove expired certificates from the NSSDB certificate database
display_info_with_timeout "Removing expired certificates from the NSSDB certificate database..."

for cert_name in $(certutil -L -d ~/.pki/nssdb | grep 'u,u,u' | awk '{print $3}'); do
  if certutil -V -u C -n "$cert_name" -d ~/.pki/nssdb | grep -q 'Not After'; then
    certutil -D -n "$cert_name" -d ~/.pki/nssdb
  fi
done

display_info_with_timeout "Removal of expired certificates from the NSSDB certificate database complete."

# List the contents of the NSSDB certificate database
zenity --info --title="NSSDB Certificate Database" --text="Here's what's in the NSSDB certificate database...\n$(certutil -L -d ~/.pki/nssdb)"

# List the contents of the modified Firefox certificate database
zenity --info --title="Firefox Certificate Database" --text="Here's what's in the Firefox Certificate Database...\n$(certutil -L -d ~/.mozilla/firefox/*default-release)"

display_info "All Done!"

