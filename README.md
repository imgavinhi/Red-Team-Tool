Red Team Tool - CSEC-473 Cyber Defense Techniques

Author: Gavin Hunsinger Email: gwh8959@rit.edu Team: FoxtrotSpring 2025

Overview

This repository contains two red team tools designed for cyber competitions: a Reverse Shell Tool and a Network Disrupter Tool. These tools assist in maintaining persistent access and disrupting network functionality on compromised systems.

Reverse Shell Tool

How reverse_shell.sh Works

1. Before running this script, ensure the target machine has SSH enabled and that a user with sudo privileges is available.

2. This script prompts for:
  Target IP – IP address of the machine to create a reverse shell on.
  Target User – User with sudo privileges to establish an SSH connection.
  Host IP Address – Attacker's machine IP.
  Host Port – Unreserved TCP port for the reverse shell connection.

3. The script:
  Constructs a systemd service file (/etc/systemd/system/shell.service) that:
  Runs as root.
  Starts after network services (After=network.target).
  Creates a persistent reverse shell using /bin/bash -i.
  Redirects input/output/errors to the attacker's machine.
  Restarts indefinitely if terminated (Restart=always).

4. Uses SSH to:
  Write the service file on the target.
  Reload systemd and enable the service (systemctl enable), ensuring persistence after reboots.
  Start the service (systemctl start).
  Hides processes using:ssh $TARGET_USER@$TARGET_IP "sudo mount -o remount,rw,nosuid,nodev,noexec,relatime,hidepid=1 /proc"
  This prevents non-root users from seeing other users’ processes.

5. The attacker's machine listens for a connection:
  nc -lvp $ATTACKER_PORT

6. Once connected, the attacker gains an interactive root shell.

Usage

1. Clone the GitHub repository.
2. Run:sudo chmod +x reverse_shell.shThis grants executable permissions.
3. Run:./reverse_shell.sh
4. Follow the prompts to specify the target IP, target user, host IP, and port.

Network Disrupter Tool

How network.sh Works

1. This script disrupts network connectivity by continuously disabling interfaces.

  Defines disable_all_networks():
  Collects network interface names (excluding loopback lo).
  Disables each interface.

2. Main script execution:
  Calls disable_all_networks().
  Hides processes (hidepid=1).
  Runs in a loop every five seconds:
  If a network interface is re-enabled, it is set back down.

network.service
1. Defines a systemd service:
2. Runs network.sh as root.
3. Restarts indefinitely if terminated (Restart=always).
4. Ensures startup after network initialization (After=network.target).
5. Enables persistence across reboots.

How deploy_network_disruption.sh Works
1. Before running, ensure SSH is enabled and a sudo user exists on the target.
2. Prompts for:
   Target IP
   Target User
3. Checks for network.sh and network.service in the current directory.
4. Uses scp to copy files to the target machine.
5. Uses SSH to:
  Move network.sh to /opt/network.sh.
  Grant execution permissions (chmod +x /opt/network.sh).
  Move network.service to /etc/systemd/system/.
  Reload systemd and enable/start the service.

Usage
1. Clone the GitHub repository.
2. Run:sudo chmod +x deploy_network_disruption.sh
3. Run:./deploy_network_disruption.shFollow the prompts to specify the target IP and user.
