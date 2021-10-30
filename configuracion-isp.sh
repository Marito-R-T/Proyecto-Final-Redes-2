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
  $ISPUP
  $IFB
  $C1
  $C2
  $C3
  $C4
  $C5
  $C6
  $COMANDO_IN_ROOT
  $COMANDO_IN_ENLACE
  $COMANDO_EXTRA_IN
  $COMANDO_OUT_ROOT
  $COMANDO_OUT_ENLACE
  $COMANDO_EXTRA_OUT
  $DOWNLOAD
  $UPLOAD
fi
