#!/bin/bash
# Configuration experte du pare-feu avec iptables

log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a /var/log/iptables_expert_firewall.log
}

configure_firewall() {
    log_message "Configuration avancée du pare-feu avec iptables..."

    # Vider les règles actuelles
    iptables -F
    iptables -X

    # Politique par défaut : tout bloquer
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT

    # Autoriser les connexions locales
    iptables -A INPUT -i lo -j ACCEPT

    # Autoriser les connexions existantes et relatives
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    # Limiter les connexions SSH à 3 par minute depuis la même IP (anti-brute force)
    iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set
    iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 3 -j DROP

    # Autoriser HTTP et HTTPS
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT

    # Limiter les connexions sur HTTP à 20 connexions par minute par IP
    iptables -A INPUT -p tcp --dport 80 -m state --state NEW -m recent --set
    iptables -A INPUT -p tcp --dport 80 -m state --state NEW -m recent --update --seconds 60 --hitcount 20 -j DROP

    # Bloquer les ports inutilisés
    iptables -A INPUT -p tcp --dport 23 -j DROP  # Bloquer Telnet
    iptables -A INPUT -p tcp --dport 445 -j DROP # Bloquer SMB

    log_message "Pare-feu configuré."
}

configure_firewall