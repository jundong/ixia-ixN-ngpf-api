# place your files under ../lib
lappend auto_path [file dirname [file dirname [file dirname [info script]]]]

package req IxiaNet
Login
IxDebugOn

Port port1 NULL NULL ::ixNet::OBJ-/vport:1
Port port2 NULL NULL ::ixNet::OBJ-/vport:2

DeviceGroup clientDevice port1
clientDevice config -name ClientDevice -count 2

Ethernet clientEthernetObj clientDevice
clientEthernetObj config    -mac 11:11:01:00:11:01 \
                            -mac_step 00:00:00:00:00:11 \
                            -mac_port_step 00:00:22:00:00:00 \
                            -mtu 1460 \
                            -enable_vlan false

PppoeClientDevice pppoeClient clientEthernetObj
pppoeClient config  -ipcp_encap ipv4 \
                    -authentication pap \
                    -user_name ixiacom \
                    -password ixiacom

DeviceGroup serverDevice port2
serverDevice config -name ServerDevice -count 1

Ethernet serverEthernetObj serverDevice
serverEthernetObj config  -mac 22:11:01:00:22:01 \
                    -mac_step 00:00:00:00:00:11 \
                    -mac_port_step 00:00:22:00:00:00 \
                    -mtu 1460 \
                    -enable_vlan false

PppoeServerDevice pppoeServer serverEthernetObj
pppoeServer config -ipv4_client_addr "22.22.11.11" \
                    -ipv4_svr_addr "33.33.22.22" \
                    -ipv4_client_addr_step "0.0.11.0" \
                    -ipv4_client_addr_port_step "0.11.0.0" \
                    -ipv4_svr_addr_step "0.0.22.0" \
                    -ipv4_svr_addr_port_step "0.22.0.0" \
                    -ipcp_encap ipv4 \
                    -authentication pap \
                    -user_name ixiacom \
                    -password ixiacom

pppoeServer start
pppoeServer wait_connect_complete -timeout 30

pppoeClient start
pppoeClient wait_connect_complete -timeout 30

set clientPerPortResults [pppoeClient get_view_stats -view_name "PPPoX Client Per Port"]
#foreach result $clientPerPortResults {
#    puts $result
#}
set serverPerPortResults [pppoeServer get_view_stats -view_name "PPPoX Server Per Port"]
#foreach result $serverPerPortResults {
#    puts $result
#}
