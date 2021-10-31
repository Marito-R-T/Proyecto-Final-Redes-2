#!/bin/bash

#VARIABLES
INTERFACEIN="enp0s8"
INTERFACEOUT="ifb0"
IP="${isp}0.${isp}0.${isp}0.1"

#filtros para aplicar el ancho de banda de subida como de bajada
IN="filter add dev ${INTERFACEIN} parent 1:0 protocol ip prio 1 u32 match ip dst"
OUT="filter add dev ${INTERFACEOUT} parent 1:0 protocol ip prio 1 u32 match ip src"
PUERTO="match ip sport"
REGLA="0Xffff"


ejecutarComandos() {
  echo "empieza a ejecutar comandos"
  #insertar modulo ifb, asignando el numero de interfaces virutales
  #que se necesita por defecto es 2
  modprobe ifb numifbs=1

  #limpiar interfaces
  ip link set dev ${INTERFACEOUT} up
  /usr/sbin/tc qdisc del dev ${INTERFACEIN} root 2>/dev/null
  /usr/sbin/tc qdisc del dev ${INTERFACEIN} ingress 2>/dev/null
  /usr/sbin/tc qdisc del dev ${INTERFACEOUT} root 2>/dev/null

  #habilitar interfaz para upload
  /usr/sbin/tc qdisc add dev ${INTERFACEIN} handle ffff: ingress
  /usr/sbin/tc filter add dev ${INTERFACEIN} parent ffff: protocol ip u32 match u32 0 0 action mirred egress redirect dev ${INTERFACEOUT}

  #creando enlace para bajada
  /usr/sbin/tc qdisc add dev ${INTERFACEIN} root handle 1: htb default 10
  if [[ $isp == 1 ]]; then
    /usr/sbin/tc class add dev ${INTERFACEIN} parent 1: classid 1:10 htb rate 1024kbit ceil 1024kbit
  elif [[ $isp == 2 ]]; then
    /usr/sbin/tc class add dev ${INTERFACEIN} parent 1: classid 1:10 htb rate 2048kbit ceil 2048kbit
  fi
  /usr/sbin/tc qdisc add dev ${INTERFACEIN} parent 1:10 handle 10: sfq perturb 10

  #creando enlace para subida
  /usr/sbin/tc  qdisc add dev ${INTERFACEOUT} root handle 1: htb default 10
  if [[ $isp == 1 ]]; then
    /usr/sbin/tc  class add dev ${INTERFACEOUT} parent 1: classid 1:10 htb rate 1024kbit ceil 1024kbit
  elif [[ $isp == 2 ]]; then
    /usr/sbin/tc  class add dev ${INTERFACEOUT} parent 1: classid 1:10 htb rate 512kbit ceil 512kbit
  fi
  /usr/sbin/tc qdisc add dev ${INTERFACEOUT} parent 1:10 handle 10: sfq perturb 10

  #asignando ip a enlace
  /usr/sbin/tc ${IN} ${IP} flowid 1:10
  /usr/sbin/tc ${OUT} ${IP} flowid 1:10
}
