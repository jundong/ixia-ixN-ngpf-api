# place your files under ../lib
lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req IxiaNet
Login
IxDebugOn

Port port1 NULL NULL ::ixNet::OBJ-/vport:1
Port port2 NULL NULL ::ixNet::OBJ-/vport:2

DeviceGroup pppoeClient port1
DeviceGroup pppoeServeer port2

pppoeClient config -name TopologyClient -type topology
pppoeClient config -name DeviceGroupClient -count 10 -type deviceGroup
pppoeClient config -mac 11:11:11:11:11:11 -mac_step 00:00:00:00:00:01 \
                    -mac_port_step 00:00:01:00:00:00 -mtu 1460 \
                    -enable_vlan true -vlan_count 1 -type ethernet
pppoeClient config -tpid 0x8100 -priority 2 \
                    -vlan_id 100 -vlan_id_step 0 \
                    -vlan_id_port_step 0 \
                    -enable_vlan true -vlan_count 1 \
                    -type vlan

pppoeClient config -enable_echo_req true -enable_echo_rsp true \
                    -echo_req_interval 60 -ipcp_encap dual_stack \
                    -authentication pap \
                    -user_name ixiacom \
                    -password ixiacom  \
                    -enable_echo_detect true \
                    -ra_timeout 88  \
                    -start_rate 123 \
                    -stop_rate 234 \
                    -type pppoeclient


pppoeServeer config -name TopologyServer -type topology
pppoeServeer config -name DeviceGroupServer -count 1 -type deviceGroup
pppoeServeer config -mac 22:22:22:22:22:22 -mac_step 00:00:00:00:00:02 \
                    -mac_port_step 00:00:02:00:00:00 -mtu 1460 \
                    -enable_vlan true -vlan_count 1 -type ethernet
pppoeServeer config -tpid 0x8100 -priority 2 \
                    -vlan_id 100 -vlan_id_step 0 \
                    -vlan_id_port_step 0 \
                    -enable_vlan true -vlan_count 1 \
                    -type vlan

pppoeServeer config -ipv4_client_addr "11.11.11.11" \
                    -ipv4_svr_addr "22.22.22.22" \
                    -ipv4_client_addr_step "0.0.01.0" \
                    -ipv4_client_addr_port_step "0.01.0.0" \
                    -ipv4_svr_addr_step "0.0.02.0" \
                    -ipv4_svr_addr_port_step "0.02.0.0" \
                    -ipv6_client_iid "11:11:11:11:11:11:11:11" \
                    -ipv6_client_iid_port_step "00:00:00:01:00:00:00:00" \
                    -ipv6_client_iid_step "00:00:00:00:01:00:00:00" \
                    -ipv6_svr_iid "22:22:22:22:22:22:22:22" \
                    -ipv6_svr_iid_port_step "00:00:00:02:00:00:00:00" \
                    -ipv6_svr_iid_step "00:00:00:00:02:00:00:00" \
                    -ipv6_prefix_len 64 \
                    -ipcp_encap dual_stack \
                    -authentication pap \
                    -user_name ixiacom \
                    -password ixiacom  \
                    -enable_domain true \
                    -domain "ixiacom.com" \
                    -type pppoeserver
