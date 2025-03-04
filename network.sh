#!/bin/bash
#Gavin Hunsinger, Spring 2025, cdtfoxtrot

#disables all network interfaces besides the loopback interfaces based on the listed interfaces on the os
disable_all_networks() {
    echo "Disabling all network interfaces except lo (loopback)..."
    
    # Get all active network interfaces except loopback
    INTERFACES=$(ls /sys/class/net | grep -v lo)
    
    for IFACE in $INTERFACES; do
        echo "Disabling interface: $IFACE" #echo's do not appear when this is run as a service
        ip link set $IFACE down
    done
}

# Run disable_all_networks function
disable_all_networks

#prevents users from seeing all processes besides the ones they own
sudo mount -o remount,rw,nosuid,nodev,noexec,relatime,hidepid=1 /proc

# Monitor and disable interfaces if they come back up
while true; do
    sleep 5
    for IFACE in $(ls /sys/class/net | grep -v lo); do
        STATUS=$(ip link show $IFACE | grep "state UP") #checks for interfaces that entered the UP state
        if [ ! -z "$STATUS" ]; then
            echo "Interface $IFACE was brought UP. Disabling again..."
            ip link set $IFACE down
        fi
    done
done
