#!/bin/bash
# shellcheck source=./modulos/comandos-isp.sh

echo 'Va ejecutar el isp1 o el isp2? 1/2'
read isp

source ./modulos/comandos-isp.sh

#configuración isp
ISPUP="ip addr add ${isp}0.${isp}0.${isp}0.1/24 dev ${INTERFACEIN}"
ISPDOWN="ip addr add ${isp}0.${isp}0.${isp}0.2/24 dev ${INTERFACEOUT}"

#limpiar
/usr/sbin/tc qdisc del dev ${INTERFACEIN} root
/usr/sbin/tc qdisc del dev ${INTERFACEIN} ingress
/usr/sbin/tc qdisc del dev ${INTERFACEOUT} root

echo "Desea continuar?"
read opc
echo $IP

if [[ $opc == 1 ]]; then
  echo 'ejecutando ispup'
  $ISPUP
  ejecutarComandos
fi
