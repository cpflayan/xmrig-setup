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

sudo cat >/etc/systemd/system/xmrig.service <<EOL
[Unit]
Description=Xmrig Miner Service
After=network.target

[Service]
WorkingDirectory=/root/xmrig-6.22.2
ExecStart=/root/xmrig-6.22.2/xmrig
Restart=always
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=xmrig
User=root

[Install]
WantedBy=multi-user.target
EOL

sudo cat >/etc/systemd/system/v2rayc.service <<EOL

[Unit]

Description=V2ray Local Client

After=network.target



[Service]
WorkingDirectory=/root/v2ray
ExecStart=/root/v2ray/v2ray run

Restart=on-failure

RestartSec=10

LimitNOFILE=4096



[Install]

WantedBy=multi-user.target

EOL
cd ~/
rm -rf xmr*
wget https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz
tar zxfv xmrig-6.22.2-linux-static-x64.tar.gz
cd ~/xmrig-6.22.2
cat > config.json<<EOL
{
    "autosave": false,
    "cpu": {
        "enabled": true,
        "huge-pages": true,
        "hw-aes": "null",
        "priority": 5,
        "yield": false,
        "max-threads-hint": 100,
        "asm": true,
        "argon2-impl": "null"
    },
    "randomx": {
        "init-avx2": "-1",
        "init": "-1",
        "1gb-pages": true,
        "numa": true,
        "scratchpad_prefetch_mode": 1
    }
    "opencl": false,
    "cuda": false,
  "pools": [
        {
            "algo": "rx/0",
            "coin": null,
            "url": "pool.supportxmr.com:443",
            "user": "43cx2hYimLw9YkAYxLG8Vg2TStTL3r6XmbfDfBiCY9MCViYCCaYpEzr1BUCmZTquQwLpg7Sb1FhrV4qR5EXWwvkgKdSHVLd",
            "pass": "z",
            "rig-id": null,
            "nicehash": false,
            "keepalive": false,
            "enabled": true,
            "tls": true,
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

sudo systemctl daemon-reload



sudo systemctl stop v2rayc.service



sudo systemctl stop xmrig.service

# 啟用並啟動服務 (注意：服務名稱修正為 ss-local.service)



sudo systemctl enable v2rayc.service

sudo systemctl reenable v2rayc.service

sudo systemctl enable xmrig.service

sudo systemctl reenable xmrig.service

sudo systemctl start v2rayc.service

sudo systemctl start xmrig.service
