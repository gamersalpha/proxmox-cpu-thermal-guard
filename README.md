# 🧠 Proxmox CPU Thermal Guard

A lightweight thermal monitoring and CPU performance management tool for Proxmox hosts.  
Automatically adjusts CPU frequency to prevent overheating during AI or virtualization workloads (like Ollama).

---

## �� Features
- 🧊 Automatic CPU cooling: reduces max frequency above 90 °C  
- ⚙️ Returns to max performance below 80 °C  
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

## 🧩 Manual Check — `check_cpu_perf.sh`

Example output when checking CPU performance status:

```
============================================
🧠 CPU Performance Check
Date: Wed Oct 29 09:39:43 AM CET 2025
============================================

🔧 CPU Governor Mode:
✅ Mode: PERFORMANCE (OK)

⚙️ Current CPU Frequencies (MHz):
CPU 0 : 4000 MHz
CPU 1 : 3900 MHz
CPU 2 : 3500 MHz
CPU 3 : 3200 MHz
...

📊 Load Average:
 3.72, 2.56, 1.80

🌡️ Temperatures:
Package id 0:  +68.0°C
Core 0:        +65.0°C
Core 1:        +66.0°C
Core 2:        +70.0°C

🔍 cpupower details:
  available cpufreq governors: performance powersave
                  The governor "performance" may decide which speed to use

============================================
✅ Verification complete.
If the governor is 'performance', your CPU is ready for Ollama.
============================================
```

---

## ❄️ Automatic Thermal Regulation — `cooldown_cpu.sh`

This script continuously monitors CPU temperature and adjusts the frequency limit dynamically.

Example log entries (`/var/log/cooldown_cpu.log`):

```
2025-10-29 10:05:32 🧠 Starting CPU thermal control
2025-10-29 10:06:02 🌡️ Temperature stable: 68°C (mode normal)
2025-10-29 10:08:12 🔥 Temperature 91°C — reducing max frequency to 3.2GHz
2025-10-29 10:09:30 🌡️ Temperature stable: 85°C (mode cooling)
2025-10-29 10:11:10 ❄️ Temperature 78°C — restoring max frequency to 4.7GHz
```

---

## 📊 Live Monitoring

To view logs in real time:
```bash
tail -f /var/log/cooldown_cpu.log
```

Or use the systemd journal:
```bash
journalctl -u cooldown-cpu -f
```

---

## 🧠 Systemd Integration

Service file: `/etc/systemd/system/cooldown-cpu.service`

```ini
[Unit]
Description=Automatic CPU Thermal Regulation for Proxmox
After=multi-user.target

[Service]
ExecStart=/usr/local/bin/cooldown_cpu.sh
Restart=always
RestartSec=5
StandardOutput=append:/var/log/cooldown_cpu.log
StandardError=append:/var/log/cooldown_cpu.log

[Install]
WantedBy=multi-user.target
```

---

## 📸 Example Dashboard

To get a live view of CPU status, you can run:
```bash
watch -n 2 'grep "Package id 0" /sys/class/thermal/thermal_zone*/temp 2>/dev/null; sensors | grep "Package id 0"'
```

---

## 🧾 TODO — Zabbix Integration

### 🎯 Objective
Integrate **Proxmox CPU Thermal Guard** with **Zabbix** to provide real-time thermal and CPU performance metrics.

### 🧩 Planned Tasks
- [ ] Create Zabbix **UserParameter** definitions for:
  - Current CPU temperature (from `sensors`)
  - Governor mode (`cpupower frequency-info`)
  - CPU frequency average (from `/proc/cpuinfo`)
  - Script state (normal / cooling)
- [ ] Add Zabbix agent configuration template (`zabbix_agentd.d/thermal_guard.conf`)
- [ ] Provide a Zabbix **template XML** for easy import
- [ ] Include alert triggers:
  - 🔥 Overheating above 90 °C  
  - ⚠️ Cooling mode active > 5 minutes  
  - ❄️ Recovery events below 80 °C
- [ ] Optional: Display data in Zabbix dashboard with color-coded graph widgets

---

## 📜 License
MIT License © 2025 gamersalpha
