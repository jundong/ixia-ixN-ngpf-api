# Copyright (c) Ixia technologies 2015-2016, Inc.

# Release Version 1.0
#===============================================================================
# Change made
# Version 1.0 
#       1. Create

class NetObject {
    public variable name
    public variable handle
    
    method unconfig {} {
        set tag "body NetObject::unconfig [info script]"
        Deputs "----- TAG: $tag -----"
        catch {
            ixNet remove $handle
            ixNet commit
        }
        set handle ""
        
        return [ GetStandardReturnHeader ]
    }
}

class EmulationObject {
    inherit NetObject
    
    public variable portObj
    public variable hPort

    method start {} {
        set tag "body EmulationObject::start [info script]"
        Deputs "----- TAG: $tag -----"
        catch {
            foreach h $handle {
                ixNet exec start $h
            }
        }
        
        return [ GetStandardReturnHeader ]
    }
    
    method abort {} {
        set tag "body EmulationObject::abort [info script]"
        Deputs "----- TAG: $tag -----"
        catch {
            foreach h $handle {
                ixNet exec abort $h
            }
        }
        
        return [ GetStandardReturnHeader ]
    }
    
    method stop {} {
        set tag "body EmulationObject::stop [info script]"
        Deputs "----- TAG: $tag -----"
        catch {
            foreach h $handle {
                ixNet exec stop $h
            }
        }
        
        return [ GetStandardReturnHeader ]
    }
    
    method enable {} {
        set tag "body EmulationObject::enable [info script]"
        Deputs "----- TAG: $tag -----"
        catch {
            ixNet setA $handle -enabled True
            ixNet commit
        }
        
        return [ GetStandardReturnHeader ]
    }
    
    method disable {} {
        set tag "body EmulationObject::disable [info script]"
        Deputs "----- TAG: $tag -----"
        Deputs "+++ $handle"
        catch {
            ixNet setA $handle -enabled False
            ixNet commit
        }
        
        return [ GetStandardReturnHeader ]
    }
    
    method unconfig {} {
        chain 
        catch { unset hPort }
    }
}

class ProtocolObject {
    inherit EmulationObject
    
    public variable parentObj
    public variable hParent
      
    method constructor { parent } {
        global errorInfo
        global errNumber
        
        set tag "body ProtocolObject::ctor [info script]"
        Deputs "----- TAG: $tag -----"
        set parentObj [ GetObject $parent ]
        if { [ catch {
            set hParent  [ $parentObj cget -handle ]
        } ] } {
            error "$errNumber(1) Stack Object in ProtocolObject ctor"
        }
    }
    
    method restart_down {} {
        set tag "body ProtocolObject::restart_down [info script]"
        Deputs "----- TAG: $tag -----"
        catch {
            foreach h $handle {
                ixNet exec restartDown $h
            }
        }
        
        return [ GetStandardReturnHeader ]
    }
    
    method unconfig {} {
        chain 
        catch { unset hParent }
    }
}

class TopologyObject {
    inherit NetObject
    
    public variable root 
    
    constructor { port } {
        global errorInfo
        global errNumber
        
        set tag "body TopologyObject::ctor [info script]"
        Deputs "----- TAG: $tag -----"
        set root [ixNet getRoot]
        if { [ catch {
            set portObj [GetObject $port]
            set portHnd [GetObjHandle $portObj]
            set handle [ixNet add $root topology]
            ixNet setM $handle -vports $portHnd
            ixNet commit
        } ] } {
            error "$errNumber(1) Parent Object in TopologyObject ctor"
        }
    }
    method config { args } {}
}

body TopologyObject::config { args } {
    global errorInfo
    global errNumber
    
    set tag "body TopologyObject::config [info script]"
    Deputs "----- TAG: $tag -----"

    #param collection
    Deputs "Args:[string range $args 1 end-1] "
    foreach { key value } [string range $args 1 end-1] {
        set key [string tolower $key]
        switch -exact -- $key {         
            -name {
                set name $value
            }
            default {
                continue
            }
        }
        ConfigAttr $handle $key $value
    }
    
    return [GetStandardReturnHeader]
}


class DeviceGroup {
    inherit EmulationObject
    
    public variable count
    public variable parentObj
    public variable hParent
    
    method constructor { port } {
        global errorInfo
        global errNumber
        
        set tag "body DeviceGroup::ctor [info script]"
        Deputs "----- TAG: $tag -----"
        set portObj [GetObject $port]
        set hPort [GetObjHandle $portObj]
        if { [ catch {
            set parentObj [TopologyObject #auto $portObj]
            set hParent [$parentObj cget -handle]
            set handle [ixNet add $hParent deviceGroup]
            ixNet commit
        } ] } {
            error "$errNumber(1) Parent Object in DeviceGroup ctor"
        }
    }
    
    method config { args } {} 
}

body DeviceGroup::config { args } {
    global errorInfo
    global errNumber
    
    set tag "body DeviceGroup::config [info script]"
    Deputs "----- TAG: $tag -----"
    #param collection
    Deputs "Args:[string range $args 1 end-1]"
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -count {
                set key -multiplier
                set count $value
            }
            -name {
                set name $value
            }
            default {
                continue
            }
        }
        ConfigAttr $handle $key $value
    }
    
    return [GetStandardReturnHeader]
}


class Ethernet {
    inherit ProtocolObject
    
    public variable vlan
    public variable mac
    public variable mac_step
    public variable mac_port_step
    public variable mtu
    public variable enable_vlan
    public variable vlan_count

    public variable tpid
    public variable priority
    public variable vlan_id1
    public variable vlan_id1_step
    public variable vlan_id1_port_step
    public variable vlan_id2
    public variable vlan_id2_step
    public variable vlan_id2_port_step
    
    
    constructor { deviceGroup } { chain $deviceGroup } { 
        set mac_step            "00:00:00:00:00:01"
        set mac_port_step       "00:00:01:00:00:00"
        set vlan_id1_step       0
        set vlan_id1_port_step  0
        set vlan_id2_step       0
        set vlan_id2_port_step  0
        set enable_vlan         1
        
        if { [ catch {
            set handle [ixNet add $hParent ethernet]
            ixNet commit
            set vlan [list]
            set vlan [lindex [ixNet getL $handle vlan] 0]
        } ] } {
            error "$errNumber(1) Parent Object in Ethernet ctor"
        }
    }
    
    method config { args } {}
}

body Ethernet::config { args } {
    global errorInfo
    global errNumber
    set tag "body Ethernet::config [info script]"
    Deputs "----- TAG: $tag -----"
    
    #param collection
    Deputs "Args:$args "
    
    array set kvList [list]
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -mac -
            -src_mac {
                set key -mac
                set mac $value
            }
            -mtu {
                set mtu $value
            }
            -enable_vlan {
                set key -enableVlans
            }
            -vlan_count {
                ixNet setA $handle -vlanCount $value
                ixNet commit
                continue
            }
            -mac_step -
            -src_mac_step {
                set mac_step $value
            }
            -mac_port_step -
            -src_mac_port_step {
                set mac_port_step $value
            }
            -tpid {
                if { [ IsHex $value ] } {
                    set value [string replace $value 0 1 ethertype]
                    set tpid $value
                }
            }
            -priority {
                set priority $value
            }
            -vlan_id -
            -vlan_id1 -
            -outer_vlan_id {
                set key -vlanId
                set vlan_id1 $value
            }
            -vlan_id_step -
            -vlan_id1_step -
            -outer_vlan_step {
                set vlan_id1_step $value
                continue
            }
            -vlan_id_port_step -
            -vlan_id1_port_step {
                set vlan_id1_port_step $value
                continue
            }
            -vlan_id2 -
            -inner_vlan_id {
                set key -vlanId2
                set vlan_id2 $value
            }
            -vlan_id2_step -
            -inner_vlan_step {
                set vlan_id2_step $value
                continue
            }
            -vlan_id2_port_step {
                set vlan_id2_port_step $value
                continue
            }
            default {
                continue
            }
        }
        set kvList($key) $value
    }
    
    foreach key [array names kvList] {
        switch -exact -- $key {
            -mac {
                if { $mac_step != "00:00:00:00:00:00" || $mac_port_step != "00:00:00:00:00:00" } {
                    ConfigAttr $handle $key $kvList($key) $mac_step $mac_port_step
                }
            }
            -vlanId {
                if { $vlan_id1_step != 0 || $vlan_id1_port_step != 0 } {
                    ConfigAttr [lindex $vlan 0] $key $kvList($key) $vlan_id1_step $vlan_id1_port_step
                } else {
                    ConfigAttr [lindex $vlan 0] $key $kvList($key)
                }
                if { [info exists kvList(-tpid)] } {
                    ConfigAttr [lindex $vlan 0] -tpid $kvList(-tpid)
                }
                if { [info exists kvList(-priority)] } {
                    ConfigAttr [lindex $vlan 0] -priority $kvList(-priority)
                }
            }
            -vlanId2 {
                ixNet setA $handle -vlanCount 2
                ixNet commit
                lappend vlan [lindex [ixNet getL $handle vlan] 1]
                if { $vlan_id2_step != 0 || $vlan_id2_port_step != 0 } {
                    ConfigAttr [lindex $vlan 1] -vlanId $kvList($key) $vlan_id2_step $vlan_id2_port_step
                } else {
                    ConfigAttr [lindex $vlan 1] $key $kvList($key)
                }
                if { [info exists kvList(-tpid)] } {
                    ConfigAttr [lindex $vlan 1] -tpid $kvList(-tpid)
                }
                if { [info exists kvList(-priority)] } {
                    ConfigAttr [lindex $vlan 1] -priority $kvList(-priority)
                }
            }
            default {
                ConfigAttr $handle $key $kvList($key)
            }
        }
    }
    
    return [GetStandardReturnHeader]
}

