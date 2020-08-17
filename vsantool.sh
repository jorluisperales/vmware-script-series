#!/bin/sh
# Script with a set of tool for vSAN troubleshooting 
# Author: Jorluis Perales
# Blog: https://www.jortechnologies.com/
# Do not change anything below this line 
# --------------------------------------

clear

while [ "$vmware" != "q" ]
do
echo "

+------------------------------------------------------+
|                         vsantool                     |
+======================================================+
| 1) VSAN Cluster State                                |
| 2) Validate if the vSAN is communicating with other  |
|               vsan members                           |
| 3) Check on the vSAN objects' state                  |
| 4) Check VSAN's disks                                |
|    (Device/CMMDS state/Dedup/Compression)            |
| 5) Verify for running resync operations              |
| 6) Check disk balance status on all hosts            |
| 7) Look for SSD congestion                           |
| 8) Print data limit health status                    |
| 9) Print physical disks health status                |
| 10) Print perf service health status                 |
| 11) Is this Node part of a stretched cluster?        |
| 12) Check for 4K alignment                           |
| 13) How many objects each host owns                  |
| 14) Find accessible object paths                     |
| 15) Find inaccessible objects                        |
| 16) Check for checksum errors                        |
| q)   Quit                                            |
+------------------------------------------------------+
"

       read vmware

        case $vmware in

######################## VSAN ########################

            '1')
           
echo "=============VSAN Cluster State=============="
        
            
esxcli vsan cluster get


echo ""

echo "Here is the overall vSAN cluster health:"
echo ""

esxcli vsan health cluster list



echo "=============================================";;


            '2')

            
echo "============================vSAN tcpdump test (vSAN;s vmk and port 12321)============================="
            
            
vmk="$(esxcli vsan network list | head -n 2 | tail -n 1 | awk '{print $3}')"

echo "VSAN's vmk: " $vmk
sleep 1
echo "tcpdump-uw command will run for 50 secs, confirm all nodes vsan vmks are communicating with each other"

timeout -t 50 tcpdump-uw -i $vmk port 12321

echo "======================================================================================================";;



            '3')

echo "=================Check on the vSAN objects' state=================="
echo "Objects"            
            
cmmds-tool find -f python | grep CONFIG_STATUS -B 4 -A 6 | grep 'uuid\|content' | grep -o 'state\\\":\ [0-9]*' | sort | uniq -c

echo ""
echo "Legend"
echo ""
echo "7 --->    healthy"
echo "13 -->    inaccessible objects "
echo "15 -->    absent/degraded "

sleep 2
echo ""
echo "Here are more details about the current objects' state:"
echo ""
esxcli vsan debug object health summary get

sleep 1


echo "===================================================================";;

            '4')

echo "=============Device/CMMDS state/Deduplication/Compression=============="


esxcli --formatter=csv --format-param=fields="Device, Deduplication,Compression,In CMMDS,Encryption,Is Mounted,Is SSD " vsan storage list   

echo ""

echo "Detailed view"

localcli vsan storage list | awk 'BEGIN{printf "%60s | %6s | %50s | %12s | %6s\n","Device","Is_SSD","VSAN_DG_UUID","Used_by_host","In_CMMDs"}/Device:/{naa=$2}/Is SSD:/{ssd=$3}/VSAN Disk Group UUID:/{dguuid=$5}/Used by this host/{used=$5}/In CMMDS:/{printf "%60s | %6s | %50s | %12s | %6s\n",naa,ssd,dguuid,used,$3}'

echo ""

echo "=======================================================================";;

            '5')

echo "=============Resync Operations=============="

echo ""
esxcli vsan debug resync list


echo ""


esxcli vsan debug resync summary get
echo ""


echo "============================================";;

            '6')

echo "=============vSAN Disk Balance=============="

echo ""
esxcli vsan health cluster get -t diskbalance

echo "============================================";;



            '7')

echo "=============Look for SSD congestion=============="

echo ""
echo "Any value greater than 150 requires to be investigated"
echo ""
for ssd in $(localcli vsan storage list |grep "Group UUID"|awk '{print $5}'|sort -u);do echo $ssd;vsish -e get /vmkModules/lsom/disks/$ssd/info|grep Congestion;done

echo "==================================================";;

            '8')

echo "=============Data limit health check=============="

echo ""
echo "=============Current cluster situation=============="
esxcli vsan health cluster get -t "Current cluster situation"
echo "=================================================="
echo ""
echo "=============After 1 additional host failure=============="
esxcli vsan health cluster get -t "After 1 additional host failure"
echo "=========================================================="
echo ""
echo "=============Host component limit=============="
esxcli vsan health cluster get -t "Host component limit"
echo "==============================================="
echo "=============Component Limit=============="
esxcli vsan debug limit get
echo "=========================================="
echo ""
echo "==================================================";;


            '9')

echo "=============Physical disk health status=============="

echo ""
echo "=============Operation health=============="
esxcli vsan health cluster get -t "Operation health"
echo "==========================================="
echo ""
echo "=============Disk capacity=============="
esxcli vsan health cluster get -t "Disk capacity"
echo "========================================"
echo ""
echo "=============Congestion=============="
esxcli vsan health cluster get -t "Congestion"
echo "====================================="
echo ""
echo "=============Component limit health=============="
esxcli vsan health cluster get -t "Component limit health"
echo "================================================="
echo ""
echo "=============Component metadata health=============="
esxcli vsan health cluster get -t "Component metadata health"
echo "===================================================="
echo ""
echo "=============Memory pools (heaps)=============="
esxcli vsan health cluster get -t "Memory pools (heaps)"
echo "==============================================="
echo ""
echo "=============Memory pools (slabs)=============="
esxcli vsan health cluster get -t "Memory pools (slabs)"
echo "==============================================="

echo "==================================================";;


           '10')

echo "=============Performance service health status=============="

echo ""
echo "=============Stats DB object=============="
esxcli vsan health cluster get -t "Stats DB object"
echo "=========================================="
echo ""
echo "=============Stats master election=============="
esxcli vsan health cluster get -t "Disk capacity"
echo "================================================"
echo ""
echo "=============Performance data collection=============="
esxcli vsan health cluster get -t "Performance data collection"
echo "======================================================"
echo ""
echo "=============All hosts contributing stats=============="
esxcli vsan health cluster get -t "All hosts contributing stats"
echo "======================================================="
echo ""
echo "=============Stats DB object conflicts=============="
esxcli vsan health cluster get -t "Stats DB object conflicts"
echo "===================================================="

echo "=============================================================";;

           '11')

echo "=============Is this Node part of a stretched cluster?=============="

echo ""
esxcli vsan cluster preferredfaultdomain get
echo ""
sleep 3
echo "=============================================================";;

           '12')

echo "=============Check for 4K alignment=============="

echo ""
ls -lah /vmfs/volumes/vsan*/*/*[!ctk].vmdk | sed -r 's/ +/ /g' | cut -d " " -f 9- | while read line; do size=$(cat "$line" | grep RW | awk '{print $2}'); if [ $(($size % 1048576)) -eq 0 ]; then echo "ALIGNED: $line is $size bytes."; else echo "NOT ALIGNED: $line is $size bytes."; fi; done
echo ""
sleep 3
echo "================================================";;

           '13')

echo "=============How many objects each host owns=============="

echo ""
cmmds-tool find -f python -t DOM_OBJECT | grep owner | sort | uniq -c
echo ""
sleep 3
echo "==========================================================";;


           '14')

echo "=============Find accessible object paths=============="

echo ""
cmmds-tool find -t DOM_OBJECT -f json |grep uuid |awk -F \" '{print $4}'|while read i;do objPath=$(/usr/lib/vmware/osfs/bin/objtool getAttr -u $i|grep path);echo "$i: $objPath";done 
echo ""
sleep 3
echo "=======================================================";;

           '15')

echo "=============Find inaccessible objects=============="

echo ""
cmmds-tool find -f python | grep -B9 "state....13" | grep uuid | cut -c 13-48 > inaccessibleObjects.txt
echo $(wc -l < inaccessibleObjects.txt) "Inaccessible Objects Found"
cat inaccessibleObjects.txt
echo ""
sleep 3
echo "====================================================";;

           '16')

echo "=============Check for Checksum errors=============="

echo ""
for disk in $(localcli vsan storage list |grep "VSAN UUID"|awk '{print $3}'|sort -u);do echo ==DISK==$disk====;vsish -e get /vmkModules/lsom/disks/$disk/checksumErrors;done
echo ""
sleep 3
echo "====================================================";;

            'q') echo "quiting!";;
            *)   
            
echo "=========Menu item is not available; try again!========="

        esac
done

exit 0

