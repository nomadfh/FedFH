#!/bin/bash

# Function to display information with a 1-second timeout
display_info() {
  echo -e "$1"
  sleep 1
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
      display_info "Unsupported Linux distribution. Please install '$package_name' manually and run the script again."
      exit 1
      ;;
  esac
}

# Function to check and install required dependencies
check_install_dependency() {
  local required_tools=("wget" "unzip" "certutil" "opensc-tool")

  installed_tools=()

  for tool in "${required_tools[@]}"; do
    command -v "$tool" >/dev/null 2>&1 || {
      display_info "This script requires '$tool' but it is not installed."
      read -p "Do you want to install it now? (yes/y): " -r
      echo
      if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]] || [[ $REPLY =~ ^[Yy]$ ]]; then
        install_dependency "$tool"
        installed_tools+=("$tool")
      else
        display_info "Installation aborted."
        exit 0
      fi
    }
  done

  if [ ${#installed_tools[@]} -eq 0 ]; then
    display_info "All required dependencies are already installed."
  else
    display_info "The following packages have been installed: ${installed_tools[*]}"
  fi
}

# Clear the terminal
clear

# Display version and instructions
echo -e "\e[31mLinux Install Script 1.0  Updated July 4th, 2023\e[0m"
read -p $'\n\nThis Install Script assumes you have both Mozilla Firefox and Chromium\ninstalled. \e[31mOnly the native versions of these packages are supported.\e[0m\nIf you have the Snap, Flatpak, or Appimage versions of these browsers\ninstalled, install the native versions before running this script.\nThe Script will still run if you only have Firefox or Chromium installed,\nbut it will not complete successfully if you have yet to open the browser.\n\nEnsure that you have already opened both Mozilla Firefox and Chromium \nbefore continuing with this script, and that both programs are closed.\n\nDo you wish to continue? (yes/y): ' confirm

# Check the exit status of the user prompt
if [[ ! $confirm =~ ^[Yy][Ee][Ss]$ ]] && [[ ! $confirm =~ ^[Yy]$ ]]; then
  display_info "Installation aborted."
  exit 0
fi

# Check and install dependencies
check_install_dependency

# Rest of the script remains unchanged
cd $HOME || exit

# Remove existing AllCerts.zip file
if [ -f AllCerts.zip ]; then
  display_info "Removing existing AllCerts.zip file..."
  rm AllCerts.zip
fi

# Check for updates before downloading certificates
display_info "Checking for updates..."
wget -N https://militarycac.com/maccerts/AllCerts.zip

# Unzip File and place it in a new DoDcerts Folder
display_info "Unzipping the AllCerts.zip file..."
unzip -o AllCerts.zip -d DoDcerts
display_info "Unzip complete."

# Change into the newly created DoDcerts folder
cd DoDcerts || exit

# Import only updated or new certificates into the Firefox certificate database
display_info "Importing individual .cer files into the Firefox certificate database..."

for n in *.cer; do
  cert_name="$(basename "$n" .cer)"
  # Check if the certificate is already imported or up to date
  if certutil -L -d ~/.mozilla/firefox/*default-release | grep -q "$cert_name" && [[ "$(certutil -V -u C -n "$cert_name" -d ~/.mozilla/firefox/*default-release | grep -c 'Not After')" -eq 0 ]]; then
    continue
  else
    certutil -A -d ~/.mozilla/firefox/*default-release -i "$n" -n "$cert_name" -t "CT,C,C"
  fi
done

display_info "Import into the Firefox certificate database complete."

# Remove expired certificates from the Firefox certificate database
display_info "Removing expired certificates from the Firefox certificate database..."

for cert_name in $(certutil -L -d ~/.mozilla/firefox/*default-release | grep 'u,u,u' | awk '{print $3}'); do
  if certutil -V -u C -n "$cert_name" -d ~/.mozilla/firefox/*default-release | grep -q 'Not After'; then
    certutil -D -n "$cert_name" -d ~/.mozilla/firefox/*default-release
  fi
done

display_info "Removal of expired certificates from the Firefox certificate database complete."

# Import only updated or new certificates into the NSSDB certificate database
display_info "Importing individual .cer files into the NSSDB certificate database..."

for n in *.cer; do
  cert_name="$(basename "$n" .cer)"
  # Check if the certificate is already imported or up to date
  if certutil -L -d ~/.pki/nssdb | grep -q "$cert_name" && [[ "$(certutil -V -u C -n "$cert_name" -d ~/.pki/nssdb | grep -c 'Not After')" -eq 0 ]]; then
    continue
  else
    certutil -A -d ~/.pki/nssdb -i "$n" -n "$cert_name" -t "CT,CT,C"
  fi
done

display_info "Import into the NSSDB certificate database complete."

# Remove expired certificates from the NSSDB certificate database
display_info "Removing expired certificates from the NSSDB certificate database..."

for cert_name in $(certutil -L -d ~/.pki/nssdb | grep 'u,u,u' | awk '{print $3}'); do
  if certutil -V -u C -n "$cert_name" -d ~/.pki/nssdb | grep -q 'Not After'; then
    certutil -D -n "$cert_name" -d ~/.pki/nssdb
  fi
done

display_info "Removal of expired certificates from the NSSDB certificate database complete."

# List the contents of the NSSDB certificate database
echo -e "NSSDB Certificate Database\nHere's what's in the NSSDB certificate database...\n$(certutil -L -d ~/.pki/nssdb)"

# List the contents of the modified Firefox certificate database
echo -e "Firefox Certificate Database\nHere's what's in the Firefox Certificate Database...\n$(certutil -L -d ~/.mozilla/firefox/*default-release)"

display_info "All Done!"

