#!/bin/bash

# Color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${CYAN}=============================${RESET}"
echo -e "${RED}Running Privilege Check${RESET}"
echo -e "${CYAN}=============================${RESET}"
# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}This script must be run as root.${RESET}"
    exit 1
fi

# Continue with the rest of the script as root
echo -e "${GREEN}Running as root. Performing privileged operations...${RESET}"

# Update & Upgrade
echo -e "${CYAN}=============================${RESET}"
echo -e "${GREEN}Updating & Upgrading Server${RESET}"
echo -e "${CYAN}=============================${RESET}"
apt update
apt upgrade -y

# Install Tools
echo -e "${CYAN}=============================${RESET}"
echo -e "${GREEN}Installing Required Tools${RESET}"
echo -e "${CYAN}=============================${RESET}"
apt -y install ca-certificates wget net-tools gnupg

# Adding Repository
echo -e "${CYAN}=============================${RESET}"
echo -e "${GREEN}Adding OpenVPN Repository${RESET}"
echo -e "${CYAN}=============================${RESET}"
wget https://as-repository.openvpn.net/as-repo-public.asc -qO /etc/apt/trusted.gpg.d/as-repository.asc
echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/as-repository.asc] http://as-repository.openvpn.net/as/debian focal main">/etc/apt/sources.list.d/openvpn-as-repo.list

# Install OpenVPN Access Server
echo -e "${CYAN}=============================${RESET}"
echo -e "${GREEN}Installing OpenVPN Access Server${RESET}"
echo -e "${CYAN}=============================${RESET}"
apt update && apt -y install openvpn-as

# Adding Firewall Rules
echo -e "${CYAN}=============================${RESET}"
echo -e "${GREEN}Adding Required Firewall Rules (tcp: 443,943, 945, udp: 1194)${RESET}"
echo -e "${CYAN}=============================${RESET}"
iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT
iptables -I INPUT 6 -m state --state NEW -p tcp --dport 943 -j ACCEPT
iptables -I INPUT 6 -m state --state NEW -p tcp --dport 945 -j ACCEPT
iptables -I INPUT 6 -m state --state NEW -p tcp --dport 1194 -j ACCEPT
sudo netfilter-persistent save

# Display Details
echo -e "${CYAN}=============================${RESET}"
echo -e "${GREEN}Installation Logs${RESET}"
echo -e "${CYAN}=============================${RESET}"
cat /usr/local/openvpn_as/init.log
