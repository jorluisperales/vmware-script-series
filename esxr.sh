#!/bin/sh
# Script to gather esxi version, uptime and hostname
# Author: Jorluis Perales, VxRail TSE 2 @ Dell EMC
# Version 1.0
#
# Do not change anything below this line
# --------------------------------------

echo "=============ESXi version=============="
echo "   Hostname:" $(hostname)
echo "   Uptime: " $(uptime | cut -d, -f1,2 | cut -c14-)
esxcli system version get
sleep 2
echo "======================================="
