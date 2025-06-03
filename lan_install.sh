#!/bin/bash

# === 1. Verific daca Ansible este instalat ===
if ! command -v ansible >/dev/null 2>&1; then
  echo "Ansible nu este instalat. Il voi instala acum..."
  sudo apt update && sudo apt install -y ansible
  if [ $? -ne 0 ]; then
    echo "Eroare la instalarea Ansible. Iesim."
    exit 1
  fi
else
  echo "Ansible este deja instalat."
fi

# === 2. Cloneaza repo-ul GitHub ===
git clone https://github.com/xtrime123/CustomPfSense.git
cd CustomPfSense || exit 1

# === Functie: Verific daca IP-ul are formă validă ===
is_valid_ip() {
  local ip=$1
  if echo "$ip" | grep -Eq '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
    return 0
  else
    return 1
  fi
}

# === 3. Cere IP-ul pfSense, repetă până e valid ===
#while true; do
#  read -rp "Introdu IP-ul WAN pfSense dupa instalare (ex: 192.168.1.1): " PFSENSE_IP
#  if is_valid_ip "$PFSENSE_IP"; then
#    break
#  else
#    echo "[EROARE] IP-ul WAN introdus nu este valid. Incearca din nou."
#  fi
#done

# === 3. Cere IP-ul LAN pfSense, repet ^c p  n ^c e valid ===
while true; do
  read -rp "Introdu IP-ul LAN pfSense dupa instalare (ex: 192.168.1.1): " PFSENSE_IP_LAN
  if is_valid_ip "$PFSENSE_IP_LAN"; then
    break
  else
    echo "[EROARE] IP-ul LAN introdus nu este valid. Incearca din nou."
  fi
done


# === 4. Scrie fisierul hosts de la zero ===
HOSTS_FILE="./hosts"
mkdir -p "$(dirname "$HOSTS_FILE")"

cat > "$HOSTS_FILE" <<EOF
[pfsense]
#$PFSENSE_IP ansible_user=root ansible_password=pfsense ansible_connection=ssh ansible_port=22 ansible_ssh_common_args='-o StrictHostKeyChecking=no'
$PFSENSE_IP_LAN ansible_user=root ansible_password=pfsense ansible_connection=ssh ansible_port=22 ansible_ssh_common_args='-o StrictHostKeyChecking=no' ansible_shell_type=sh ansible_python_interpreter=/bin/sh
EOF

echo "[INFO] Fisierul hosts a fost rescris cu IP-ul $PFSENSE_IP_LAN."

# === 5. Pregatesc si fisierul all.yml ===
FISIER_YAML="./group_vars/all.yml"
mkdir -p "$(dirname "$FISIER_YAML")"

# === 5.1 Construim un array asociativ cu valorile existente ===
declare -A EXISTENTE

if [[ -f "$FISIER_YAML" ]]; then
  while IFS=":" read -r key value; do
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | sed -e 's/^ *"//' -e 's/" *$//' | xargs)
    if [[ -n "$key" && "$key" != \#* ]]; then
      EXISTENTE["$key"]="$value"
    fi
  done < "$FISIER_YAML"
fi

# === 5.2 Adaug IP-ul pfSense ===
EXISTENTE["pfsense_ip_lan"]="$PFSENSE_IP_LAN"

# === 5.3 Campuri ce vor fi completate de utilizator ===
declare -A CAMPURI=(
  ["pfsense_ip_wan"]="IP-ul WAN pfSense (OPTIONAL)"
  ["pfsense_interface_wan"]="Interfata WAN (ex. em0,vtnet0)"
  ["pfsense_interface_lan"]="Interfata LAN (ex. em0,vtnet1)"
  ["maxmind_account"]="Cont MaxMind"
  ["asn_token"]="ASN Token"
  ["maxmind_key"]="Cheie MaxMind"
  ["oinkcode"]="Oinkcode Snort"
  ["maxmind_geoipdb_uid"]="UID GeoIP DB"
  ["maxmind_geoipdb_key"]="Cheie GeoIP DB"
)

ORDINE=(
  "pfsense_ip_wan"
  "pfsense_interface_wan"
  "pfsense_interface_lan"
  "asn_token"
  "maxmind_account"
  "maxmind_key"
  "oinkcode"
  "maxmind_geoipdb_uid"
  "maxmind_geoipdb_key"
)

echo "[INFO] Completez fisierul YAML cu datele introduse..."

for CHEIE in "${ORDINE[@]}"; do
  LABEL=${CAMPURI[$CHEIE]}
  read -rp "Introdu valoarea pentru ${LABEL}: " VAL
  VAL_ESCAPED=$(printf '%s' "$VAL" | sed 's/"/\\"/g')
  EXISTENTE["$CHEIE"]="$VAL_ESCAPED"
done

# === 5.4 Scriem fisierul YAML curat ===
{
  echo "# Configurare pfSense Ansible"
  echo "# Generat automat la $(date)"

  for key in "${ORDINE[@]}"; do
    if [[ -n "${EXISTENTE[$key]}" ]]; then
      echo "$key: \"${EXISTENTE[$key]}\""
    fi
  done

  for key in "${!EXISTENTE[@]}"; do
    if [[ ! " ${ORDINE[*]} " =~ " ${key} " && -n "${EXISTENTE[$key]}" ]]; then
      echo "$key: \"${EXISTENTE[$key]}\""
    fi
  done
} > "$FISIER_YAML"

echo "[INFO] Fișierul all.yml a fost curățat și actualizat."

# === 6. Functie cauta sau instaleaza Python 3 ===
get_python3() {
  for cmd in python3 python3.12 python3.11 python3.10 python; do
    if command -v "$cmd" >/dev/null 2>&1; then
      echo "$cmd"
      return 0
    fi
  done

  echo "[WARN] Python 3 nu este instalat. Încerc să-l instalez..."
  sudo apt update && sudo apt install -y python3 || {
    echo "[EROARE] Instalarea Python 3 a eșuat. Ieșim."
    exit 1
  }

  if command -v python3 >/dev/null 2>&1; then
    echo "python3"
  else
    echo "[EROARE] Python 3 tot nu este disponibil după instalare. Ieșim."
    exit 1
  fi
}

# === 6.1 Rulez scriptul Python ===
PYTHON_CMD=$(get_python3)
"$PYTHON_CMD" /ansible-pfsense-setup/passcrypt.py

# === 7. Adaug fingerprint-ul in known_hosts daca lipseste ===
if ! ssh-keygen -F "$PFSENSE_IP_LAN" >/dev/null; then
  echo "[INFO] Adaug fingerprint-ul pfSense în known_hosts..."
  ssh-keyscan -H "$PFSENSE_IP_LAN" >> ~/.ssh/known_hosts 2>/dev/null
else
  echo "[INFO] Cheia SSH pentru $PFSENSE_IP_LAN exista deja in known_hosts."
fi

# === 8. Testeaza conexiunea SSH si ruleaza playbook ===
echo "[INFO] Verific conexiunea SSH catre pfSense..."
if ansible -i "$HOSTS_FILE" all -m ping; then
  echo "[OK] Conexiune reusita. Rulez playbook-ul..."
  ansible-playbook -i "$HOSTS_FILE" playbooks/deploy-config.yml
else
  echo "[EROARE] Conexiunea SSH a esuat. Verific daca pfSense este online si are IP-ul corect."
  exit 1
fi
