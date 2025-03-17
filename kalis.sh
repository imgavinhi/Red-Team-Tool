#!/bin/bash

# Stops and deletes containers if they exist
incus stop red-team2-kali1 2>/dev/null || true
incus delete red-team2-kali1 2>/dev/null || true

incus stop red-team2-kali2 2>/dev/null || true
incus delete red-team2-kali2 2>/dev/null || true

incus stop red-team2-kali3 2>/dev/null || true
incus delete red-team2-kali3 2>/dev/null || true

incus stop red-team2-kali4 2>/dev/null || true
incus delete red-team2-kali4 2>/dev/null || true

incus stop red-team2-kali5 2>/dev/null || true
incus delete red-team2-kali5 2>/dev/null || true

# Creates the network for the container
#incus network create r2-kali-test network=UPLINK ipv4.address=192.168.47.1/24 ipv4.nat=true ipv6.address=none ipv6.nat=false

# Initializes the Kali container with a specific IP address and disk size
incus init images:kali red-team2-kali1 -t c2-m6 --network r2-kali-test -d eth0,ipv4.address=192.168.47.50 -d root,size=320GiB
incus init images:kali red-team2-kali2 -t c2-m6 --network r2-kali-test -d eth0,ipv4.address=192.168.47.51 -d root,size=320GiB
incus init images:kali red-team2-kali3 -t c2-m6 --network r2-kali-test -d eth0,ipv4.address=192.168.47.52 -d root,size=320GiB
incus init images:kali red-team2-kali4 -t c2-m6 --network r2-kali-test -d eth0,ipv4.address=192.168.47.53 -d root,size=320GiB
incus init images:kali red-team2-kali5 -t c2-m6 --network r2-kali-test -d eth0,ipv4.address=192.168.47.54 -d root,size=320GiB

# Starts the Kali container
echo "========== Start Kali VM"
incus start red-team2-kali1
incus start red-team2-kali2
incus start red-team2-kali3
incus start red-team2-kali4
incus start red-team2-kali5

# Setup Kali container (install basic tools)
echo "========== Setting up red-team2-kali"
incus exec red-team2-kali1 -- /bin/bash -c "apt update"
incus exec red-team2-kali1 -- /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get install -y net-tools git python3 nmap metasploit-framework kali-win-kex iputils-ping xrdp'
incus exec red-team2-kali2 -- /bin/bash -c "apt update"
incus exec red-team2-kali2 -- /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get install -y net-tools git python3 nmap metasploit-framework kali-win-kex iputils-ping xrdp'
incus exec red-team2-kali3 -- /bin/bash -c "apt update"
incus exec red-team2-kali3 -- /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get install -y net-tools git python3 nmap metasploit-framework kali-win-kex iputils-ping xrdp'
incus exec red-team2-kali4 -- /bin/bash -c "apt update"
incus exec red-team2-kali4 -- /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get install -y net-tools git python3 nmap metasploit-framework kali-win-kex iputils-ping xrdp'
incus exec red-team2-kali5 -- /bin/bash -c "apt update"
incus exec red-team2-kali5 -- /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get install -y net-tools git python3 nmap metasploit-framework kali-win-kex iputils-ping xrdp'

# Add a new user 'bard'
echo "========== Creating new user bard"
incus exec red-team2-kali1 -- /bin/bash -c "useradd -m -s /bin/bash bard"
incus exec red-team2-kali1 -- /bin/bash -c "echo 'bard:bard' | chpasswd" # Set password for bard
incus exec red-team2-kali2 -- /bin/bash -c "useradd -m -s /bin/bash bard"
incus exec red-team2-kali2 -- /bin/bash -c "echo 'bard:bard' | chpasswd" # Set password for bard
incus exec red-team2-kali3 -- /bin/bash -c "useradd -m -s /bin/bash bard"
incus exec red-team2-kali3 -- /bin/bash -c "echo 'bard:bard' | chpasswd" # Set password for bard
incus exec red-team2-kali4 -- /bin/bash -c "useradd -m -s /bin/bash bard"
incus exec red-team2-kali4 -- /bin/bash -c "echo 'bard:bard' | chpasswd" # Set password for bard
incus exec red-team2-kali5 -- /bin/bash -c "useradd -m -s /bin/bash bard"
incus exec red-team2-kali5 -- /bin/bash -c "echo 'bard:bard' | chpasswd" # Set password for bard

# Add the new user to the sudo group
echo "========== Adding 'bard' to sudo group"
incus exec red-team2-kali -- /bin/bash -c "usermod -aG sudo bard"

# Cloning GitHub repositories
echo "========== Cloning GitHub repositories"
incus exec red-team2-kali1 -- /bin/bash -c "git clone https://github.com/imgavinhi/Red-Team-Tool /home/bard/Red-Team-Tool"
incus exec red-team2-kali1 -- /bin/bash -c "git clone https://github.com/arogoff/redteamscripts/ /home/bard/redteamscripts"
incus exec red-team2-kali1 -- /bin/bash -c "git clone https://github.com/seabass586/Comp2Tools /home/bard/Comp2Tools"
incus exec red-team2-kali1 -- /bin/bash -c "git clone https://github.com/arogoff/blueteamscripts/ /home/bard/blueteamscripts"

incus exec red-team2-kali2 -- /bin/bash -c "git clone https://github.com/imgavinhi/Red-Team-Tool /home/bard/Red-Team-Tool"
incus exec red-team2-kali2 -- /bin/bash -c "git clone https://github.com/arogoff/redteamscripts/ /home/bard/redteamscripts"
incus exec red-team2-kali2 -- /bin/bash -c "git clone https://github.com/seabass586/Comp2Tools /home/bard/Comp2Tools"
incus exec red-team2-kali2 -- /bin/bash -c "git clone https://github.com/arogoff/blueteamscripts/ /home/bard/blueteamscripts"

incus exec red-team2-kali3 -- /bin/bash -c "git clone https://github.com/imgavinhi/Red-Team-Tool /home/bard/Red-Team-Tool"
incus exec red-team2-kali3 -- /bin/bash -c "git clone https://github.com/arogoff/redteamscripts/ /home/bard/redteamscripts"
incus exec red-team2-kali3 -- /bin/bash -c "git clone https://github.com/seabass586/Comp2Tools /home/bard/Comp2Tools"
incus exec red-team2-kali3 -- /bin/bash -c "git clone https://github.com/arogoff/blueteamscripts/ /home/bard/blueteamscripts"

incus exec red-team2-kali4 -- /bin/bash -c "git clone https://github.com/imgavinhi/Red-Team-Tool /home/bard/Red-Team-Tool"
incus exec red-team2-kali4 -- /bin/bash -c "git clone https://github.com/arogoff/redteamscripts/ /home/bard/redteamscripts"
incus exec red-team2-kali4 -- /bin/bash -c "git clone https://github.com/seabass586/Comp2Tools /home/bard/Comp2Tools"
incus exec red-team2-kali4 -- /bin/bash -c "git clone https://github.com/arogoff/blueteamscripts/ /home/bard/blueteamscripts"

incus exec red-team2-kali5 -- /bin/bash -c "git clone https://github.com/imgavinhi/Red-Team-Tool /home/bard/Red-Team-Tool"
incus exec red-team2-kali5 -- /bin/bash -c "git clone https://github.com/arogoff/redteamscripts/ /home/bard/redteamscripts"
incus exec red-team2-kali5 -- /bin/bash -c "git clone https://github.com/seabass586/Comp2Tools /home/bard/Comp2Tools"
incus exec red-team2-kali5 -- /bin/bash -c "git clone https://github.com/arogoff/blueteamscripts/ /home/bard/blueteamscripts"

# Change ownership of the cloned repositories to bard
incus exec red-team2-kali1 -- /bin/bash -c "chown -R bard:bard /home/bard/Red-Team-Tool /home/bard/redteamscripts /home/bard/Comp2Tools /home/bard/blueteamscripts"
incus exec red-team2-kali2 -- /bin/bash -c "chown -R bard:bard /home/bard/Red-Team-Tool /home/bard/redteamscripts /home/bard/Comp2Tools /home/bard/blueteamscripts"
incus exec red-team2-kali3 -- /bin/bash -c "chown -R bard:bard /home/bard/Red-Team-Tool /home/bard/redteamscripts /home/bard/Comp2Tools /home/bard/blueteamscripts"
incus exec red-team2-kali4 -- /bin/bash -c "chown -R bard:bard /home/bard/Red-Team-Tool /home/bard/redteamscripts /home/bard/Comp2Tools /home/bard/blueteamscripts"
incus exec red-team2-kali5 -- /bin/bash -c "chown -R bard:bard /home/bard/Red-Team-Tool /home/bard/redteamscripts /home/bard/Comp2Tools /home/bard/blueteamscripts"

# Add a basic message for the root user
echo "========== Adding message for root user"
incus exec red-team2-kali1 -- /bin/bash -c "echo 'reset; echo YOU ARE LOGGED IN AS ROOT IN red-team2-kali' >> /root/.bashrc"
incus exec red-team2-kali2 -- /bin/bash -c "echo 'reset; echo YOU ARE LOGGED IN AS ROOT IN red-team2-kali' >> /root/.bashrc"
incus exec red-team2-kali3 -- /bin/bash -c "echo 'reset; echo YOU ARE LOGGED IN AS ROOT IN red-team2-kali' >> /root/.bashrc"
incus exec red-team2-kali4 -- /bin/bash -c "echo 'reset; echo YOU ARE LOGGED IN AS ROOT IN red-team2-kali' >> /root/.bashrc"
incus exec red-team2-kali5 -- /bin/bash -c "echo 'reset; echo YOU ARE LOGGED IN AS ROOT IN red-team2-kali' >> /root/.bashrc"

# Add a basic message for the bard user
echo "========== Adding message for bard user"
incus exec red-team2-kali1 -- /bin/bash -c "echo 'reset; echo YOU ARE LOGGED IN AS bard IN red-team2-kali' >> /home/bard/.bashrc"
incus exec red-team2-kali2 -- /bin/bash -c "echo 'reset; echo YOU ARE LOGGED IN AS bard IN red-team2-kali' >> /home/bard/.bashrc"
incus exec red-team2-kali3 -- /bin/bash -c "echo 'reset; echo YOU ARE LOGGED IN AS bard IN red-team2-kali' >> /home/bard/.bashrc"
incus exec red-team2-kali4 -- /bin/bash -c "echo 'reset; echo YOU ARE LOGGED IN AS bard IN red-team2-kali' >> /home/bard/.bashrc"
incus exec red-team2-kali5 -- /bin/bash -c "echo 'reset; echo YOU ARE LOGGED IN AS bard IN red-team2-kali' >> /home/bard/.bashrc"

echo "========== Setup complete."
