#!/bin/sh
# Script to configure BMC/iDRAC's IP
# Author: Jorluis Perales, VxRail SST @ Dell EMC
# Version 1.0
#
# Do not change anything below this line
# --------------------------------------

echo "=============Configure BMC/iDRAC's IP (New or Change)=============="
echo ""
            
            
echo "Current BCM/iDRAC ip configuration"
echo ""
/opt/vxrail/tools/ipmitool lan print 1 | grep -E "IP Address|Subnet Mask |Default Gateway IP"

echo ""

echo "Would you like to change/configure the nodes' BCM/iDRAC ip? (Y/N)"

read answer

if [ "$answer" == "Y" ];
then


    echo "Type the new BMC/iDRAC's ip:"
    read ip
    echo "Type the new BMC/iDRAC's netmask:"    
    read netmask
    echo "Type the new BMC/iDRAC's gateway:"
    read gw
	
echo ""    

/opt/vxrail/tools/ipmitool lan set 1 ipsrc static
    
/opt/vxrail/tools/ipmitool lan set 1 ipaddr $ip

/opt/vxrail/tools/ipmitool lan set 1 netmask $netmask

/opt/vxrail/tools/ipmitool lan set 1 defgw ipaddr $gw

echo ""
    
    echo "==========================================="
    echo "Here is the new BCM/iDRAC ip configuration:"
    

    echo "IP Address Source       : Static Address"
    echo "IP Address              : "$ip
    echo "Subnet Mask             : "$netmask
    echo "Default Gateway IP      : "$gw

    echo "==========================================="


fi

if [ "$answer" == "N" ];
then


echo "====="
echo "|Bye|"
echo "====="

sleep 1


fi
