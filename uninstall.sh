#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="wg-putz-bot"

echo "==> Stoppe und deaktiviere Service..."
sudo systemctl stop "$SERVICE_NAME" 2>/dev/null || true
sudo systemctl disable "$SERVICE_NAME" 2>/dev/null || true

echo "==> Entferne Symlink..."
sudo rm -f /etc/systemd/system/$SERVICE_NAME.service
sudo systemctl daemon-reload

echo "==> Fertig! Service wurde entfernt."
echo "    Projektdateien und Datenbank sind noch vorhanden."
