#!/bin/bash
# This script polls NUT to get your UPS status.
# It sends desktop notifications on status change.

PREV_STATUS=""
echo "Monitor started. Waiting for UPS status changes..."
logger -t "UPS-monitor" "Monitor started"

while true; do
    # Get all possible statuses (split by spaces and display on lines)
    CURRENT_STATUS=$(upsc cyberpower@localhost ups.status 2>/dev/null)

    if [ -n "$CURRENT_STATUS" ] && [ "$CURRENT_STATUS" != "$PREV_STATUS" ]; then
        # Categorize the main status for notification
        # Priority: Danger (Battery/Discharge) > Alert (Others) > Normal (Line)
        case "$CURRENT_STATUS" in
        *"OB"* | *"DISCHRG"* | *"OVER"* | *"LB"* | *"LOWBATT"* | *"OFF"* | *"FSD"*)
            # Critical or Danger States
            notify-send "🚨 cyberpower UPS - ALERT" "Status: $CURRENT_STATUS" -u critical
            logger -p user.alert -t "UPS-monitor" "ALERT: $CURRENT_STATUS"
            echo "[$(date)] ALERT: $CURRENT_STATUS"
            ;;
        *"CAL"* | *"BYPASS"* | *"TEST"* | *"WAIT"*)
            # Warning/Alert or Test States
            notify-send "⚠️ cyberpower UPS - Warning" "Status: $CURRENT_STATUS" -u normal
            logger -p user.warning -t "UPS-monitor" "Warning: $CURRENT_STATUS"
            echo "[$(date)] Warning: $CURRENT_STATUS"
            ;;
        *"OL"* | *"CHRG"*)
            # Normal or Recovery States
            notify-send "✅ cyberpower UPS - Normal" "Status: $CURRENT_STATUS" -u low
            logger -p user.info -t "UPS-monitor" "Normal: $CURRENT_STATUS"
            echo "[$(date)] Normal: $CURRENT_STATUS"
            ;;
        *)
            # Any other uncategorized status (caution)
            notify-send "ℹ️ cyberpower UPS" "New status: $CURRENT_STATUS" -u normal
            logger -p user.notice -t "UPS-monitor" "Uncategorized status: $CURRENT_STATUS"
            echo "[$(date)] Uncategorized status: $CURRENT_STATUS"
            ;;
        esac
        PREV_STATUS="$CURRENT_STATUS"
    fi

    sleep 2 # polling rate
done
