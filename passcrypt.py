import crypt
import getpass
import re
import os

# === 1. Cere parolele ===
parola_root = getpass.getpass("Introdu parola pentru root GUI: ")
parola_vpn = getpass.getpass("Introdu parola pentru VPN user: ")

# === 2. Generează hash bcrypt (cu înlocuire $2b$ → $2y$) ===
def gen_hash(parola):
    salt = crypt.mksalt(crypt.METHOD_BLOWFISH)
    hashat = crypt.crypt(parola, salt)
    return hashat.replace("$2b$", "$2y$")

hash_root = gen_hash(parola_root)
hash_vpn = gen_hash(parola_vpn)

# === 3. Calea fișierului YAML ===
cale_fisier = "/ansible-pfsense-setup/CustomPfSense/group_vars/all.yml"

if not os.path.exists(cale_fisier):
    print(f"[EROARE] Fișierul {cale_fisier} nu există.")
    exit(1)

# === 4. Citim conținutul original ===
with open(cale_fisier, "r", encoding="utf-8") as f:
    linii = f.readlines()

# === 5. Caută și actualizează / adaugă hash-urile ===
found_root = False
found_vpn = False
linii_noi = []

for linie in linii:
    if linie.strip().startswith("root_password_hash:"):
        linii_noi.append(f'root_password_hash: "{hash_root}"\n')
        found_root = True
    elif linie.strip().startswith("vpn_user_password_hash:"):
        linii_noi.append(f'vpn_user_password_hash: "{hash_vpn}"\n')
        found_vpn = True
    else:
        linii_noi.append(linie)

# Dacă lipsesc, le adăugăm la final
if not found_root:
    linii_noi.append(f'root_password_hash: "{hash_root}"\n')
if not found_vpn:
    linii_noi.append(f'vpn_user_password_hash: "{hash_vpn}"\n')

# === 6. Scriem fișierul înapoi ===
with open(cale_fisier, "w", encoding="utf-8") as f:
    f.writelines(linii_noi)

print("[INFO] Hash-urile au fost actualizate sau adăugate cu succes.")
