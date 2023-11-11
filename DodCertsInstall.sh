#!/bin/bash

# Function to display information with a timeout
display_info_with_timeout() {
  echo -e "$1"
  sleep 3
}

# Function to display information with a "Click OK to proceed" message
display_info_with_prompt() {
  echo -e "$1\n\nClick OK to proceed"
  read -p "Press [Enter] to continue..."
}

# Function to prompt the user to install a missing dependency
prompt_to_install_dependency() {
  read -p "This script requires '$1' but it is not installed. Do you want to install it now? (y/n): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    return 0
  else
    return 1
  fi
}

# Function to determine the appropriate package manager
get_package_manager() {
  if command -v dnf >/dev/null 2>&1; then
    echo "sudo dnf install -y"
  elif command -v apt >/dev/null 2>&1; then
    echo "sudo apt install -y"
  elif command -v zypper >/dev/null 2>&1; then
    echo "sudo zypper install -y"
  elif command -v pacman >/dev/null 2>&1; then
    echo "sudo pacman -Syu"
  else
    echo "unsupported"
  fi
}

# Function to install a missing dependency using the appropriate package manager
install_dependency() {
  local package_manager
  package_manager=$(get_package_manager)
  local package_name="$1"

  case $package_manager in
    "sudo dnf install -y")
      $package_manager "$package_name"
      ;;
    "sudo apt install -y")
      $package_manager "$package_name"
      ;;
    "sudo zypper install -y")
      $package_manager "$package_name"
      ;;
    "sudo pacman -Syu")
      $package_manager "$package_name"
      ;;
    *)
      display_info_with_timeout "Unsupported Linux distribution. Please install '$package_name' manually and run the script again."
      exit 1
      ;;
  esac
}

# Function to check and install required dependencies
check_install_dependency() {
  local required_tools=("wget" "unzip" "certutil")

  for tool in "${required_tools[@]}"; do
    command -v "$tool" >/dev/null 2>&1 || {
      display_info_with_prompt "This script requires '$tool' but it is not installed."
      prompt_to_install_dependency "$tool"
      if [ $? -eq 0 ]; then
        case "$tool" in
          "certutil")
            install_dependency "libnss3-tools"
            ;;
          *)
            install_dependency "$tool"
            ;;
        esac
      else
        display_info_with_timeout "Please install '$tool' manually before running the script again."
        exit 1
      fi
    }
  done
}

# Clear the terminal
clear

# Display version and instructions
echo "Linux Install Script 1.0  Updated July 4th, 2023"
read -p $'\n\nThis Install Script assumes you have both Mozilla Firefox and Chromium\ninstalled. Only the native versions of these packages are supported.\nIf you have the Snap, Flatpak, or Appimage versions of these browsers\ninstalled, install the native versions before running this script.\nThe Script will still run if you only have Firefox or Chromium installed,\nbut it will not complete successfully if you have yet to open the browser.\n\nEnsure that you have already opened both Mozilla Firefox and Chromium \nbefore continuing with this script, and that both programs are closed.\n\nDo you wish to continue? (yes/y): ' confirm

# Check the exit status of the user prompt
if [[ ! $confirm =~ ^[Yy][Ee][Ss]$ ]] && [[ ! $confirm =~ ^[Yy]$ ]]; then
  display_info_with_timeout "Installation aborted."
  exit 0
fi

# Rest of the script remains unchanged
cd $HOME || exit

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
cd DoDcerts || exit

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
echo -e "NSSDB Certificate Database\nHere's what's in the NSSDB certificate database...\n$(certutil -L -d ~/.pki/nssdb)"

# List the contents of the modified Firefox certificate database
echo -e "Firefox Certificate Database\nHere's what's in the Firefox Certificate Database...\n$(certutil -L -d ~/.mozilla/firefox/*default-release)"

display_info_with_timeout "All Done!"

