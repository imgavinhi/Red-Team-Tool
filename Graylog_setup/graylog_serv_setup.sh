#!/bin/bash

set -e

# Update system
echo "[*] Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

# Install required dependencies
echo "[*] Installing dependencies (gnupg, curl, pwgen, wget)..."
sudo apt-get install -y gnupg curl pwgen wget

# Set required sysctl param
echo "[*] Setting vm.max_map_count..."
sudo sysctl -w vm.max_map_count=262144

# Install MongoDB
echo "[*] Installing MongoDB..."
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl daemon-reload
sudo systemctl enable mongod.service
sudo systemctl start mongod.service

# Install Graylog
echo "[*] Installing Graylog..."
wget https://packages.graylog2.org/repo/packages/graylog-6.1-repository_latest.deb
sudo dpkg -i graylog-6.1-repository_latest.deb
sudo apt-get update
sudo apt-get install -y graylog-datanode graylog-server

# Generate and configure password secret
echo "[*] Configuring Graylog secrets..."
PASSWORD_SECRET=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c96)
echo "Generated password secret: $PASSWORD_SECRET"

# Replace password_secret and http_bind_address
sudo sed -i "s/^password_secret =.*/password_secret = $PASSWORD_SECRET/" /etc/graylog/server/server.conf
sudo sed -i "s/^#http_bind_address =.*/http_bind_address = 0.0.0.0:9000/" /etc/graylog/server/server.conf
sudo sed -i "s/^password_secret =.*/password_secret = $PASSWORD_SECRET/" /etc/graylog/datanode/datanode.conf

# Enable and start services
echo "[*] Enabling and starting Graylog services..."
sudo systemctl daemon-reload
sudo systemctl enable graylog-datanode.service
sudo systemctl start graylog-datanode.service
sudo systemctl enable graylog-server.service
sudo systemctl start graylog-server.service

echo "[+] Graylog installation complete!"
echo "Access the web UI at http://<your-server-ip>:9000"
