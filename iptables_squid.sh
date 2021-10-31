#!/bin/sh

# squid proxy's IP address (which is attached to eth0)
SQUID_SERVER=`ifconfig enp0s9 | sed -ne 's/.*inet addr:([^ ]*).*/1/p'`

# interface connected to WAN
INTERNET="enp0s9"

# interface connected to LAN
LAN_IN="enp0s8"

# Squid port
SQUID_PORT="3128"

# clean old firewall
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# load iptables modules for NAT masquerade and IP conntrack
modprobe ip_conntrack
modprobe ip_conntrack_ftp

# define necessary redirection for incoming HTTP traffic (e.g., 80)
iptables -t nat -A PREROUTING -i $LAN_IN -p tcp --dport 80 -j REDIRECT --to-port $SQUID_PORT

# forward locally generated http traffic to Squid
iptables -t nat -A OUTPUT -p tcp --dport 80 -m owner --uid-owner proxy -j ACCEPT
iptables -t nat -A OUTPUT -p tcp --dport 80 -j REDIRECT --to-ports $SQUID_PORT

# forward the rest of non-HTTP traffic
iptables --table nat --append POSTROUTING --out-interface $INTERNET -j MASQUERADE
iptables --append FORWARD --in-interface $INTERNET -j ACCEPT

# enable IP forwarding for proxy
echo 1 > /proc/sys/net/ipv4/ip_forward


# redirect HTTP to locally installed Squid instance
#iptables -t nat -A PREROUTING -i ens160 -p tcp --dport 80 -j REDIRECT --to-ports 3126

# redirect HTTPS to locally installed Squid instance
#iptables -t nat -A PREROUTING -i ens160 -p tcp --dport 443 -j REDIRECT --to-ports 3127
