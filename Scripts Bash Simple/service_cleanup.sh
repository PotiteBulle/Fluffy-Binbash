#!/bin/bash

# Liste des services à désactiver
SERVICES_TO_DISABLE=("telnet" "ftp" "rlogin")

echo "Désactivation des services non sécurisés..."

for service in "${SERVICES_TO_DISABLE[@]}"; do
    sudo systemctl stop "$service"
    sudo systemctl disable "$service"
    echo "Service désactivé : $service"
done

echo "Tous les services non sécurisés ont été désactivés."