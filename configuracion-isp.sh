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
    echo 'ejecutando ifb'
  $IFB
    echo 'ejecutando c1'
  $C1
    echo 'ejecutando c2'
  $C2
    echo 'ejecutando c3'
  $C3
    echo 'ejecutando c4'
  $C4
    echo 'ejecutando c5'
  $C5
    echo 'ejecutando c6'
  $C6
    echo 'ejecutando comandoinroot'
  $COMANDO_IN_ROOT
    echo 'ejecutando COMANDO_IN_ENLACE'
  $COMANDO_IN_ENLACE
    echo 'ejecutando comandoextrain'
  $COMANDO_EXTRA_IN
    echo 'ejecutando comandooutroot'
  $COMANDO_OUT_ROOT
    echo 'ejecutando comandooutenlace'
  $COMANDO_OUT_ENLACE
    echo 'ejecutando comandoextraout'
  $COMANDO_EXTRA_OUT
    echo 'ejecutando download'
  $DOWNLOAD
    echo 'ejecutando upload'
  $UPLOAD
fi
