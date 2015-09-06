# place your files under ../lib
lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req IxiaNet
Login
IxDebugOn

Port port1 NULL NULL ::ixNet::OBJ-/vport:1

DeviceGroup deviceGroup port1
deviceGroup config -name DeviceGroupOne -count 2

EthernetObject ethernetObj deviceGroup
ethernetObj config -mac 11:11:01:00:22:01 -mac_step 00:00:00:00:00:11 \
                    -mac_port_step 00:00:22:00:00:00 -mtu 1460 \
                    -enable_vlan true -vlan_count 2 \
                    -tpid 0x9300 -priority 2 \
                    -vlan_id 111 -vlan_id_step 33 \
                    -vlan_id_port_step 44 

PppoeClientDevice pppoeClentDevice ethernetObj
pppoeClentDevice config -enable_echo_req true -enable_echo_rsp true \
                    -echo_req_interval 111 -ipcp_encap dual_stack \
                    -authentication auto \
                    -user_name ixiacom \
                    -password ixiacom  \
                    -enable_echo_detect false \
                    -ra_timeout 88  \
                    -start_rate 123 \
                    -stop_rate 234
