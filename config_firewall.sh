#!/bin/bash

# Script pour configurer un pare-feu de base avec iptables

echo "Configuration du pare-feu..."

# Vider les anciennes règles
sudo iptables -F
sudo iptables -X

# Refuser tout par défaut
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# Autoriser les connexions locales (loopback)
sudo iptables -A INPUT -i lo -j ACCEPT

# Autoriser les connexions déjà établies
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Autoriser les connexions SSH uniquement depuis une IP spécifique
TRUSTED_IP="192.168.1.100"
sudo iptables -A INPUT -p tcp --dport 22 -s $TRUSTED_IP -j ACCEPT

# Autoriser le trafic HTTP et HTTPS
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Sauvegarder les règles iptables
sudo iptables-save > /etc/iptables/rules.v4

echo "Pare-feu configuré avec succès."