#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="wg-putz-bot"

case "${1:-}" in
  start)
    sudo systemctl start "$SERVICE_NAME"
    echo "Bot gestartet."
    ;;
  stop)
    sudo systemctl stop "$SERVICE_NAME"
    echo "Bot gestoppt."
    ;;
  restart)
    sudo systemctl restart "$SERVICE_NAME"
    echo "Bot neugestartet."
    ;;
  status)
    sudo systemctl status "$SERVICE_NAME"
    ;;
  logs)
    sudo journalctl -u "$SERVICE_NAME" -f
    ;;
  *)
    echo "Verwendung: ./bot-ctl.sh {start|stop|restart|status|logs}"
    exit 1
    ;;
esac
