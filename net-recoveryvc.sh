# Script to obtain create a temporary vSS and PG to recovery network connectivity between vcsa and psc
# Author: Jorluis Perales, VxRail SST @ Dell EMC
# Version 1.0
#
# Do not change anything below this line
# --------------------------------------

echo "===============Create a tmp vswitch/PG for vCenter/PSC network recovery============="
			
echo ""
esxcli network nic list
echo ""
vds=$(esxcli network vswitch dvs vmware list | grep -E "EVO:RAIL Distributed Switch|VMware HCIA Distributed Switch" | head -n 1)
echo ""
echo "Which vmnic you would like to disconect:"

read vmnic

sleep 2

portid=$(esxcli network vswitch dvs vmware list | grep "$vmnic" -A4 | grep "Port ID" | sed 's/[^0-9]*//g')

echo ""

echo "Disconnecting $vmnic"

sleep 1
esxcfg-vswitch -Q $vmnic -V $portid "$vds"

echo ""
sleep 1
echo "$vmnic has been succefully removed, creating tmpsw switch"

esxcli network vswitch standard add -v tmpsw

sleep 1

echo "Adding $vmnic to the tmpsw switch "

sleep 1

esxcli network vswitch standard uplink add -u $vmnic -v tmpsw

echo "Creating a new tmp Port Group and adding it to the tmpsw switch "

sleep 1


esxcli network vswitch standard portgroup add --portgroup-name=tmp --vswitch-name=tmpsw

echo ""

echo "Would you like to add the vCenter/Management VLAN ID to the tmp port group? (Y/N)"

read answer

if [ $answer == y -o $answer == Y ];
then


    echo "Type the vCenter/Management VLAN ID:"
	read vlan

sleep 1
	
echo "Setting VLAN ID $vlan to tmp switch"
sleep 1

esxcli network vswitch standard portgroup set --portgroup-name=tmp --vlan-id=$vlan 
sleep 1
echo ""	
fi

if [ $answer == n -o $answer == N ];
then


echo "========="
echo "|Alright|"
echo "========="

sleep 1

echo ""
fi 

echo "All set, now go through the $(hostname)'s UI and add the new tmp port group to your vCenter/PSC"

echo "=================================================================================================="

