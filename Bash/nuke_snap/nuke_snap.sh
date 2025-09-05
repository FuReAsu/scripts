#!/bin/bash

all_success=false
while [ "$all_success" = false ]; do
    all_success=true

    mapfile -t snap_packages < <(snap list | awk 'NR > 1 { print $1 }')

    if [ ${#snap_packages[@]} -eq 0 ]; then
        break  
    fi

    for snap_package in "${snap_packages[@]}"; do
        echo "Removing $snap_package..."
        if snap remove "$snap_package"; then
            echo "✅ Successfully removed $snap_package"
        else
            echo "❌ Removing $snap_package failed, will retry later."
            all_success=false
        fi
    done

    if [ "$all_success" = false ]; then
        echo "Retrying in 3s..."
        sleep 3
    fi
done

echo "🎉 All snaps have been nuked"

echo "Uninstalling snapd from system..."
systemctl disable --now snapd 2>/dev/null || true
pkill snapd 2>/dev/null || true
apt remove snapd -y

echo "Masking the service and socket"
systemctl mask snapd.service
systemctl mask snapd.socket
