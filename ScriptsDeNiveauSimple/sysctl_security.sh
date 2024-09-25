#!/bin/bash

echo "Sécurisation des paramètres réseau avec sysctl..."

# Désactiver l'IP forwarding
sudo sysctl -w net.ipv4.ip_forward=0

# Désactiver les ICMP redirects
sudo sysctl -w net.ipv4.conf.all.accept_redirects=0
sudo sysctl -w net.ipv4.conf.default.accept_redirects=0

# Désactiver la source routing
sudo sysctl -w net.ipv4.conf.all.accept_source_route=0
sudo sysctl -w net.ipv6.conf.all.accept_source_route=0

# Activer ces changements de manière persistante
sudo sysctl -p

echo "Paramètres réseau sécurisés."