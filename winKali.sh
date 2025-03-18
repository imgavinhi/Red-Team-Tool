#!/bin/bash
# Number of Kali machines to create
NUM_MACHINES=2 #Change to 5 for comp
# Base IP for the containers (first machine will be at 192.168.47.50)
BASE_IP=50

# Number of Windows machines to create
NUM_WINDOWS=1  # Adjust this for the number of Windows VMs you want

# Stop and delete any existing containers
for i in $(seq 1 $NUM_MACHINES); do
    CONTAINER="red-team2-kali${i}"
    echo "Stopping and deleting container: $CONTAINER"
    incus stop "$CONTAINER" 2>/dev/null || true
    incus delete "$CONTAINER" 2>/dev/null || true
done

# Stop and delete any existing Windows VMs
for i in $(seq 1 $NUM_WINDOWS); do
    WIN_VM="red-team2-windows${i}"
    echo "Stopping and deleting Windows VM: $WIN_VM"
    incus stop "$WIN_VM" 2>/dev/null || true
    incus delete "$WIN_VM" 2>/dev/null || true
done

# Optionally, create the network if needed (uncomment the next line if required)
# incus network create r2-kali-test network=UPLINK ipv4.address=192.168.47.1/24 ipv4.nat=true ipv6.address=none ipv6.nat=false
# incus network create testing-for-comp network=UPLINK ipv4.address=192.168.47.1/24 ipv4.nat=true ipv6.address=none ipv6.nat=false

# Initialize Kali containers with unique IP addresses
for i in $(seq 1 $NUM_MACHINES); do
    CONTAINER="red-team2-kali${i}"
    IP="192.168.47.$((BASE_IP + i - 1))"
    echo "Initializing container: $CONTAINER with IP $IP"
    # change --network r2-kali-test
    incus init images:kali "$CONTAINER" -t c2-m6 --network testing-for-comp -d eth0,ipv4.address="${IP}" -d root,size=320GiB
done

# Initialize Windows VM with a unique IP address
for i in $(seq 1 $NUM_WINDOWS); do
    WIN_VM="red-team2-windows${i}"
    IP="192.168.47.$((BASE_IP + NUM_MACHINES + i))"
    echo "Initializing Windows VM: $WIN_VM with IP $IP"
    # Here we use the Windows Server 2019 image from oszoo repository
    # change --network r2-kali-test
    incus launch oszoo:winsrv/2019/ansible-cloud "$WIN_VM" --vm --config limits.cpu=4 --config limits.memory=8GiB --network testing-for-comp --device eth0,ipv4.address="${IP}" --device root,size=320GiB
done

# Start Kali containers
echo "========== Starting Kali VMs =========="
for i in $(seq 1 $NUM_MACHINES); do
    CONTAINER="red-team2-kali${i}"
    incus start "$CONTAINER"
done

# Start Windows VMs
echo "========== Starting Windows VMs =========="
for i in $(seq 1 $NUM_WINDOWS); do
    WIN_VM="red-team2-windows${i}"
    incus start "$WIN_VM"
done

# Update and install packages on Kali containers
echo "========== Setting up Kali VMs =========="
for i in $(seq 1 $NUM_MACHINES); do
    CONTAINER="red-team2-kali${i}"
    incus exec "$CONTAINER" -- /bin/bash -c "apt update"
    incus exec "$CONTAINER" -- /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get install -y net-tools git python3 nmap metasploit-framework iputils-ping'
done

# Create a new user 'bard' and set its password on Kali containers
echo "========== Creating new user 'bard' =========="
for i in $(seq 1 $NUM_MACHINES); do
    CONTAINER="red-team2-kali${i}"
    incus exec "$CONTAINER" -- /bin/bash -c "useradd -m -s /bin/bash bard"
    incus exec "$CONTAINER" -- /bin/bash -c "echo 'bard:bard' | chpasswd"
done

# Add 'bard' to the sudo group on Kali containers
echo "========== Adding 'bard' to sudo group =========="
for i in $(seq 1 $NUM_MACHINES); do
    CONTAINER="red-team2-kali${i}"
    incus exec "$CONTAINER" -- /bin/bash -c "usermod -aG sudo bard"
done

# Clone GitHub repositories into the home directory of user 'bard' on Kali containers
echo "========== Cloning GitHub repositories =========="
for i in $(seq 1 $NUM_MACHINES); do
    CONTAINER="red-team2-kali${i}"
    incus exec "$CONTAINER" -- /bin/bash -c "git clone https://github.com/imgavinhi/Red-Team-Tool /home/bard/Red-Team-Tool"
    incus exec "$CONTAINER" -- /bin/bash -c "git clone https://github.com/arogoff/redteamscripts/ /home/bard/redteamscripts"
    incus exec "$CONTAINER" -- /bin/bash -c "git clone https://github.com/seabass586/Comp2Tools /home/bard/Comp2Tools"
    incus exec "$CONTAINER" -- /bin/bash -c "git clone https://github.com/arogoff/blueteamscripts/ /home/bard/blueteamscripts"
done

# Change ownership of the cloned repositories to the 'bard' user on Kali containers
echo "========== Changing ownership of cloned repositories =========="
for i in $(seq 1 $NUM_MACHINES); do
    CONTAINER="red-team2-kali${i}"
    incus exec "$CONTAINER" -- /bin/bash -c "chown -R bard:bard /home/bard/Red-Team-Tool /home/bard/redteamscripts /home/bard/Comp2Tools /home/bard/blueteamscripts"
done

# Add a login message for the root user on Kali containers
echo "========== Adding login message for root user =========="
for i in $(seq 1 $NUM_MACHINES); do
    CONTAINER="red-team2-kali${i}"
    incus exec "$CONTAINER" -- /bin/bash -c "echo 'Welcome to the Red Team VM!' > /etc/motd"
done

# Optionally, you can add similar configurations for the Windows VM if needed
echo "To get into the windows machines use: incus console --type=vga red-team2-windows#"
