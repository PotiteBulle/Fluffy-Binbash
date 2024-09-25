#!/bin/bash
# Durcissement des paramètres réseau avec sysctl

log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a /var/log/sysctl_hardening.log
}

secure_sysctl() {
    log_message "Application des paramètres sysctl..."
    sysctl -w net.ipv4.ip_forward=0
    sysctl -w net.ipv4.conf.all.accept_redirects=0
    sysctl -w net.ipv4.conf.default.accept_redirects=0
    sysctl -w net.ipv4.conf.all.send_redirects=0
    sysctl -w net.ipv4.conf.default.send_redirects=0
    sysctl -w net.ipv4.conf.all.accept_source_route=0
    sysctl -w net.ipv4.conf.default.accept_source_route=0
    sysctl -w net.ipv6.conf.all.accept_source_route=0
    sysctl -w net.ipv6.conf.default.accept_source_route=0
    sysctl -w net.ipv4.tcp_syncookies=1
    sysctl -p
    log_message "Paramètres sysctl appliqués."
}

secure_sysctl