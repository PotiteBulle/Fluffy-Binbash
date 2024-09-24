#!/bin/bash

echo "Installation et configuration des mises à jour automatiques..."

# Installer le paquet unattended-upgrades
sudo apt update
sudo apt install unattended-upgrades -y

# Activer les mises à jour automatiques
sudo dpkg-reconfigure -plow unattended-upgrades

echo "Les mises à jour automatiques sont activées."