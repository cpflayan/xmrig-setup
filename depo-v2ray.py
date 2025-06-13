import os
import json
import platform
import subprocess
import urllib.request
import tarfile

# --- 下載 V2Ray ---
def download_v2ray():
    system = platform.system().lower()
    arch = platform.machine()

    # 自動選擇版本
    if arch == "x86_64":
        arch = "64"
    elif arch == "aarch64":
        arch = "arm64"
    else:
        print("暫不支援此架構")
        exit(1)

    url = f"https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-{arch}.zip"
    print(f"下載 V2Ray: {url}")
    urllib.request.urlretrieve(url, "v2ray.zip")
    os.system("unzip v2ray.zip -d v2ray")

# --- 生成 config.json ---
def generate_config():
    config = {
"inbounds": [
{
"port": 1080,
"listen": "127.0.0.1",
"protocol": "socks",
"settings": {
"auth": "noauth",
"udp": True
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
"udp": True
}
]
}
}
]
}
    os.makedirs("v2ray", exist_ok=True)
    with open("v2ray/config.json", "w") as f:
        json.dump(config, f, indent=4)
    print("已生成 config.json")

# --- 啟動 V2Ray ---
def start_v2ray():
    v2ray_path = "./v2ray/v2ray"
    subprocess.Popen([v2ray_path, "run", "./v2ray/config.json"])
    print("V2Ray 已啟動 (背景)")

# --- 總流程 ---
if __name__ == "__main__":
    os.system("apt update && apt install -y unzip curl")
    download_v2ray()
    generate_config()
    start_v2ray()
