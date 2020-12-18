#!/bin/bash

cd iso
ISOVERSION=10.7.0
ISOFILE=debian-${ISOVERSION}-amd64-netinst.iso
echo ${ISOVERSION}
echo ${ISOFILE}
if [ ! -e ${ISOFILE} ]; then
wget http://cdimage.debian.org/debian-cd/${ISOVERSION}/amd64/iso-cd/${ISOFILE}
else
echo "File already exists"
fi
