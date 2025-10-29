# 🧠 Proxmox CPU Thermal Guard

A lightweight thermal monitoring and CPU performance management tool for Proxmox hosts.  
Automatically adjusts CPU frequency to prevent overheating during AI or virtualization workloads (like Ollama).

---

## �� Features
- 🧊 Automatic CPU cooling: reduces max frequency above 90°C
- ⚙️ Returns to max performance below 80°C
- 🧾 Logs actions to `/var/log/cooldown_cpu.log`
- 🔁 Optional systemd service for background control
- 🧠 Compatible with CPU-only Proxmox nodes and Ollama deployments

---

## 📦 Installation

```bash
git clone git@github.com:gamersalpha/proxmox-cpu-thermal-guard.git
cd proxmox-cpu-thermal-guard
sudo cp scripts/*.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/*.sh
sudo cp systemd/cooldown-cpu.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable cooldown-cpu
sudo systemctl start cooldown-cpu
```

---

## 📊 Logs
View live temperature regulation logs:
```bash
tail -f /var/log/cooldown_cpu.log
```

---

## 🧩 Manual Check
Run a manual CPU state check:
```bash
check_cpu_perf.sh
```

---

## 📜 License
MIT License © 2025 gamersalpha
