# Secure VPN Gateway + Java-Tron-Lite

## How to run

1. In VirtualBox create 2 VM with Ubuntu (I used 20.04):
   - host-server (SSH-only + VPN)
   - tron-vps   (Java-Tron-Lite)

2. Copy the `host-server/` and `tron-vps/` directories to the corresponding VMs.
```bash
sudo apt update && sudo apt install -y git
cd /home/$(whoami)
git clone https://github.com/Nicorehov/secure-tron-server.git secure_tron
```
3. On each VM, run:
```bash
cd ~/secure-tron/ #folder host or java
chmod +x *.sh
sudo ./<script_name>.sh
```
4. Check the files in `report/`.

## Parameters
Both scripts have the following variables set at the beginning:
```bash
USER_NAME="your_user" # local user name
IFACE="enp0s8" # Host-Only interface
HOST_IP="192.168.56.10" # IP host-server
TRON_IP="192.168.56.20" # IP tron-vps
JAVA_TRON_JAR="java-tron-lite.jar"
CONFIG_FILE="config.conf"
```
Edit these values ​​before running.
```bash
cd ~/secure_tron/host_server
nano host_server.sh
# same with java_tron_light
```

## Verification
- **SSH-only**: `report/ssh-key-test.txt` contains `SSH key auth OK`.
- **VPN**: `report/nordvpn-status.txt` shows `Status: Connected` and `Kill Switch: enabled`.
- **Firewall**: UFW rules match restrictions.
- **Health**: `report/tron-from-gateway.txt` returns an answer, while `report/tron-from-outside.txt` returns `Access denied`.

Note* If you dont have a nordvpn subscribtion it wont return answer.