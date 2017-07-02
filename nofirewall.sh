#!/bin/sh

# On vide les chaines prédéfinies
iptables -F
iptables -t nat -F
iptables -t mangle -F

# On supprime les règles des chaines personnelles
iptables -X
iptables -t nat -X
iptables -t mangle -X

# On passe les politiques de filtrage des chaines par défaut à ACCEPT
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT 
iptables -P OUTPUT ACCEPT 

echo "Utilisez iptables-save pour mettre à jour /etc/firewall.conf"