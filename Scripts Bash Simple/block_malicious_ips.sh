#!/bin/bash

# Fichier contenant les IP à bloquer
BLOCKLIST="/etc/iptables/blocklist.txt"

# Vérifier si le fichier existe
if [ ! -f "$BLOCKLIST" ]; then
    echo "Fichier blocklist non trouvé !"
    exit 1
fi

echo "Blocage des IP malveillantes..."

while IFS= read -r ip; do
    sudo iptables -A INPUT -s "$ip" -j DROP
    echo "IP bloquée : $ip"
done < "$BLOCKLIST"

# Sauvegarder les règles iptables
sudo iptables-save > /etc/iptables/rules.v4

echo "Toutes les IP malveillantes ont été bloquées."