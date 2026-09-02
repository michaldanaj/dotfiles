#!/bin/bash

DEVICE_NAME="Px7 S2"

# włącz Bluetooth, jeśli jest wyłączony
if ! rfkill list bluetooth | grep -q "Soft blocked: no"; then
    echo "Włączam Bluetooth..."
    rfkill unblock bluetooth
    sleep 2
fi

# pobierz MAC urządzenia po nazwie
DEVICE_MAC=$(bluetoothctl devices | grep "$DEVICE_NAME" | awk '{print $2}')

if [ -z "$DEVICE_MAC" ]; then
    echo "Nie znaleziono urządzenia $DEVICE_NAME ❌"
    exit 1
fi

# sprawdź, czy urządzenie jest już połączone
if bluetoothctl info "$DEVICE_MAC" | grep -q "Connected: yes"; then
    echo "$DEVICE_NAME już połączony ✅"
else
    echo "Łączenie z $DEVICE_NAME..."
    bluetoothctl connect "$DEVICE_MAC"
    sleep 2
    if bluetoothctl info "$DEVICE_MAC" | grep -q "Connected: yes"; then
        echo "Połączono z $DEVICE_NAME 🎧"
    else
        echo "Nie udało się połączyć z $DEVICE_NAME ❌"
    fi
fi
