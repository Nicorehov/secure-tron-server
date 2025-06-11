#!/usr/bin/env bash

# Parameters (edit before running)
USER_NAME="nic"
IFACE="enp0s8"
HOST_IP="192.168.56.10"
TRON_IP="192.168.56.20"
JAVA_TRON_JAR="java-tron-lite.jar"
CONFIG_FILE="config.conf"

mkdir -p report

# 1) Install SSH, UFW, Java
sudo apt update
sudo apt install -y openssh-server ufw openjdk-11-jre-headless

# 2) Ensure user exists
if ! id -u ${USER_NAME} &>/dev/null; then
  sudo useradd -m -s /bin/bash ${USER_NAME}
fi

# 3) Host-only network
sudo ip link set ${IFACE} up
sudo ip addr add ${TRON_IP}/24 dev ${IFACE}

# 4) Deploy service
sudo tee /etc/systemd/system/tron-lite.service > /dev/null << EOF
[Unit]
Description=Java Tron Lite
After=network.target

[Service]
User=${USER_NAME}
ExecStart=/usr/bin/java -jar /home/${USER_NAME}/${JAVA_TRON_JAR} --config /home/${USER_NAME}/${CONFIG_FILE}
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now tron-lite.service

# 5) UFW setup
sudo ufw reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from ${HOST_IP} to any port 22 proto tcp
sudo ufw allow from ${HOST_IP} to any port 9090 proto tcp
sudo ufw enable

# 6) Tests
ssh ${USER_NAME}@${HOST_IP} "curl -s http://${TRON_IP}:9090/health" \
  > report/tron-from-gateway.txt || true

curl -s http://127.0.0.1:9090/health \
  > report/tron-from-outside.txt || echo "Access denied" >> report/tron-from-outside.txt