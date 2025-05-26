pfSense Custom Firewall Project

Un proiect de securitate cibernetică care transformă un mini-PC (NUC) cu resurse limitate într-un firewall avansat, capabil să ofere mai multă protecție încât un router obișnuit de la ISP.

:dart: Obiectiv

Configurarea unui firewall personalizat cu pfSense, care include:

Detectarea amenințărilor prin Suricata (IDS/IPS)

Blocare trafic nedorit prin pfBlockerNG (inclusiv GeoIP)

Serviciu VPN pentru acces remote securizat (OpenVPN)

Integrare opțională cu Telegram pentru comenzi la distanță

:hammer_and_wrench: Cerințe hardware

Intel NUC cu 4 core CPU @ 1.5GHz

4GB RAM

64GB SSD

2 interfețe de rețea (WAN/LAN sau WAN/WiFi)

:floppy_disk: Structura repository-ului

pfsense-custom-firewall/
|
├── config/
│   └── exported_config.xml         # Configurația pfSense exportată (curățată de date sensibile)
|
├── scripts/
│   ├── postinstall.sh              # Script CLI pentru automatizare după instalare pfSense
│   ├── telegram_integration.sh     # Script de integrare Telegram
│   └── ddns_setup.md               # Ghid configurare Dynamic DNS
|
├── docs/
│   ├── vpn_setup.md                # Pași configurare OpenVPN
│   ├── geoip_blocking.md           # Setări pfBlockerNG + blocare țări
│   └── suricata_config.md          # Ghid Suricata
|
├── assets/
│   ├── diagram-topology.png        # Diagrama rețelelor (WAN/LAN/WiFi)
│   └── screenshots/                # Capturi de ecran din interfața pfSense
|
├── .gitignore
├── LICENSE
└── README.md                       # Acest fișier

:rocket: Instalare rapidă

1. Instalează pfSense pe un VM sau bare-metal

Link: https://www.pfsense.org/download/

2. Aplică configurația exportată

Diagnostics > Backup & Restore > Restore

Selectează fișierul config/exported_config.xml

3. Configurează Dynamic DNS (opțional)

Vezi scripts/ddns_setup.md

4. Adaugă integrarea Telegram (opțional)

Vezi scripts/telegram_integration.sh

:closed_lock_with_key: Servicii incluse

Serviciu

Descriere

Suricata

Monitorizare rețea, semnături de atac (IDS/IPS)

pfBlockerNG

Blocare IP-uri, reclame, GeoIP filtering

OpenVPN

Acces securizat de la distanță

Telegram Bot

Control firewall via mesaje (opțional)

:bar_chart: Diagrama rețelelor

 [Internet] 
     | 
     | (ISP Router cu Port Forwarding)
 [WAN - 192.168.1.21] pfSense [LAN - 192.168.10.1] 
                                  |
                              [WiFi AP / Switch / PC-uri]

:notebook: Exemple utile

Acces interfață pfSense: https://192.168.10.1

Testare GeoIP blocking: accesează site din Burundi / Rusia

VPN: Conectează-te din altă rețea cu fișierul .ovpn

:warning: Securitate

Schimbă parolele implicite!

Folosește porturi custom pentru OpenVPN

Activează SSL pentru WebGUI

Nu include certificatul original în acest repo!

:page_facing_up: Licența

MIT License

Pentru contribuții sau feedback, deschide un issue sau trimite un pull request.

Lucrare de disertație - Securitate Cibernetică
Autor: [Numele tău aici]
An: 2025
