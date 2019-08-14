# Script to obtain the placement of the physical disk by naa on ESXi hosts
# Author: Jorluis Perales, VxRail TSE 2 @ Dell EMC
# Version 1.0
#
# Do not change anything below this line
# --------------------------------------

echo "=============Physical disks placement=============="
echo ""
	
esxcli storage core device list | grep "naa" | awk '{print $1}' | grep "naa" | while read in; do

echo "$in"
esxcli storage core device physical get -d "$in"
sleep 1

echo "===================================================="

done	
