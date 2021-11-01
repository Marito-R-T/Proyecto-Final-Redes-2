#!/bin/sh

# clean old firewall
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# redirect HTTP to locally installed Squid instance
iptables -t nat -A PREROUTING -i ens160 -p tcp --dport 80 -j REDIRECT --to-ports 3126

# redirect HTTPS to locally installed Squid instance
iptables -t nat -A PREROUTING -i ens160 -p tcp --dport 443 -j REDIRECT --to-ports 3127



# http_port 3128

# acl blocked_sites dstdomain "/etc/squid/blocked_sites"
# http_access deny blocked_sites
# systemctl restart Squid

# comento todos los port que no sean http o https,
# comento todo lo de ips LANS
# agrego la ip 30.30.30.1/24

############## DESCOMENTAR ##############
# cache_effective_user proxy
# cache_effective_group proxy
