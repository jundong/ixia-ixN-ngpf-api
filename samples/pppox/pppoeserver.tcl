# place your files under ../lib
lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req IxiaNet
Login
IxDebugOn

Port port1 NULL NULL ::ixNet::OBJ-/vport:1

DeviceGroup deviceGroupServer port1
deviceGroupServer config -name DeviceGroupTwo -count 1

EthernetObject ethernetObj deviceGroupServer
ethernetObj config -mac 11:11:01:00:22:01 -mac_step 00:00:00:00:00:11 \
                    -mac_port_step 00:00:22:00:00:00 -mtu 1460 \
                    -enable_vlan true -vlan_count 2 \
                    -tpid 0x9300 -priority 2 \
                    -vlan_id 111 -vlan_id_step 33 \
                    -vlan_id_port_step 44 

PppoeServerDevice pppoeServerDevice ethernetObj
pppoeServerDevice config -ipv4_client_addr "22.22.11.11" \
                    -ipv4_svr_addr "33.33.22.22" \
                    -ipv4_client_addr_step "0.0.11.0" \
                    -ipv4_client_addr_port_step "0.11.0.0" \
                    -ipv4_svr_addr_step "0.0.22.0" \
                    -ipv4_svr_addr_port_step "0.22.0.0" \
                    -ipv6_client_iid "11:11:11:11:00:00:00:01" \
                    -ipv6_client_iid_port_step "00:00:00:11:00:00:00:00" \
                    -ipv6_client_iid_step "00:00:00:00:11:00:00:00" \
                    -ipv6_svr_iid "22:22:22:22:00:00:00:01" \
                    -ipv6_svr_iid_port_step "00:00:00:22:00:00:00:00" \
                    -ipv6_svr_iid_step "00:00:00:00:22:00:00:00" \
                    -ipv6_prefix_len 98 \
                    -ipcp_encap dual_stack \
                    -authentication auto \
                    -user_name ixiacom \
                    -password ixiacom  \
                    -enable_domain true \
                    -domain "ixiacom.com"
