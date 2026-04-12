#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="wg-putz-bot"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVICE_FILE="$SCRIPT_DIR/$SERVICE_NAME.service"

if [ ! -f "$SCRIPT_DIR/.env" ]; then
  echo "Fehler: .env-Datei nicht gefunden in $SCRIPT_DIR"
  echo "Erstelle eine mit: echo 'TELEGRAM_BOT_TOKEN=dein_token' > .env"
  exit 1
fi

echo "==> Installiere Abhängigkeiten..."
sudo apt update
sudo apt install -y ruby ruby-dev build-essential libsqlite3-dev

echo "==> Installiere Ruby-Gems..."
gem install bundler
cd "$SCRIPT_DIR" && bundle install

echo "==> Richte systemd-Service ein..."
sudo ln -sf "$SERVICE_FILE" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl start "$SERVICE_NAME"

echo "==> Fertig! Bot laeuft."
echo "    Logs: sudo journalctl -u $SERVICE_NAME -f"
