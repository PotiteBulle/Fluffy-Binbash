#!/bin/bash
# Surveillance des tentatives de connexion SSH échouées

log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a /var/log/ssh_attempts.log
}

monitor_ssh_attempts() {
    log_message "Surveillance des tentatives de connexion SSH..."

    tail -f /var/log/auth.log | grep "Failed password" | while read -r line ; do
        ATTEMPT_IP=$(echo $line | awk '{print $NF}')
        log_message "Tentative échouée de l'IP : $ATTEMPT_IP"
        echo "Tentative échouée de l'IP : $ATTEMPT_IP" | mail -s "Alerte SSH" admin@votresite.com # Adresse email pour les alertes
    done
}

monitor_ssh_attempts