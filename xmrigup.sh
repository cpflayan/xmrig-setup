#!/bin/bash

# 安裝 Shadowsocks-libev
sudo apt install shadowsocks-libev -y
#創資料夾
mkdir /home/xmrig
cd /home/xmrig
# 下載並解壓 xmrig
wget https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-linux-static-x64.tar.gz
tar xzfv xmrig-6.22.2-linux-static-x64.tar.gz

# 建立 xmrig systemd 服務檔 (注意：這裡的 ExecStart 中 --proxy 參數使用本地 127.0.0.1:1080)
sudo cat >/etc/systemd/system/xmrig1.service <<EOL
[Unit]
Description=Xmrig Miner Service
After=network.target

[Service]
WorkingDirectory=/home/xmrig/xmrig-6.22.2
ExecStart=/home/xmrig/xmrig-6.22.2/xmrig -o 155.248.227.196:8855 -u 8B5ERk1rDHzEyxhTMDjENRG1gVqtsWnTx78kjoPNARYYCwXErauWfjjdz4mSwhSBoqPmEiLeSxkw5irLmSCyG7qGDHfhjWi -p x --nicehash -k --proxy 127.0.0.1:1080 
Restart=always
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=xmrig
User=root

[Install]
WantedBy=multi-user.target
EOL

#sudo cat >/etc/systemd/system/xmrig2.service <<EOL
#[Unit]
#Description=Xmrig Miner Service
#After=network.target

#[Service]
#WorkingDirectory=/home/ubuntu/xmrig-6.22.2
#ExecStart=/home/ubuntu/xmrig-6.22.2/xmrig -o 114.29.237.94:3333 -u 43cx2hYimLw9YkAYxLG8Vg2TStTL3r6XmbfDfBiCY9MCViYCCaYpEzr1BUCmZTquQwLpg7Sb1FhrV4qR5EXWwvkgKdSHVLd -p x --proxy 127.0.0.1:1080 -t 8 --cpu-affinity 0xAAAA
#Restart=always
#RestartSec=10
#KillSignal=SIGINT
#SyslogIdentifier=xmrig
#User=root

#[Install]
#WantedBy=multi-user.target
#EOL

# 建立 ss-local systemd 服務檔
sudo cat >/etc/systemd/system/ss-local.service <<EOL
[Unit]
Description=Shadowsocks Local Client
After=network.target

[Service]
ExecStart=/usr/bin/ss-local -c /etc/shadowsocks-libev/config.json
Restart=on-failure
RestartSec=10
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOL

# 建立 Shadowsocks 配置檔
cat >/etc/shadowsocks-libev/config.json <<EOL
{
    "server": "155.248.227.196",
    "server_port": 4433,
    "local_address": "127.0.0.1",
    "local_port": 1080,
    "password": "abc123",
    "timeout": 300,
    "method": "chacha20-ietf-poly1305",
    "mode": "tcp_and_udp"
}
EOL

# 重新載入 systemd 配置

sudo systemctl daemon-reload

sudo systemctl stop xmrig1.service

sudo systemctl stop ss-local.service
# 啟用並啟動服務 (注意：服務名稱修正為 ss-local.service)

sudo systemctl enable xmrig1.service

sudo systemctl reenable xmrig1.service

sudo systemctl enable ss-local.service

sudo systemctl reenable ss-local.service

sudo systemctl start ss-local.service

sudo systemctl start xmrig1.service



