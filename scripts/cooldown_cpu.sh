#!/bin/bash
# ============================================
# ❄️ Script de régulation thermique CPU - Proxmox
# Surveille la température et ajuste la fréquence max
# Version avec log /var/log/cooldown_cpu.log
# ============================================

# Configuration
TEMP_HIGH=90       # Seuil haut (°C) : limite avant throttling
TEMP_LOW=80        # Seuil bas (°C) : retour en vitesse max
MAX_FREQ="4.7GHz"  # Fréquence max autorisée
SAFE_FREQ="3.2GHz" # Fréquence réduite en cas de surchauffe
CHECK_INTERVAL=30  # Intervalle entre vérifications (secondes)
LOG_FILE="/var/log/cooldown_cpu.log"

# Création du fichier log s'il n'existe pas
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

# Fonction de log avec horodatage
log() {
  echo "$(date '+%F %T') $1" | tee -a "$LOG_FILE"
}

# Vérifications préalables
if ! command -v cpupower &>/dev/null; then
  log "❌ cpupower non installé. Installe-le avec : apt install linux-cpupower -y"
  exit 1
fi

if ! command -v sensors &>/dev/null; then
  log "❌ lm-sensors non installé. Installe-le avec : apt install lm-sensors -y && sensors-detect"
  exit 1
fi

# Lecture température CPU
get_temp() {
  sensors | grep "Package id 0" | awk '{print $4}' | tr -d '+°C'
}

# Limiter la fréquence max
set_freq_limit() {
  local freq=$1
  cpupower frequency-set -u "$freq" >/dev/null 2>&1
  log "🧊 Fréquence maximale réglée sur $freq"
}

# Démarrage
log "============================================"
log "🧠 Démarrage du contrôle thermique CPU"
log "Seuil haut : ${TEMP_HIGH}°C | Seuil bas : ${TEMP_LOW}°C"
log "Vérification toutes les ${CHECK_INTERVAL}s"
log "============================================"

STATE="normal"

# Boucle de surveillance continue
while true; do
  TEMP=$(get_temp)
  if [ -z "$TEMP" ]; then
    log "⚠️ Impossible de lire la température CPU"
    sleep "$CHECK_INTERVAL"
    continue
  fi

  TEMP_INT=${TEMP%.*} # partie entière de la température

  if (( TEMP_INT >= TEMP_HIGH )) && [ "$STATE" != "cooling" ]; then
    log "🔥 Température $TEMP°C — réduction fréquence à ${SAFE_FREQ}"
    set_freq_limit "$SAFE_FREQ"
    STATE="cooling"
  elif (( TEMP_INT <= TEMP_LOW )) && [ "$STATE" == "cooling" ]; then
    log "❄️ Température $TEMP°C — retour fréquence max ${MAX_FREQ}"
    set_freq_limit "$MAX_FREQ"
    STATE="normal"
  else
    log "🌡️ Température stable : ${TEMP}°C (mode $STATE)"
  fi

  sleep "$CHECK_INTERVAL"
done
