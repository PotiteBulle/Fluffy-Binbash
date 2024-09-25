#!/bin/bash
# Sécurisation avancée de SSH

log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a /var/log/ssh_advanced_security.log
}

secure_ssh() {
    SSH_CONFIG="/etc/ssh/sshd_config"
    
    log_message "Sécurisation avancée de SSH..."

    # Désactiver l'authentification par mot de passe
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' $SSH_CONFIG

    # Changer le port SSH par défaut
    sed -i 's/#Port 22/Port 2222/' $SSH_CONFIG

    # Limiter l'accès SSH uniquement aux utilisateurices spécifiques
    echo "AllowUsers utilisateurices@192.168.1.100" >> $SSH_CONFIG

    # Redémarrer SSH pour appliquer les changements
    systemctl restart sshd

    log_message "Configuration SSH avancée appliquée."
}

secure_ssh