#!/bin/bash

# Install required packages
sudo /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install oath-toolkit

# Prompt users to set up TOTP
secret=$(oathtool --totp --base32 --length 6)
echo "Scan this QR code with your authenticator app to set up TOTP authentication:"
qrencode -t ANSI256 "otpauth://totp/$(hostname)?secret=$secret"

valid=false
while [ $valid != true ]
do
    read -p "Enter your TOTP code: " totp
    output=$(oathtool --totp --base32 --length 6 $secret)
    if [ $output == $totp ]
    then
        valid=true
    else
        echo "Invalid TOTP code. Please try again."
    fi
done

# Enable TOTP authentication for sudo
sudo authchanger -a -i -plugin com.apple.authentication.pam -dsclauth -reset -reason "Enable TOTP authentication"
sudo defaults write /Library/Preferences/com.apple.loginwindow "SecurityMechanism" -string "SecureToken,LocalPassword,TOTP"

echo "TOTP authentication has been set up successfully."
