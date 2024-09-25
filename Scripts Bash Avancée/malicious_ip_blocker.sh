#!/bin/bash
# Blocage automatique des IPs malveillantes

BLOCKLIST="/etc/iptables/blocklist.txt"

log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a /var/log/blocklist.log
}

block_ips() {
    log_message "Blocage des IPs malveillantes..."

    if [ -f "$BLOCKLIST" ]; then
        while IFS= read -r ip; do
            iptables -A INPUT -s "$ip" -j DROP
            log_message "IP bloquée : $ip"
        done < "$BLOCKLIST"
    else
        log_message "Aucune liste de blocage trouvée."
    fi
}

block_ips