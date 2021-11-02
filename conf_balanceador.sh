#!/bin/bash

ip route add 10.10.10.0/24 dev enp0s3 src 10.10.10.2 table isp1
ip route add default via 10.10.10.1 table isp1

ip route add 20.20.20.0/24 dev enp0s8 src 20.20.20.2 table isp2
ip route add default via 20.20.20.1 table isp2


echo "dar probabilidad"
read var

iptables -t mangle -A PREROUTING -j CONNMARK --restore-mark
iptables -t mangle -A PREROUTING -m mark ! --mark 0 -j ACCEPT
iptables -t mangle -A PREROUTING -j MARK --set-mark 10
iptables -t mangle -A PREROUTING -m statistic --mode random --probability $var -j MARK --set-mark 20
iptables -t mangle -A PREROUTING -j CONNMARK --save-mark

iptables -t nat -A POSTROUTING -j MASQUERADE

ip rule add fwmark 20 table isp2 prio 33000
ip rule add fwmark 10 table isp1 prio 33000
# ip route del default
