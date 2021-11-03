#!/bin/bash

WAN1=10.10.10.0/24
IF1=enp0s3
IP1=10.10.10.2
T1=isp1
GW1=10.10.10.1

WAN2=20.20.20.0/24
IF2=enp0s8
IP2=20.20.20.2
T2=isp2
GW2=20.20.20.1

while IFS= read -r line; do
  if [[ "$line" == "ISP1"* ]]; then
    ISP1=${line:5}
  elif [[ "$line" == "ISP2"* ]]; then
    ISP2=${line:5}
  fi
done < '/home/marito/pesos.txt'

PROB1=$(echo "scale=2; $ISP1 / ($ISP1 + $ISP2)" | bc)
PROB2=$(echo "scale=2; 1 - $PROB1" | bc)

ip route del default
ip route del $WAN1 dev $IF1 src $IP1 table $T1
ip route del default via $GW1 table $T1
ip route del $WAN2 dev $IF2 src $IP2 table $T2
ip route del default via $GW2 table $T2

ip route add $WAN1 dev $IF1 src $IP1 table $T1
ip route add default via $GW1 table $T1

ip route add $WAN2 dev $IF2 src $IP2 table $T2
ip route add default via $GW2 table $T2

# RESTART MANGLE AND NAT
iptables -t nat -F
iptables -t mangle -F

# dinamico
ejecutarDinamico() {
  while read -r line; do
    readarray -d , -t PARAMS <<< $line
    if [[ ${PARAMS[3]} == 'ISP1' ]]; then
      iptables -t nat -A PREROUTING -s ${PARAMS[0]} -p ${PARAMS[2]} --dport ${PARAMS[1]} -o $IF1 -j MASQUERADE
    elif [[ ${PARAMS[3]} == 'ISP2' ]]; then
      iptables -t nat -A PREROUTING -s ${PARAMS[0]} -p ${PARAMS[2]} --dport ${PARAMS[1]} -o $IF2 -j MASQUERADE
    else
      iptables -t nat -A PREROUTING -s ${PARAMS[0]} -p ${PARAMS[2]} --dport ${PARAMS[1]} -j MASQUERADE
    fi
  done < '/home/marito/LBrules.txt'
}


# MANGLE PREROUTING
iptables -t mangle -A PREROUTING -j CONNMARK --restore-mark
iptables -t mangle -A PREROUTING -m mark ! --mark 0 -j ACCEPT
iptables -t mangle -A PREROUTING -j MARK --set-mark 10
iptables -t mangle -A PREROUTING -m statistic --mode random --probability $var -j MARK --set-mark 20
iptables -t mangle -A PREROUTING -j CONNMARK --save-mark

# NAT MASQUERADE
# iptables -t nat -A POSTROUTING -j MASQUERADE
ejecutarDinamico

# IP RULES PRIO
ip rule add fwmark 20 table isp2 prio 33000
ip rule add fwmark 10 table isp1 prio 33000

# IP FORWARD
echo "1" > /proc/sys/net/ipv4/ip_forward
