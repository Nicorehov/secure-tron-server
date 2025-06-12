#!/usr/bin/env bash

# Parameters (edit before running)
USER_NAME="nic"
IFACE="enp0s8"
HOST_IP="192.168.56.10"

mkdir -p report

# 1) Install SSH, UFW, curl
sudo apt update
sudo apt install -y openssh-server ufw curl

# 2) Configure SSH: key-only, disable passwords and root login
sudo sed -i \
  -e 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' \
  -e 's/^#\?PermitRootLogin .*/PermitRootLogin no/' \
  /etc/ssh/sshd_config
echo "AllowUsers ${USER_NAME}" | sudo tee /etc/ssh/sshd_config.d/01-allow-users.conf
sudo systemctl reload ssh

# 3) Host-only network
sudo ip link set ${IFACE} up
sudo ip addr add ${HOST_IP}/24 dev ${IFACE}

# 4) UFW setup
sudo ufw reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow in on ${IFACE} to any port 22 proto tcp
sudo ufw enable

# 5) Install and setup nordvpn
sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)
nordvpn login
# After login: nordvpn login --callback <URL>
nordvpn set autoconnect on
nordvpn set technology nordlynx
nordvpn set killswitch on
nordvpn whitelist add subnet 192.168.56.0/24

# 6) Tests
# Access test
ssh -o PasswordAuthentication=no -i ~/.ssh/id_rsa ${USER_NAME}@127.0.0.1 -p 22 \
  echo "SSH key auth OK" > report/ssh-key-test.txt || true

# VPN status
nordvpn status > report/nordvpn-status.txt