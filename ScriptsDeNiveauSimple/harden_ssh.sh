#!/bin/bash

SSH_CONFIG="/etc/ssh/sshd_config"

echo "Renforcement de la configuration SSH..."

# Désactiver l'authentification par mot de passe
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' $SSH_CONFIG

# Désactiver la connexion root
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' $SSH_CONFIG

# Restreindre SSH à une IP spécifique
echo "AllowUsers votre_utilisateurice@192.168.1.100" | sudo tee -a $SSH_CONFIG

# Redémarrer le service SSH
sudo systemctl restart sshd

echo "Configuration SSH renforcée."