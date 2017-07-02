#!/bin/sh

# On vide les chaines prédéfinies
iptables -F
iptables -t nat -F
iptables -t mangle -F

# On supprime les règles des chaines personnelles
iptables -X
iptables -t nat -X
iptables -t mangle -X

# On passe les politiques de filtrage des chaines par défaut à DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP 

# Autoriser le trafic sur l'interface de loopback interne
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# On autorise les réponses 
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# On autorise le ping sortant et entrant (5 requetes par secondes)
iptables -A OUTPUT -p icmp -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j
ACCEPT
iptables -A INPUT -p icmp -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j
ACCEPT
iptables -A INPUT -p icmp -m limit --limit 5/s -j ACCEPT

# Anti Scan
iptables -A INPUT -p tcp --tcp-flags FIN,URG,PSH FIN,URG,PSH -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST RST -j DROP

# On rejete les nouvelle connexions TCP qui ne sont pas des packet SYN
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP

# On rejete les packets fragmentés 
iptables -A INPUT -f -j DROP

#On rejete les packets 'malformed' XMAS packets
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

# On rejete les packets NULL 
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

# On autorise les requetes DNS sortantes
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT

# On autorise les requetes Web sortantes 
iptables -A OUTPUT -p tcp -m multiport --dport 80,443 -j ACCEPT

# On autorise les connexions ssh entrantes
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# On rejete tout le reste (par sécu)
iptables -A INPUT -p all -j DROP
iptables -A OUTPUT -p all -j DROP
iptables -A FORWARD -p all -j DROP

echo "Utilisez iptables-save pour mettre à jour /etc/firewall.conf"