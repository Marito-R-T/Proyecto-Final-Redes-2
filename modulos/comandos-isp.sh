#!/bin/bash

#VARIABLES
INTERFACEIN="enp0s8"
INTERFACEOUT="ifb0"
IP="${isp}0.${isp}0.${isp}0.1"

#filtros para aplicar el ancho de banda de subida como de bajada
IN="/usr/sbin/tc filter add dev ${INTERFACEIN} parent 1:0 protocol ip prio 1 u32 match ip dst"
OUT="/usr/sbin/tc filter add dev ${INTERFACEOUT} parent 1:0 protocol ip prio 1 u32 match ip dst"
PUERTO="match ip sport"
REGLA="0Xffff"

#insertar modulo ifb, asignando el numero de interfaces virutales
#que se necesita por defecto es 2
IFB="sudo modprobe ifb numifbs=1"

#limpiar interfaces
C1="ip link set dev ${INTERFACEOUT} up"
C2="/usr/sbin/tc qdisc del dev ${INTERFACEIN} root 2>/dev/null"
C3="/usr/sbin/tc qdisc del dev ${INTERFACEIN} ingress 2>/dev/null"
C4="/usr/sbin/tc qdisc del dev ${INTERFACEOUT} root 2>/dev/null"

#habilitar interfaz para upload
C5="/usr/sbin/tc qdisc add dev ${INTERFACEIN} handle ffff: ingress"
C6="/usr/sbin/tc filter add dev ${INTERFACEIN} parent ffff: protocol ip u32 match u32 0 0 action mirred egress redirect dev ${INTERFACEOUT}"

#creando enlace para bajada
COMANDO_IN_ROOT="/usr/sbin/tc  qdisc add dev ${INTERFACEIN} root handle 1: htb"
COMANDO_IN_ENLACE="/usr/sbin/tc  class add dev ${INTERFACEIN} parent 1: classid 1:10 htb rate 2000kbit ceil 2000kbit"
COMANDO_EXTRA_IN="/usr/sbin/tc qdisc add dev ${INTERFACEIN} parent 1:10 handle 10: sfq perturb 10"

#creando enlace para subida

COMANDO_OUT_ROOT="/usr/sbin/tc  qdisc add dev ${INTERFACEOUT} root handle 1: htb"
COMANDO_OUT_ENLACE="/usr/sbin/tc  class add dev ${INTERFACEOUT} parent 1: classid 1:10 htb rate 50kbit ceil 50kbit"
COMANDO_EXTRA_OUT="/usr/sbin/tc qdisc add dev ${INTERFACEOUT} parent 1:10 handle 10: sfq perturb 10"

#asignando ip a enlace
DOWNLOAD="${IN} ${IP} flowid 1:10"
UPLOAD="${OUT} ${IP} flowid 1:10"
