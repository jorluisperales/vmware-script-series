# Script to create a temporary vSS and PG to recovery network connectivity between vcsa and psc
# Author: Jorluis Perales, VxRail SST @ Dell EMC
# Version 1.0 - Original version
# Version 1.1 - Added automatic VLAN assignment to newly PG based on node's mgmt vmk
#
# Do not change anything below this line
# --------------------------------------

echo "===============Create a tmp vswitch/PG for vCenter/PSC network recovery============="
			
echo ""
esxcli network nic list
echo ""
vds=$(esxcli network vswitch dvs vmware list | grep -E "EVO:RAIL Distributed Switch|VMware HCIA Distributed Switch" | head -n 1)
echo ""
echo "Which vmnic you would like to disconnect:"

read vmnic


sleep 2

portid=$(esxcli network vswitch dvs vmware list | grep "$vmnic" -A4 | grep "Port ID" | sed 's/[^0-9]*//g')
platform=$(esxcli hardware platform get | grep "Vendor Name:" | awk '{print $3}')


echo ""

echo "Disconnecting $vmnic"

sleep 1
esxcfg-vswitch -Q $vmnic -V $portid "$vds"

echo ""
sleep 1
echo "$vmnic has been successfully removed, creating tmpsw switch"

esxcli network vswitch standard add -v tmpsw

sleep 1

echo "Adding $vmnic to the tmpsw switch "

sleep 1

esxcli network vswitch standard uplink add -u $vmnic -v tmpsw

echo "Creating a new tmp Port Group and adding it to the tmpsw switch "

sleep 1


esxcli network vswitch standard portgroup add --portgroup-name=tmp --vswitch-name=tmpsw

echo ""

echo "The Script will automatically add the Management's vmk VLAN to the newly created Port Group"
echo ""
if [ $platform == Dell ];
then

echo "Hardware is $platform"
echo ""


	vmk2dvp=$(esxcli network vswitch dvs vmware list | grep -i vmk2 -A1 | tail -n 1 | awk '{print $3}')
	
	vlan=$(net-dvs  | grep -i $vmk2dvp -A37 | egrep -i "com.vmware.common.port.volatile.vlan" | awk '{print $4}')

sleep 1
	
echo "Setting VLAN ID $vlan to tmp switch"
sleep 1

esxcli network vswitch standard portgroup set --portgroup-name=tmp --vlan-id=$vlan 
sleep 1
echo ""	
fi

if [ $platform == Quanta ];
then

echo "Hardware is $platform"
echo ""

	vmk1dvp=$(esxcli network vswitch dvs vmware list | grep -i vmk1 -A1 | tail -n 1 | awk '{print $3}')
	
	vlan=$(net-dvs  | grep -i $vmk1dvp -A37 | egrep -i "com.vmware.common.port.volatile.vlan" | awk '{print $4}')

sleep 1
	
echo "Setting VLAN ID $vlan to tmp switch"
sleep 1

esxcli network vswitch standard portgroup set --portgroup-name=tmp --vlan-id=$vlan 
sleep 1

echo ""
fi 

echo "All set, now go through the $(hostname)'s UI and add the new tmp port group to your vCenter/PSC"

echo "======================================================================================================="

