#!/bin/bash

sudo apt install curl openssl -y

sudo apt update && sudo apt upgrade -y

sudo mkdir /home/proxy

cd /home/proxy

wget https://github.com/xmrig/xmrig-proxy/releases/download/v6.22.0/xmrig-proxy-6.22.0-linux-static-x64.tar.gz

tar xzfv xmrig-proxy-6.22.0-linux-static-x64.tar.gz

bash <(curl -L https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh)

sudo cp /usr/local/etc/xray/config.json /usr/local/etc/xray/config.json.backup

sudo cat > /home/proxy/xmrig-proxy-6.22.0/config.json<<EOL
{
    "access-log-file": null,
    "access-password": null,
    "algo-ext": true,
    "api": {
        "id": null,
        "worker-id": null
    },
    "http": {
        "enabled": false,
        "host": "127.0.0.1",
        "port": 0,
        "access-token": null,
        "restricted": true
    },
    "background": false,
    "bind": [
        {
            "host": "0.0.0.0",
            "port": 3333,
            "tls": false
        },
        {
            "host": "::",
            "port": 3333,
            "tls": false
        }
    ],
    "colors": true,
    "title": true,
    "custom-diff": 0,
    "custom-diff-stats": false,
    "donate-level": 0,
    "log-file": null,
    "mode": "nicehash",
    "pools": [
        {
            "algo": "rx/0",
            "coin": null,
            "url": "pool.supportxmr.com:9000",
            "user": "8B5ERk1rDHzEyxhTMDjENRG1gVqtsWnTx78kjoPNARYYCwXErauWfjjdz4mSwhSBoqPmEiLeSxkw5irLmSCyG7qGDHfhjWi",
            "pass": "twcc",
            "rig-id": null,
            "keepalive": true,
            "enabled": true,
            "tls": true,
            "tls-fingerprint": null,
            "daemon": false
        }
    ],
    "retries": 2,
    "retry-pause": 1,
    "reuse-timeout": 0,
    "tls": {
        "enabled": true,
        "protocols": null,
        "cert": null,
        "cert_key": null,
        "ciphers": null,
        "ciphersuites": null,
        "dhparam": null
    },
    "user-agent": null,
    "syslog": false,
    "verbose": false,
    "watch": true,
    "workers": true
}
EOL

sudo cat > /usr/local/etc/xray/config.json<<EOL
{ 
    "inbounds": [
      { 
            "port": 443, 
            "protocol": "shadowsocks",
            "settings": {
                   "method": "chacha20-ietf-poly1305",   
                   "password": "abc123", 
                   "network": "tcp,udp"
                                }
         }
                            ], 
       "outbounds": [
        { 
              "protocol": "freedom", 
              "settings":
                       {
                             "servers": [ 
                               { 
                                      "address": "127.0.0.1", 
                                      "port": 3333
          }
        ]
      }
    }
  ]
}
EOL

sudo cat > /etc/systemd/system/xmrig-proxy.service<<EOL
[Unit]
Description=XMRig Proxy Service
After=network.target

[Service]
ExecStart=/home/proxy/xmrig-proxy-6.22.0/xmrig-proxy
WorkingDirectory=/home/proxy/xmrig-proxy-6.22.0
User=root
Group=root
Restart=always
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl stop xray.service

sudo systemctl stop xmrig-proxy.service

sudo systemctl daemon-reload

sudo systemctl reenable xray.service

sudo systemctl reenable xmrig-proxy.service

sudo systemctl start xray.service

sudo systemctl start xmrig-proxy.service
