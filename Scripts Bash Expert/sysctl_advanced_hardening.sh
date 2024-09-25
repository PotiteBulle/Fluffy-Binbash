#!/bin/bash
# Durcissement avancé des paramètres réseau avec sysctl

log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a /var/log/sysctl_advanced_hardening.log
}

apply_sysctl_hardening() {
    log_message "Application des paramètres sysctl..."

    # Empêcher le routing de paquets malveillants
    sysctl -w net.ipv4.conf.all.rp_filter=1
    sysctl -w net.ipv4.conf.default.rp_filter=1

    # Désactiver les redirections ICMP
    sysctl -w net.ipv4.conf.all.accept_redirects=0
    sysctl -w net.ipv6.conf.all.accept_redirects=0

    # Protection contre SYN flood
    sysctl -w net.ipv4.tcp_syncookies=1

    # Limitation des connexions TCP incomplètes pour éviter les attaques de type DOS
    sysctl -w net.ipv4.tcp_max_syn_backlog=2048

    # Désactivation de la réponse aux broadcasts ping
    sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1

    # Activé la protection contre les paquets malformés
    sysctl -w net.ipv4.conf.all.log_martians=1

    sysctl -p
    log_message "Paramètres sysctl avancés appliqués."
}

apply_sysctl_hardening