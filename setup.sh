#!/usr/bin/env bash

set -euo pipefail

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "🧪 Running in DRY-RUN mode. No changes will be made."
  echo ""
fi

echo "🧪 Starting NixOS System Configuration Setup..."

PROJECT_DIR="$(pwd)"
TARGET_DIR="/etc/nixos"
TIMESTAMP="$(date +%s)"
BACKUP_DIR="$TARGET_DIR.backup.$TIMESTAMP"

echo "📂 Project Directory: $PROJECT_DIR"
echo "📁 Target NixOS Config Directory: $TARGET_DIR"
echo ""

# 1. Backup current config
echo "🛡️ Backing up /etc/nixos to $BACKUP_DIR..."
$DRY_RUN || sudo cp -r "$TARGET_DIR" "$BACKUP_DIR"

# 2. Copy new configuration
echo "📥 Replacing configuration.nix..."
$DRY_RUN || sudo cp "$PROJECT_DIR/configuration.nix" "$TARGET_DIR/configuration.nix"

# 3. Copy modules if exists
if [ -d "$PROJECT_DIR/modules" ]; then
  echo "📂 Copying modules directory..."
  $DRY_RUN || sudo cp -r "$PROJECT_DIR/modules" "$TARGET_DIR/modules"
fi

# 4. Display current disks
echo ""
echo "🔍 Current disk layout (excluding NVMe):"
lsblk -f | grep -v nvme || true
echo ""
echo "⚠️ If you have HDD partitions, edit hardware-configuration.nix and add UUID entries."
echo ""

# 5. Create mount directories
read -rp "👤 Enter your username for mount paths under /home: " USERNAME
echo "📁 Will create: /home/$USERNAME/work and /home/$USERNAME/utility"
$DRY_RUN || sudo mkdir -p /home/"$USERNAME"/work /home/"$USERNAME"/utility

# 6. Rebuild system
echo ""
echo "🔄 Rebuilding system with nixos-rebuild switch..."
$DRY_RUN || sudo nixos-rebuild switch

echo ""
echo "🎉 Setup ${DRY_RUN:+(dry-run) }complete!"
