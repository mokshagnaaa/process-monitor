#!/bin/bash
# Usage: ./process_monitor.sh <process_name> <interval_seconds>

PROCESS_NAME="${1:-bash}"     # process to watch (default: bash)
INTERVAL="${2:-5}"            # check every N seconds (default: 5)
CPU_LIMIT=80                  # warn if CPU % is above this
MEM_LIMIT=80                  # warn if memory % is above this
LOG_FILE="monitor.log"

# Function to print a message with time and save it to the log file
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log "Started monitoring '$PROCESS_NAME' every $INTERVAL seconds (Ctrl+C to stop)"

while true; do
    PID=$(pgrep -x "$PROCESS_NAME" | head -n 1)

    if [ -z "$PID" ]; then
        log "ALERT: $PROCESS_NAME is NOT running"
    else
        CPU=$(ps -p "$PID" -o %cpu= | awk '{print int($1)}')
        MEM=$(ps -p "$PID" -o %mem= | awk '{print int($1)}')
        log "OK: $PROCESS_NAME PID=$PID CPU=${CPU}% MEM=${MEM}%"

        [ "$CPU" -ge "$CPU_LIMIT" ] && log "WARNING: High CPU usage ($CPU%)"
        [ "$MEM" -ge "$MEM_LIMIT" ] && log "WARNING: High memory usage ($MEM%)"
    fi

    sleep "$INTERVAL"
done
