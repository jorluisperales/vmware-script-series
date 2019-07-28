#!/bin/sh
# Script to get Disks Smart info and mapping - VSAN
# Author: Jorluis Perales, VxRail TSE 2 @ Dell EMC
# Version 1.0
#
# Do not change anything below this line
# --------------------------------------


echo "=============SMART Disks info and mapping=============="
for i in `esxcli  storage core device list | grep ^naa` ; do echo $i; esxcli storage core device smart get -d $i ; done
echo""

echo "Device Mapping:"
echo ""

vdq -i -H

echo "======================================================="

