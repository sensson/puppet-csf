# This file is managed by puppet and is used to allow
# VPN connections if you're using something like OpenVPN

#iptables -A INPUT -i eth0 -p tcp --dport 1723 -j ACCEPT
#iptables -A INPUT -i eth0 -p gre -j ACCEPT
#iptables -A OUTPUT -p gre -j ACCEPT
#iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
#iptables -A FORWARD -i ppp+ -o eth0 -j ACCEPT
#iptables -A FORWARD -i eth0 -o ppp+ -j ACCEPT

# new
#iptables -A INPUT -i ppp+ -j ACCEPT
#iptables -A INPUT -p tcp -m tcp --dport 1723 -j ACCEPT
#iptables -A INPUT -p gre -j ACCEPT
#iptables -A FORWARD -j ACCEPT
#iptables -A OUTPUT -o ppp+ -j ACCEPT
#iptables -A OUTPUT -p gre -j ACCEPT
#iptables -A POSTROUTING -o eth0 -j MASQUERADE
#iptables -A POSTROUTING -o ppp+ -j MASQUERADE

# last attempt
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A INPUT -p gre -j ACCEPT
iptables -A OUTPUT -p gre -j ACCEPT
iptables -A FORWARD -i ppp+ -o eth0 -p ALL -j ACCEPT
iptables -A FORWARD -i eth0 -o ppp+ -p ALL -j ACCEPT
iptables -A FORWARD -i ppp+ -j ACCEPT