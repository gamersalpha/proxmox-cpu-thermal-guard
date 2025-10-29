#!/bin/bash
# ============================================
# 🔍 Superviseur CPU - Ollama / Proxmox / Debian
# ============================================

echo "============================================"
echo "🧠 Vérification de l'état CPU"
echo "Date : $(date)"
echo "============================================"

# Vérifier le mode gouverneur CPU
echo -e "\n🔧 Mode gouverneur CPU :"
if [ -d /sys/devices/system/cpu ]; then
    GOV=$(grep -h . /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null | sort | uniq)
    if echo "$GOV" | grep -q "performance"; then
        echo "✅ Mode : PERFORMANCE (OK)"
    elif echo "$GOV" | grep -q "powersave"; then
        echo "⚠️ Mode : POWERSAVE (à changer avec : cpupower frequency-set -g performance)"
    else
        echo "❓ Mode détecté : $GOV"
    fi
else
    echo "❌ Impossible de lire les informations CPU (pas de cpufreq)"
fi

# Fréquences actuelles
echo -e "\n⚙️ Fréquences CPU actuelles (MHz) :"
awk '/cpu MHz/ {printf "CPU %-3d: %6.0f MHz\n", NR-1, $4}' /proc/cpuinfo | head -n 16

# Charge système
echo -e "\n📊 Charge moyenne (load average) :"
uptime | awk -F'load average:' '{print $2}'

# Températures (si lm-sensors installé)
if command -v sensors &>/dev/null; then
    echo -e "\n🌡️ Températures :"
    sensors | grep -E 'Package|Core' || echo "Aucune donnée température détectée."
else
    echo -e "\n🌡️ Info : 'lm-sensors' non installé. Pour l’installer :"
    echo "apt install lm-sensors -y && sensors-detect"
fi

# Vérifie que cpupower est dispo
if command -v cpupower &>/dev/null; then
    echo -e "\n🔍 Détails cpupower :"
    cpupower frequency-info | grep "governor"
else
    echo -e "\n⚠️ L’outil cpupower n’est pas installé. Installe-le avec :"
    echo "apt install linux-cpupower -y"
fi

echo -e "\n============================================"
echo "✅ Vérification terminée."
echo "Si le gouverneur est 'performance', ton CPU est prêt pour Ollama."
echo "============================================"
