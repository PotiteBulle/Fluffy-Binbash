#!/bin/bash

echo "Audit de sécurité du réseau en cours..."

# Vérifier les ports ouverts avec netstat
echo "Vérification des ports ouverts..."
sudo netstat -tulpn

# Vérifier l'état du pare-feu avec iptables
echo "État actuel du pare-feu (iptables)..."
sudo iptables -L

# Vérifier les services en cours d'exécution
echo "Liste des services en cours d'exécution..."
sudo systemctl list-units --type=service --state=running

# Vérifier les utilisateurs avec des connexions actives
echo "Utilisateurices actuellement connectés..."
who

# Vérifier les tentatives de connexion SSH échouées
echo "Tentatives de connexion SSH échouées..."
sudo grep "Failed password" /var/log/auth.log

echo "Audit de sécurité terminé."