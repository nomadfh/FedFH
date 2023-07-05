#!/bin/bash
cd $HOME
clear
# Display the warning message and prompt for confirmation
echo "Linux Install Script 1.0  Updated July 4th, 2023"
read -p $'\n\nThis Install Script assumes you have both Mozilla Firefox and Microsoft Edge\ninstalled. The Script will still run if you only have Firefox or Edge installed,\nbut it will not complete successfully if you have yet to open the browser.\n\nEnsure that you have already opened both Mozilla Firefox and Microsoft Edge \nbefore continuing with this script, and that both programs are closed.\n\nDo you wish to continue? (yes/y): ' confirm

if [[ ! $confirm =~ ^[Yy][Ee]?[Ss]?$ ]]; then
  echo "Installation aborted."
  exit 0
fi

# Download individual certs from MilitaryCAC's Mac bundle
echo "Downloading individual certificates from MilitaryCAC's Mac bundle..."
wget https://militarycac.com/maccerts/AllCerts.zip
echo "Download complete."

# Unzip File and place it in a new DoDcerts Folder
echo "Unzipping the AllCerts.zip file..."
unzip AllCerts.zip -d DoDcerts
echo "Unzip complete."

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
echo "Import into the Firefox certificate database complete."

# Import all individual .cer files into the NSSDB certificate database
echo "Importing individual .cer files into the NSSDB certificate database..."
for n in *.cer; do
  cert_name="$(basename "$n" .cer)"
  # Check if the certificate is already imported
  if certutil -L -d ~/.pki/nssdb | grep -q "$cert_name"; then
    echo "Certificate $cert_name is already imported. Skipping..."
  else
    echo "Importing $n..."
    certutil -A -d ~/.pki/nssdb -i "$n" -n "$cert_name" -t "CT,CT,C"
  fi
done
echo "Import into the NSSDB certificate database complete."

# List the contents of the NSSDB certificate database
echo -e "\n\n\nHere's what's in the NSSDB (EDGE) certificate database..."
certutil -L -d ~/.pki/nssdb

# List the contents of the modified Firefox certificate database
echo -e "\n\n\nHere's what's in the Firefox Certificate Database..."
certutil -L -d ~/.mozilla/firefox/*default-release

echo -e "\n\n\nAll Done!"

