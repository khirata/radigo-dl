#!/bin/bash

COUNTRY=$1      # e.g., Japan
CITY=$2         # e.g., Tokyo
STATION_ID=$3   # e.g., JOQR
START_TIME=$4   # e.g., 202601171500

OUTPUT="output/${START_TIME}-${STATION_ID}.aac"

nordvpn login --token $(< /run/secrets/nordvpn.txt) || exit 1

echo "$(date --iso-8601="seconds") $(basename $0) $1 $2 $3 $4"

# Connect to local VPN server in the station area
ATTEMPTS=0
MAX_ATTEMPTS=9

echo "nordvpn c $COUNTRY $CITY"

nordvpn c "$COUNTRY" "$CITY"
until radigo area | grep -q "$STATION_ID"; do
    if (( ATTEMPTS >= MAX_ATTEMPTS )); then
        echo "Failed to match area after $MAX_ATTEMPTS attempts."
        exit 1
    fi
    echo "Current area does not list the station ($STATION_ID). Reconnecting..."
    radigo area
    nordvpn d
    nordvpn c "$COUNTRY" "$CITY"
    ((ATTEMPTS++))
done

# Record the program and copy to the host
ATTEMPTS=0
MAX_ATTEMPTS=4

until radigo rec -id="$STATION_ID" -s="$START_TIME" && [[ -f "$OUTPUT" ]]; do
    if (( ATTEMPTS >= MAX_ATTEMPTS )); then
        echo "Failed to download after $MAX_ATTEMPTS attempts."
        exit 1
    fi
    echo "Failed to download ($START_TIME $STATION_ID). Re-tring..."
    ((ATTEMPTS++))
done

chown 1000:1000 "$OUTPUT"
cp "$OUTPUT" /root/audios

nordvpn d
