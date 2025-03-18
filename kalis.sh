#!/bin/bash
# Number of Kali machines to create
NUM_MACHINES=2 #Change to 5 for comp
# Base IP for the containers (first machine will be at 192.168.47.50)
BASE_IP=50

# Stop and delete any existing containers
for i in $(seq 1 $NUM_MACHINES); do
    CONTAINER="red-team2-kali${i}"
    echo "Stopping and deleting container: $CONTAINER"
    incus stop "$CONTAINER" 2>/dev/null || true
    incus delete "$CONTAINER" 2>/dev/null || true
done

# Optionally, create the network if needed (uncomment the next line if required)
# incus network create r2-kali-test network=UPLINK ipv4.address=192.168.47.1/24 ipv4.nat=true ipv6.address=none ipv6.nat=false
# incus network create testing-for-comp network=UPLINK ipv4.address=192.168.47.1/24 ipv4.nat=true ipv6.address=none ipv6.nat=false

# Initialize containers with unique IP addresses
for i in $(seq 1 $NUM_MACHINES); do
    CONTAINER="red-team2-kali${i}"
    IP="192.168.47.$((BASE_IP + i - 1))"
    echo "Initializing container: $CONTAINER with IP $IP"
    #incus init images:kali "$CONTAINER" -t c2-m6 --network r2-kali-test -d eth0,ipv4.address="${IP}" -d root,size=320GiB
    incus init images:kali "$CONTAINER" -t c2-m6 --network testing-for-comp -d eth0,ipv4.address="${IP}" -d root,size=320GiB
done

# Start containers
echo "========== Starting Kali VMs =========="
for i in $(seq 1 $NUM_MACHINES); do
    CONTAINER="red-team2-kali${i}"
    incus start "$CONTAINER"
done

# Update and install packages on each container
echo "========== Setting up Kali VMs =========="
for i in $(seq 1 $NUM_MACHINES); do
    CONTAINER="red-team2-kali${i}"
    incus exec "$CONTAINER" -- /bin/bash -c "apt update"
    incus exec "$CONTAINER" -- /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get install -y net-tools git python3 nmap metasploit-framework iputils-ping'
done

# Create a new user 'bard' and set its password
echo "========== Creating new user 'bard' =========="
for i in $(seq 1 $NUM_MACHINES); do
    CONTAINER="red-team2-kali${i}"
    incus exec "$CONTAINER" -- /bin/bash -c "useradd -m -s /bin/bash bard"
    incus exec "$CONTAINER" -- /bin/bash -c "echo 'bard:bard' | chpasswd"
done

# Add 'bard' to the sudo group on each container
echo "========== Adding 'bard' to sudo group =========="
for i in $(seq 1 $NUM_MACHINES); do
    CONTAINER="red-team2-kali${i}"
    incus exec "$CONTAINER" -- /bin/bash -c "usermod -aG sudo bard"
done

# Clone GitHub repositories into the home directory of user 'bard'
echo "========== Cloning GitHub repositories =========="
for i in $(seq 1 $NUM_MACHINES); do
    CONTAINER="red-team2-kali${i}"
    incus exec "$CONTAINER" -- /bin/bash -c "git clone https://github.com/imgavinhi/Red-Team-Tool /home/bard/Red-Team-Tool"
    incus exec "$CONTAINER" -- /bin/bash -c "git clone https://github.com/arogoff/redteamscripts/ /home/bard/redteamscripts"
    incus exec "$CONTAINER" -- /bin/bash -c "git clone https://github.com/seabass586/Comp2Tools /home/bard/Comp2Tools"
    incus exec "$CONTAINER" -- /bin/bash -c "git clone https://github.com/arogoff/blueteamscripts/ /home/bard/blueteamscripts"
done

# Change ownership of the cloned repositories to the 'bard' user
echo "========== Changing ownership of cloned repositories =========="
for i in $(seq 1 $NUM_MACHINES); do
    CONTAINER="red-team2-kali${i}"
    incus exec "$CONTAINER" -- /bin/bash -c "chown -R bard:bard /home/bard/Red-Team-Tool /home/bard/redteamscripts /home/bard/Comp2Tools /home/bard/blueteamscripts"
done

# Add a login message for the root user
echo "========== Adding login message for root user =========="
for i in $(seq 1 $NUM_MACHINES); do
    CONTAINER="red-team2-kali${i}"
    incus exec "$CONTAINER" -- /bin/bash -c "echo 'reset; echo YOU ARE LOGGED IN AS ROOT IN red-team2-kali' >> /root/.bashrc"
done

# Add a login message for the 'bard' user
echo "========== Adding login message for bard user =========="
for i in $(seq 1 $NUM_MACHINES); do
    CONTAINER="red-team2-kali${i}"
    incus exec "$CONTAINER" -- /bin/bash -c "echo 'reset; echo YOU ARE LOGGED IN AS bard IN red-team2-kali' >> /home/bard/.bashrc"
done

echo "========== Setup complete. =========="
