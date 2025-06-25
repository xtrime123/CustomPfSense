# 🔐 Automatizare pfSense pe sistem low-spec (NUC + Proxmox)

Acest proiect automatizează configurarea și securizarea unui firewall pfSense, rulând într-un mediu virtualizat Proxmox, cu resurse hardware limitate. Soluția folosește Ansible pentru a aplica o configurație completă, personalizată.

---

## 🚀 Obiectivul proiectului

Configurare complet automatizată pentru pfSense:
- Fără configurare manuală post-instalare
- Setări de firewall, VPN, DNSBL, blocare GeoIP
- Instalare extensii de securitate (Suricata, pfBlockerNG, OpenVPN)
- Resetare parole, interfețe și reguli

---

## ⚙️ Instalare pfSense de la zero în Proxmox

1. **Descarcă imaginea pfSense ISO:**
   [https://www.pfsense.org/download/](https://www.pfsense.org/download/)

2. **Încarcă ISO-ul în Proxmox (prin SCP):** sau manual.
   ```bash
   scp pfSense-CE.iso root@proxmox:/var/lib/vz/template/iso/
Creează o mașină virtuală (VM) în Proxmox:

Alocare: 512 MB RAM, 1 core, 20 GB HDD

2 interfețe rețea (WAN – vtnet0, LAN – vtnet1)

Boot de pe ISO și urmează pașii de instalare pfSense

După instalare, accesează interfața web pfSense (vezi in Proxmox ip-ul alocat) :

ex. URL:  https://192.168.1.1

Username: admin, Parolă implicită: pfsense

🤖 Automatizare cu Ansible
Rulată dintr-un container Debian pe Proxmox

Comanda de pornire:

bash
Copy
Edit
./install.sh
Scriptul:

Verifică dacă Ansible este instalat

Solicită informații esențiale (IP pfSense, chei API, parole)

Generează automat configurația (all.yml)

Aplică configurația doar când conexiunea SSH este activă

🔒 Funcționalități implementate
✅ Resetare parole administrator și VPN

✅ Configurare interfețe WAN/LAN

✅ Activare și configurare:

Suricata – detecție intruziuni

pfBlockerNG – filtrare DNSBL, IP și GeoIP

OpenVPN – acces securizat

✅ Import automat reguli de firewall

✅ Test de conectivitate la fiecare pas

✅ Upload config.xml pe pfSense

## 📦 Instrucțiuni rapide de utilizare

1. **Asigură-te că pfSense este instalat și funcțional în Proxmox.**
   - Trebuie să ai două interfețe de rețea (WAN și LAN)
   - Să știi IP-ul LAN al pfSense (ex: `192.168.1.1`) - sau logeaza-te pe routerul de la ISP si afla care este IP-ul oferit pentru Proxmox/pfSense

2. **Pornește un container Debian în Proxmox (sau VM)**
   - Conectat în aceeași rețea cu pfSense

3. **Clonează acest repository în container:**
   ```bash
   git clone https://github.com/xtrime123/CustomPfSense
   cd CustomPfSense
