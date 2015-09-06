# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.5
#===============================================================================
# Change made
# Version 1.0 
#       1. Create

class DeviceGroup {
    public variable root
    public variable port
    public variable portObj
    public variable topology
    public variable topologyObj
    public variable deviceGroup
    public variable deviceGroupObj
    public variable ethernet
    public variable ethernetObj
    public variable vlan
    public variable vlanObj
    public variable type
    public variable count
    public variable protocols
    public variable protocolsObj
    
    # -- port can be a list, but one port recommended
    # -- template
    # --     -enum: IPV4 IPV6 PPPOXCLIENT PPPOXSERVER L3VPN_PE   
    constructor { port { template null } } {
        set root [ixNet getRoot]
        set portObj $port
        set protocols [list]
        set protocolsObj [list]
        set type [ string toupper $template ]
        puts "type => $type"
        reborn
    }
    
    method init {} {
        switch $type {
            IPV4 {
      
            }
            IPV6 {
    
            }
            PPPOECLIENT {
                set flag false
                foreach key $protocols {
                    if { [regexp -nocase pppoxclient $key] } {
                        set flag true
                        break
                    }
                }
                if { !$flag } {
                    set pppoeClientObj [PPPoEClientObject #auto $this]
                    lappend protocolsObj $pppoeClientObj
                }
            }
            PPPOESERVER {
                set flag false
                foreach key $protocols {
                    if { [regexp -nocase pppoxserver $key] } {
                        set flag true
                        break
                    }
                }
                if { !$flag } {
                    set pppoeServerObj [PPPoEServerObject #auto $this]
                    lappend protocolsObj $pppoeServerObj
                }
            }
            L3VPN_PE {
            }
        }
    }
    
    method reborn {} {}
    method config { args } {} 
    method config_ethernet { args } {}
    method config_vlan { args } {}
    method config_ip { args } {}
    method config_ipv4 { args } {}
    method config_ipv6 { args } {}
}
    
body DeviceGroup::reborn {} {
    global errorInfo
    global errNumber
    puts "reborn => [info exists topologyObj]"
    set tag "body DeviceGroup::reborn [info script]"
    Deputs "----- TAG: $tag -----"
    
    if { ![info exists topologyObj]} {
        set topologyObj [TopologyObject #auto $this]
        set topology [$topologyObj cget -handle]
        lappend protocolsObj $topologyObj
    }
    if { ![info exists deviceGroupObj]} {
        set deviceGroupObj [DeviceGroupObject #auto $this]
        set deviceGroup [$deviceGroupObj cget -handle]
        lappend protocolsObj $deviceGroupObj
    }
    if { ![info exists ethernetObj]} {
        set ethernetObj [EthernetObject #auto $this]
        set ethernet [$ethernetObj cget -handle]
        lappend protocolsObj $ethernetObj
    }
    if { ![info exists vlanObj]} {
        set vlanObj [VlanObject #auto $this]
        set vlan [$vlanObj cget -handle]
        lappend protocolsObj $vlanObj
    } 

    if { $type != "NULL" } {
        init
    }
    
    return [GetStandardReturnHeader]
}

# ---------------------------------
# -- count
# --    -INT
# -- router_id
# --    -IP
body DeviceGroup::config { args } {
    global errorInfo
    global errNumber
    set tag "body DeviceGroup::config [info script]"
    Deputs "----- TAG: $tag -----"
    
    set count 1
    #param collection
    Deputs "Args:$args "
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -type {
                set type [string toupper $value]
                init
            }
            default {
                continue
            }
        }
    }
    
    if { [regexp -nocase all $type] } {
        foreach obj $protocolsObj {
            $obj config $args
        }
    } else {
        puts "protocolsObj => $protocolsObj"
        puts "protocols => $protocols"
        puts "args => $args"
        puts "type => $type"
        set index [lsearch -nocase $protocolsObj $type*]
        puts "index => $index"
        if { $index != -1 } {
            set obj [lindex $protocolsObj $index]
            $obj config $args
        }
    }
    
    return [GetStandardReturnHeader]
}

# ---------------------------------
# -- mac/src_mac
# --    -MAC addr
# -- src_mac_step
# --    -MAC addr
# -- mtu
# --    -INT
# -- enable_vlan
# --    -BOOL
body DeviceGroup::config_ethernet { args } {
    global errorInfo
    global errNumber

    ethernetObj.config $args
    
    return [GetStandardReturnHeader]
}

# ---------------------------------
# -- tpid
# --    -HEX
# -- priority
# --    -INT
# -- vlan_id
# --    -INT
body DeviceGroup::config_vlan { args } {
    global errorInfo
    global errNumber
    set tag "body DeviceGroup::config_vlan [info script]"
    Deputs "----- TAG: $tag -----"

    if { $handle == "" } {
        config -count $count
    }
    
    #param collection
    Deputs "Args:$args "

    config_ethernet -enable_vlan 1

    array set kvList [list]

    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -tpid {
                if { [ IsHex $value ] } {
                    set value [string replace $value 0 1 ethertype]
                    # set value [ format %i $value ]
                }
            }
            -priority {
            }
            -vlan_id -
            -vlan_id1 -
            -outer_vlan_id {
                set key -vlanId                
            }
            -vlan_id1_step -
            -outer_vlan_step {
                set vlan_step $value
            }
            -vlan_id2 -
            -inner_vlan_id {
                set key -vlanId2
            }
            -vlan_id2_step -
            -inner_vlan_step {
                set vlan_step2 $value
            }            
            default {
                continue
            }
        }
        set kvList($key) $value
    }
    
    foreach key [array names kvList] {
        switch -exact -- $key {
            -vlanId {
                if { [ info exists vlan_step ] } {
                    SetMultipleValue $vlan $key $kvList($key) $vlan_step
                } else {
                    SetMultipleValue $vlan $key $kvList($key)
                }
            }
            -vlanId2 {
                config_ethernet -vlan_count 2
                set vlan [lindex [ixNet getL $ethernet vlan] 1]
                if { [ info exists vlan_step2 ] } {
                    SetMultipleValue $vlan -vlanId $kvList($key) $vlan_step2
                } else {
                    SetMultipleValue $vlan -vlanId $kvList($key)
                }
                set vlan [lindex [ixNet getL $ethernet vlan] 0]
            }
            default {
                SetMultipleValue $ethernet $key $kvList($key)
            }
        }
    }
    return [GetStandardReturnHeader]
}

# ---------------------------------
# -- address
# --    -IP
# -- prefix
# --    -INT
# -- gateway
# --    -IP
# -- family
# --    -enum: ipv4 ipv6
body DeviceGroup::config_ip { args } {
    global errorInfo
    global errNumber
    set tag "body DeviceGroup::config_ip [info script]"
    Deputs "----- TAG: $tag -----"

    if { $handle == "" } {
        config -count $count
    }
    
    #param collection
    Deputs "Args:$args "

    array set kvList [list]

    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -address -
            -prefix {
            }
            -gateway -
            -ipv4_gw -
            -ipv6_gw {
                set key -gatewayIp
            }
            -ipv4_gw_step -
            -ipv6_gw_step {
                set gw_step $value
            }
            -family {
                set obj $value
                continue
            }
            -ipv4_addr -
            -ipv6_addr {
                set key -address
            }
            -ipv4_addr_step -
            -ipv6_addr_step {
                set addr_step $value
            }
            -ipv4_prefix_len -
            -ipv4_prefix_length -
            -ipv6_prefix_len -
            -ipv6_prefix_length {
                set key -prefix
            }
            default {
                continue
            }
        }
        set kvList($key) $value
    }
    
    if { [ info exists obj ] } {
        foreach key [array names kvList] {
            switch -exact -- $key {
                -address {
                    if { [ info exists addr_step ] } {
                        SetMultipleValue $obj $key $kvList($key) $addr_step
                    } else {
                        SetMultipleValue $obj $key $kvList($key)
                    }
                }
                -gatewayIp {
                    if { [ info exists gw_step ] } {
                        SetMultipleValue $obj $key $kvList($key) $gw_step
                    } else {
                        SetMultipleValue $obj $key $kvList($key)
                    }
                }
                default {
                    SetMultipleValue $obj $key $kvList($key)
                }
            }
        }
    }
    return [GetStandardReturnHeader]

}
body DeviceGroup::config_ipv4 { args } {
    global errorInfo
    global errNumber
    set tag "body DeviceGroup::config_ipv4 [info script]"
    Deputs "----- TAG: $tag -----"

    return [eval config_ip -family $ipv4 $args]
}
body DeviceGroup::config_ipv6 { args } {
    global errorInfo
    global errNumber
    set tag "body DeviceGroup::config_ipv6 [info script]"
    Deputs "----- TAG: $tag -----"

    return [eval config_ip -family $ipv6 $args]
}
