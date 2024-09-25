#!/bin/bash
# Détection et mitigation des attaques DDoS avec iptables et netstat

log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a /var/log/ddos_mitigation.log
}

monitor_ddos() {
    log_message "Début de la surveillance des connexions pour détection de potentiel attaques DDoS..."

    # Vérification des connexions actives toutes les 10 secondes
    while true; do
        netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n > /tmp/ip_connexions.log

        while read count ip; do
            if [ "$count" -gt 100 ]; then
                log_message "Mitigation DDoS : L'IP $ip effectue trop de connexions ($count connexions)."
                iptables -A INPUT -s "$ip" -j DROP
            fi
        done < /tmp/ip_connexions.log

        sleep 10
    done
}

monitor_ddos