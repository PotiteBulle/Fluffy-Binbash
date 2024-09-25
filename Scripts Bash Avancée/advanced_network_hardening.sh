#!/bin/bash

# Script avancé pour sécuriser le réseau sous Linux

# Variables
LOGFILE="/var/log/advanced_network_security.log"
BLOCKLIST="/etc/iptables/blocklist.txt"
TRUSTED_IP="192.168.1.100"   # Remplacer par l'IP de confiance pour SSH
KNOCK_PORTS=(7000 8000 9000) # Ports pour le port-knocking
ALERT_EMAIL="admin@votresite.com" # Adresse email pour les alertes

# Fonction pour enregistrer les logs
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOGFILE"
}

# 1. Durcissement des paramètres de sécurité réseau avec sysctl
secure_sysctl() {
    log_message "Application des paramètres sysctl..."
    sudo sysctl -w net.ipv4.ip_forward=0
    sudo sysctl -w net.ipv4.conf.all.accept_redirects=0
    sudo sysctl -w net.ipv4.conf.default.accept_redirects=0
    sudo sysctl -w net.ipv4.conf.all.send_redirects=0
    sudo sysctl -w net.ipv4.conf.default.send_redirects=0
    sudo sysctl -w net.ipv4.conf.all.accept_source_route=0
    sudo sysctl -w net.ipv4.conf.default.accept_source_route=0
    sudo sysctl -w net.ipv6.conf.all.accept_source_route=0
    sudo sysctl -w net.ipv6.conf.default.accept_source_route=0
    sudo sysctl -w net.ipv4.tcp_syncookies=1
    sudo sysctl -p
    log_message "Paramètres sysctl appliqués."
}

# 2. Configuration avancée du pare-feu avec iptables
configure_iptables() {
    log_message "Configuration du pare-feu avancé..."

    # Vider les règles existantes
    sudo iptables -F
    sudo iptables -X

    # Politique par défaut : bloquer toutes les connexions entrantes
    sudo iptables -P INPUT DROP
    sudo iptables -P FORWARD DROP
    sudo iptables -P OUTPUT ACCEPT

    # Autoriser les connexions locales (loopback)
    sudo iptables -A INPUT -i lo -j ACCEPT

    # Autoriser les connexions existantes et relatives
    sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    # Autoriser SSH uniquement via le port knocking (expliqué dans une fonction à part)
    sudo iptables -A INPUT -p tcp --dport 22 -m recent --name SSH --rcheck --seconds 60 -j ACCEPT

    # Autoriser HTTP et HTTPS
    sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

    # Autoriser le ping (facultatif, souvent bloqué pour la sécurité)
    sudo iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

    # Bloquer les IPs malveillantes
    if [ -f "$BLOCKLIST" ]; then
        log_message "Blocage des IPs malveillantes listées..."
        while IFS= read -r ip; do
            sudo iptables -A INPUT -s "$ip" -j DROP
            log_message "IP bloquée : $ip"
        done < "$BLOCKLIST"
    fi

    # Sauvegarder les règles iptables
    sudo iptables-save | sudo tee /etc/iptables/rules.v4

    log_message "Pare-feu avancé configuré avec succès."
}

# 3. Mise en place du port-knocking pour protéger SSH
configure_port_knocking() {
    log_message "Mise en place du port-knocking pour SSH..."

    # Nettoyer les anciennes règles de port-knocking
    sudo iptables -N KNOCK
    sudo iptables -F KNOCK

    # Règle de base pour déclencher le port-knocking
    sudo iptables -A INPUT -p tcp --dport ${KNOCK_PORTS[0]} -m recent --name KNOCK1 --set -j DROP
    sudo iptables -A INPUT -p tcp --dport ${KNOCK_PORTS[1]} -m recent --name KNOCK2 --rcheck --seconds 10 -m recent --name KNOCK1 --remove -j DROP
    sudo iptables -A INPUT -p tcp --dport ${KNOCK_PORTS[2]} -m recent --name SSH --set --rcheck --seconds 10 -m recent --name KNOCK2 --remove -j ACCEPT

    log_message "Port-knocking activé pour protéger l'accès SSH."
}

# 4. Surveillance des tentatives de connexion SSH échouées
monitor_ssh_attempts() {
    log_message "Surveillance des tentatives de connexion SSH échouées..."

    # Surveiller les tentatives échouées via le journal auth.log
    sudo tail -f /var/log/auth.log | grep "Failed password" | while read -r line ; do
        ATTEMPT_IP=$(echo $line | awk '{print $NF}')
        log_message "Tentative échouée de l'IP : $ATTEMPT_IP"
        echo "Tentative échouée de l'IP : $ATTEMPT_IP" | mail -s "Alerte SSH" $ALERT_EMAIL
    done
}

# 5. Sécuriser la configuration SSH
secure_ssh() {
    log_message "Renforcement de la configuration SSH..."
    SSH_CONFIG="/etc/ssh/sshd_config"

    # Désactiver l'authentification par mot de passe
    sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' $SSH_CONFIG
    sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' $SSH_CONFIG

    # Restreindre l'accès SSH uniquement aux utilisateurices autorisés
    echo "AllowUsers votre_utilisateurices@${TRUSTED_IP}" | sudo tee -a $SSH_CONFIG

    # Redémarrer le service SSH pour appliquer les modifications
    sudo systemctl restart sshd

    log_message "Configuration SSH sécurisée."
}

# 6. Fonction principale pour exécuter toutes les étapes
main() {
    secure_sysctl
    configure_iptables
    configure_port_knocking
    secure_ssh
    monitor_ssh_attempts &
    log_message "Sécurisation réseau avancée terminée."
}

main