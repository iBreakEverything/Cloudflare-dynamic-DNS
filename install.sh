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
echo "✅  Downloaded and made executable: ./$SCRIPT_FILENAME"

# Check if jq is installed
if ! command -v jq >/dev/null 2>&1; then
  echo "⚠️  jq is required but not installed."
  read -rp "Do you want to install jq now? [y/N]: " install_jq

  case "$install_jq" in
    [yY][eE][sS]|[yY])
      echo "🔍 Detecting package manager..."

      if command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt install -y jq
      elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y jq
      elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y epel-release && sudo yum install -y jq
      elif command -v apk >/dev/null 2>&1; then
        sudo apk add --no-cache jq
      else
        echo "❌ Could not determine package manager. Please install jq manually."
        exit 1
      fi
      ;;
    *)
      echo "❌ jq is required to continue. Please install it manually."
      exit 1
      ;;
  esac
fi

echo "✔️  jq is installed; $(jq --version)"
