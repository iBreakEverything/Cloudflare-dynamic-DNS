#!/bin/sh

echo "=== Cloudflare-dynamic-DNS Installer ==="

# Choose mode
echo "Select mode:"
echo "1) crontab"
echo "2) user"
read -rp "Enter choice [1-2]: " mode_choice

case "$mode_choice" in
  1) MODE="crontab" ;;
  2) MODE="user" ;;
  *) echo "Invalid mode"; exit 1 ;;
esac

# Choose shell
echo "Select shell type:"
echo "1) bash"
echo "2) sh"
read -rp "Enter choice [1-2]: " shell_choice

case "$shell_choice" in
  1) SHELL="bash" ;;
  2) SHELL="sh" ;;
  *) echo "Invalid shell"; exit 1 ;;
esac

# Construct filename
SCRIPT_FILENAME="cloudflare-${MODE}-${SHELL}-ipv4.sh"
CONFIG_FILENAME="cloudflare-ddns.conf"

# GitHub release URL
DOWNLOAD_URL_SCRIPT="https://github.com/iBreakEverything/Cloudflare-dynamic-DNS/releases/latest/download/${SCRIPT_FILENAME}"
DOWNLOAD_URL_CONFIG="https://github.com/iBreakEverything/Cloudflare-dynamic-DNS/releases/latest/download/${CONFIG_FILENAME}"

# Download the file
echo "Downloading $SCRIPT_FILENAME..."
curl -fsSL "$DOWNLOAD_URL_SCRIPT" -o "$SCRIPT_FILENAME" || { echo "Download failed!"; exit 1; }
echo "Downloading $CONFIG_FILENAME..."
curl -fsSL "$DOWNLOAD_URL_CONFIG" -o "$CONFIG_FILENAME" || { echo "Download failed!"; exit 1; }

chmod +x "$SCRIPT_FILENAME"
echo "✅ Downloaded and made executable: ./$SCRIPT_FILENAME"

# Check if jq is installed
if [[ $(jq --version 2>/dev/null| wc -c) -eq 0 ]]; then
  # Choose installer
  echo "Install jq:"
  echo "1) apt"
  echo "2) snap"
  echo "3) yum"
  echo "*) No"
  read -rp "Enter choice [1-2]: " shell_choice

  case "$shell_choice" in
    1) apt install jq -y ;;
    2) snap install jq ;;
    3) yum install epel-release -y && yum install jq -y ;;
    *) echo "jq not installed"; exit 1 ;;
  esac
fi

echo "✅ $(jq --version)"
