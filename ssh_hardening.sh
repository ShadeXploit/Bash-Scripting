#!/bin/bash

# SSH Hardening Script for SSH server

# Define the new SSH port (change this if you want a different port)
NEW_SSH_PORT=2222

# Backup the current sshd_config before making changes
echo "Backing up current sshd_config..."
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Change SSH port
echo "Changing SSH port to $NEW_SSH_PORT..."
sudo sed -i "s/^#Port 22/Port $NEW_SSH_PORT/" /etc/ssh/sshd_config

# Disable password authentication
echo "Disabling password authentication..."
sudo sed -i "s/^#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config

# Disable root login
echo "Disabling root login..."
sudo sed -i "s/^#PermitRootLogin prohibit-password/PermitRootLogin no/" /etc/ssh/sshd_config

# Force SSH to use Protocol 2 only
echo "Ensuring SSH Protocol 2 is used..."
sudo sed -i "s/^#Protocol 2/Protocol 2/" /etc/ssh/sshd_config

# Restart SSH service to apply changes
echo "Restarting SSH service..."
sudo systemctl restart ssh

# Setup UFW Firewall (if not already set up)
echo "Setting up UFW firewall..."
sudo apt-get install ufw -y
sudo ufw allow $NEW_SSH_PORT/tcp
sudo ufw enable

# Install Fail2Ban if not installed
echo "Installing Fail2Ban..."
sudo apt-get install fail2ban -y

# Configure Fail2Ban for SSH
echo "Configuring Fail2Ban for SSH..."
echo "[sshd]" | sudo tee -a /etc/fail2ban/jail.local
echo "enabled = true" | sudo tee -a /etc/fail2ban/jail.local
echo "port = $NEW_SSH_PORT" | sudo tee -a /etc/fail2ban/jail.local
echo "logpath = /var/log/auth.log" | sudo tee -a /etc/fail2ban/jail.local
echo "maxretry = 3" | sudo tee -a /etc/fail2ban/jail.local

# Restart Fail2Ban service
echo "Restarting Fail2Ban..."
sudo systemctl restart fail2ban

# Output status messages
echo "All done! Your SSH server has been hardened."
echo "Your new SSH port is $NEW_SSH_PORT."
echo "Use the following command to connect to your Raspberry Pi from now on:"
echo "ssh -p $NEW_SSH_PORT pi@<your-pi-ip>"
