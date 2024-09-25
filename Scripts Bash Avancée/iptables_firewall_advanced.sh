#!/bin/bash
# Configuration du pare-feu avancé avec iptables

log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a /var/log/iptables_firewall.log
}

configure_iptables() {
    log_message "Configuration du pare-feu iptables..."

    # Vider les règles existantes
    iptables -F
    iptables -X

    # Politique par défaut : tout bloquer
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT

    # Autoriser les connexions locales (loopback)
    iptables -A INPUT -i lo -j ACCEPT

    # Autoriser les connexions existantes et relatives
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    # Autoriser SSH uniquement pour des IPs spécifiques
    iptables -A INPUT -p tcp -s 192.168.1.100 --dport 22 -j ACCEPT

    # Autoriser HTTP/HTTPS
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT

    # Bloquer les tentatives de scan de port
    iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
    iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
    iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP

    log_message "Pare-feu configuré."
}

configure_iptables