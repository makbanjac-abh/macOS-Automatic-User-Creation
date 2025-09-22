#!/bin/zsh

# Prompt for new admin username
read "NEWUSER?Enter the new employee username: "

# Prompt for full name
read "FULLNAME?Enter the full name for the new employee: "

# Prompt for password (input hidden)
read -s "PASSWORD?Enter the password for the new employee (input hidden): "
echo
read -s "PASSWORD2?Re-enter the password to confirm: "
echo

# Check if passwords match
if [[ "$PASSWORD" != "$PASSWORD2" ]]; then
  echo "Passwords do not match. Exiting."
  exit 1
fi

# Create the admin user interactively
sudo sysadminctl -addUser "$NEWUSER" -fullName "$FULLNAME" -admin -password "$PASSWORD"

# Install Homebrew
if ! command -v brew &> /dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Slack
brew install --cask slack

# Turn on FileVault
sudo fdesetup enable -user "$USER"

# Enable macOS firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# Set Finder to show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Set lock screen message
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "Property of Atlantbh. If you find this computer, please call +387 33 716-550 or e-mail us at hello@atlantbh.com"

# Require password immediately after sleep or screen saver
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo ""
echo "===== Onboarding Checklist ====="

# FileVault status
if fdesetup status | grep -q "FileVault is On"; then
  echo -e "${GREEN}✅ FileVault ON${NC}"
else
  echo -e "${RED}❌ FileVault OFF${NC}"
fi

# Firewall status
if /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep -q "enabled"; then
  echo -e "${GREEN}✅ Firewall ON${NC}"
else
  echo -e "${RED}❌ Firewall OFF${NC}"
fi

# Lock screen message
LOCKMSG="Property of Atlantbh. If you find this computer, please call +387 33 716-550 or e-mail us at hello@atlantbh.com"
if sudo defaults read /Library/Preferences/com.apple.loginwindow LoginwindowText 2>/dev/null | grep -q "$LOCKMSG"; then
  echo -e "${GREEN}✅ Lock screen poruka ON${NC}"
else
  echo -e "${RED}❌ Lock screen message OFF${NC}"
fi

# Slack installed
if [ -d "/Applications/Slack.app" ]; then
  echo -e "${GREEN}✅ Slack installed${NC}"
else
  echo -e "${RED}❌ Slack not installed${NC}"
fi

echo "==============================="

echo "Admin korisnik $FULLNAME kreiran."

echo "Skripta uspjesno obavljena. Ne zaboravi ukljuciti ${GREEN}Find My${NC} u postavkama."
