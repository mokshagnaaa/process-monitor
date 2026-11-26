#!/bin/bash
# Usage: ./process_monitor.sh 

PROCESS_NAME="${1:-bash}"     
INTERVAL="${2:-5}"            
CPU_LIMIT=80                  
MEM_LIMIT=80                  
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
