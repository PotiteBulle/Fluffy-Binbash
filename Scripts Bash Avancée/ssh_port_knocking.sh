#!/bin/bash
# Script de port-knocking pour sécuriser SSH

log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a /var/log/port_knocking.log
}

configure_port_knocking() {
    log_message "Configuration du port-knocking pour SSH..."

    iptables -N KNOCKING
    iptables -A INPUT -p tcp --dport 7000 -m recent --name KNOCK1 --set -j DROP
    iptables -A INPUT -p tcp --dport 8000 -m recent --rcheck --name KNOCK1 --remove -m recent --name KNOCK2 --set -j DROP
    iptables -A INPUT -p tcp --dport 9000 -m recent --rcheck --name KNOCK2 --remove -m recent --name SSH --set -j ACCEPT

    log_message "Port-knocking configuré pour SSH."
}

configure_port_knocking