#!/bin/bash
# Surveillance réseau avancée avec fail2ban et iptables

log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | sudo tee -a /var/log/network_surveillance.log
}

configure_fail2ban() {
    log_message "Configuration de fail2ban..."

    # Installer et configurer fail2ban pour surveiller SSH
    sudo apt update && sudo apt install fail2ban mailutils -y

    # Configurer fail2ban pour bannir après 5 tentatives échouées
    echo -e "[sshd]\nenabled = true\nfilter = sshd\nlogpath = /var/log/auth.log\nmaxretry = 5\nbantime = 3600" | sudo tee /etc/fail2ban/jail.local

    sudo systemctl restart fail2ban
    log_message "Fail2ban configuré et en cours d'exécution."
}

monitor_iptables() {
    log_message "Surveillance en temps réel des connexions suspectes avec iptables..."

    # Assurez-vous que iptables logge les connexions suspectes
    sudo tail -f /var/log/syslog | grep --line-buffered "iptables" | while read line; do
        echo "Alerte iptables: $line" | mail -s "Alerte Réseau" admin@votresite.com # Adresse email pour les alertes
    done
}

configure_fail2ban
monitor_iptables &