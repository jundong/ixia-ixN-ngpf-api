
# Copyright (c) Ixia technologies 2010-2011, Inc.

# Release Version 1.0
#===============================================================================
# Change made
# Version 1.0 
#       1. Create



################################################
# Change Note                                  #
#1. 
################################################

class PppoeObject {
    inherit ProtocolObject
    
    public variable enable_echo_req
    public variable enable_echo_rsp
    public variable echo_req_interval
    
    public variable ipcp_encap
    
    public variable authentication
    public variable user_name
    public variable password
    
    constructor { ethernet } { chain $ethernet } {
        set user_name    user
        set password     password
    }
    
    method config { args } {}
}

body PppoeObject::config { args } {
    global errorInfo
    global errNumber
    
    set tag "body PppoeObject::config [info script]"
    Deputs "----- TAG: $tag -----"
    
    #param collection
    Deputs "Args:$args "
    
    array set kvList [list]
    foreach { key value } [string range $args 1 end-1] {
        set key [string tolower $key]
        switch -exact -- $key {
            -enable_echo_req {
                set key -enableEchoReq
                set enable_echo_req $value
            }
            -enable_echo_rsp {
                set key  -enableEchoRsp 
                set enable_echo_rsp $value
            }
            -echo_req_interval {
                set key -echoReqInterval  
                set echo_req_interval $value
            }
            -ipcp_encap {
                set key -ncpType 
                set ipcp_encap $value
            }
            -authentication {
                set key -authType 
                set authentication $value 
            }
            -user_name {
                set user_name $value
                continue
            }
            -password {
                set password $value
                continue
            }
            default {
                continue
            }
        }
        set kvList($key) $value
    }
    
    foreach key [array names kvList] {
        if { $key == "-authType" } {
            switch $authentication {
                auto {
                    set authentication pap_or_chap
                    set kvList($key)            $authentication        
                    set kvList(-papUser)        $user_name
                    set kvList(-chapName)       $user_name
                    set kvList(-papPassword)    $password
                    set kvList(-chapSecret)     $password
                }
                pap {
                    set authentication          pap
                    set kvList($key)            $authentication  
                    set kvList(-papUser)        $user_name
                    set kvList(-papPassword)    $password
                }
                chap_md5 {
                    set authentication          chap
                    set kvList($key)            $authentication
                    set kvList(-chapName)       $user_name
                    set kvList(-chapSecret)     $password
                }
                default {
                    continue
                }
            }
            break
        }
    }
    
    foreach key [array names kvList] {
        switch -exact -- $key {
            -chapName -
            -chapSecret -
            -papPassword -
            -papUser {
                if { [regexp pppoxserver $$handle] } {
                    set server_session [ixNet getL $handle pppoxServerSessions]
                    ConfigAttr $server_session $key $kvList($key)
                } else {
                    ConfigAttr $handle $key $kvList($key)
                }
            }
            default {
                ConfigAttr $handle $key $kvList($key)
            }
        }
    }
    
    return [GetStandardReturnHeader]
}

class PppoeClientDevice {
    inherit PppoeObject
    
    public variable enable_echo_detect
    public variable ra_timeout
    public variable start_rate
    public variable stop_rate
    
    constructor { parent } { chain $parent } {
        set handle [ixNet add $hParent pppoxclient ]
        ixNet commit
    }
    
    method config { args } {}
}

body PppoeClientDevice::config { args } {
    global errorInfo
    global errNumber
    set tag "body PppoeClientDevice::config [info script]"
    Deputs "----- TAG: $tag -----"
    
    #param collection
    Deputs "Args:$args "
    
    chain $args
    
    array set kvList [list]
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -enable_echo_detect {
                set key -enableEchoDetect
                set enable_echo_detect $value
            }
            -ra_timeout {
                set key  -raTimeout
                set ra_timeout $value
            }
            -start_rate {
                set key -startRate
                set  start_rate $value
            }
            -stop_rate {
                set key -stopRate
                set stop_rate $value
            }
            default {
                continue
            }
        }
        set kvList($key) $value
    }
    
    set root [ixNet getRoot]
    foreach key [array names kvList] {
        switch -exact -- $key {
            -startRate {
                ConfigAttr $root/globals/topology/pppoxclient/startRate -rate $kvList($key)
            }
            -stopRate {
                ConfigAttr $root/globals/topology/pppoxclient/stopRate -rate $kvList($key)
            }
            -enableEchoDetect {
                ConfigAttr $root/globals/topology/pppoxclient -createInterfaces $kvList($key)
            }
            -raTimeout {
                ConfigAttr $root/globals/topology/pppoxclient $key $kvList($key)
            }
            default {
                ConfigAttr $handle $key $kvList($key)
            }
        }
    }
    return [GetStandardReturnHeader]
}

class PppoeServerDevice {
    inherit PppoeObject
    
    public variable ipv4_client_addr
    public variable ipv4_client_addr_step
    public variable ipv4_client_addr_port_step
    public variable ipv4_svr_addr
    public variable ipv4_svr_addr_step
    public variable ipv4_svr_addr_port_step
    public variable ipv6_client_iid
    public variable ipv6_client_iid_step
    public variable ipv6_client_iid_port_step
    public variable ipv6_svr_iid
    public variable ipv6_svr_iid_step
    public variable ipv6_svr_iid_port_step
    public variable ipv6_prefix_len
    
    public variable enable_domain
    public variable domain
    
    constructor { parent } { chain $parent } {
        set ipv4_client_addr_step       "0.0.1.0"
        set ipv4_client_addr_port_step  "0.1.0.0"
        set ipv4_svr_addr_step          "0.0.1.0"
        set ipv4_svr_addr_port_step     "0.1.0.0" 
        set ipv6_client_iid_step        "00:00:00:01:00:00:00:00"
        set ipv6_client_iid_port_step   "00:00:01:00:00:00:00:00" 
        set ipv6_svr_iid_step           "00:00:00:01:00:00:00:00" 
        set ipv6_svr_iid_port_step      "00:00:01:00:00:00:00:00" 

        set handle [ixNet add $hParent pppoxserver ]
        ixNet commit
    }
    
    method config { args } {}
}

body PppoeServerDevice::config { args } {
    global errorInfo
    global errNumber
    set tag "body PppoeServerDevice::config [info script]"
    Deputs "----- TAG: $tag -----"
    
    #param collection
    Deputs "Args:$args "
    
    chain $args
    
    array set kvList [list]
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -ipv4_client_addr {
                set key -clientBaseIp
                set ipv4_client_addr $value
            }
            -ipv4_client_addr_step {
                set key -clientIpIncr
                set ipv4_client_addr_step $value
                continue
            }
            -ipv4_client_addr_port_step {
                set ipv4_client_addr_port_step $value
                continue
            }
            -ipv4_svr_addr {
                set key -serverBaseIp
                set ipv4_svr_addr $value
            }
            -ipv4_svr_addr_step {
                set key -serverIpIncr
                set ipv4_svr_addr_step $value
                continue
            }
            -ipv4_svr_addr_port_step {
                set ipv4_svr_addr_port_step $value
                continue
            }
            -ipv6_client_iid {
                set key -clientIID
                set ipv6_client_iid $value
            }
            -ipv6_svr_iid {
                set key -serverIID
                set ipv6_svr_iid $value
            }
            -ipv6_svr_iid_step {
                set key -serverIIDIncr
                set ipv6_svr_iid_step $value
                continue
            }
            -ipv6_client_iid_step {
                set key -clientIIDIncr
                set ipv6_client_iid_step $value
                continue
            }
            -ipv6_svr_iid_port_step {
                set ipv6_svr_iid_port_step $value
                continue
            }
            -ipv6_client_iid_port_step {
                set ipv6_client_iid_port_step $value
                continue
            }
            -ipv6_prefix_len {
                set key -ipv6AddrPrefixLen
                set ipv6_prefix_len $value
            }
            -enable_domain {
                set key -enableDomainGroups
                set enable_domain $value 
            }
            -domain {
                set key -domainList 
                set domain $value
            }
            default {
                continue
            }
        }
        set kvList($key) $value
    }
    
    foreach key [array names kvList] {
        switch -exact -- $key {
            -clientBaseIp {
                if { $ipv4_client_addr_port_step != "0.0.0.0" || $ipv4_client_addr_step != "0.0.0.0" } {
                    ConfigAttr $handle $key $kvList($key) $ipv4_client_addr_step $ipv4_client_addr_port_step
                }
            }
            -serverBaseIp {
                if { $ipv4_svr_addr_port_step != "0.0.0.0" || $ipv4_svr_addr_step != "0.0.0.0" } {
                    ConfigAttr $handle $key $kvList($key) $ipv4_svr_addr_step $ipv4_svr_addr_port_step
                }
            }
            -clientIID {
                if { $ipv6_client_iid_step != "00:00:00:00:00:00:00:00" \
                    || $ipv6_client_iid_port_step != "00:00:00:00:00:00:00:00" } {
                    ConfigAttr $handle $key $kvList($key) $ipv6_client_iid_step $ipv6_client_iid_port_step
                }
            }
            -serverIID {
                if { $ipv6_svr_iid_step != "00:00:00:00:00:00:00:00" \
                    || $ipv6_svr_iid_step != "00:00:00:00:00:00:00:00" } {
                    ConfigAttr $handle $key $kvList($key) $ipv6_svr_iid_step $ipv6_svr_iid_port_step
                }
            }
            -domainList -
            -enableDomainGroups {
                set server_session [ixNet getL $handle pppoxServerSessions]
                ConfigAttr $server_session $key $kvList($key)
            }
            default {
                ConfigAttr $handle $key $kvList($key)
            }
        }
    }
    
    return [GetStandardReturnHeader]
}




#class PppoeHost {
#    inherit ProtocolObject
#    
#    #public variable type
#    public variable optionSet
#    public variable rangeStats
#    public variable hostCnt
#    public variable hPppox
#    
#    constructor { port } { chain $port } {}
#    method reborn {} {}
#    method config { args } {}
#    method get_summary_stats {} {}
#    method wait_connect_complete { args } {}
#    method CreatePPPoEPerSessionView {} {
#        set tag "body PppoeHost::CreatePPPoEPerSessionView [info script]"
#        Deputs "----- TAG: $tag -----"
#        set root                [ixNet getRoot]
#        set customView          [ ixNet add $root/statistics view ]
#        ixNet setM  $customView -caption "pppoePerSessionView" -type layer23ProtocolStack -visible true
#        ixNet commit
#        set customView          [ ixNet remapIds $customView ]
#        Deputs "view:$customView"
#        
#        set availableFilter     [ ixNet getList $customView availableProtocolStackFilter ]
#        Deputs "available filter:$availableFilter"
#        
#        set filter              [ ixNet getList $customView layer23ProtocolStackFilter ]
#        Deputs "filter:$filter"
#        Deputs "handle:$handle"
#        
#        set pppoxRange [ixNet getList $handle pppoxRange]
#        Deputs "pppoxRange:$pppoxRange"
#        
#        set rangeName [ ixNet getA $pppoxRange -name ]
#        Deputs "range name:$rangeName"
#        
#        foreach afil $availableFilter {
#            Deputs "$afil"
#            if { [ regexp $rangeName $afil ] } {
#                set stackFilter $afil
#            }
#        }
#        Deputs "stack filter:$stackFilter"
#        ixNet setM $filter -drilldownType perSession -protocolStackFilterId [ list $stackFilter ]
#        ixNet commit
#        set srtStat [lindex [ixNet getF $customView statistic -caption {Session Name}] 0]
#        ixNet setA $filter -sortAscending true -sortingStatistic $srtStat
#        ixNet commit
#        foreach s [ixNet getL $customView statistic] {
#            ixNet setA $s -enabled true
#        }
#        ixNet setA $customView -enabled true
#        ixNet commit
#        return $customView
#    }
#}
#
#body PppoeHost::reborn {} {
#    set tag "body PppoeHost::reborn [info script]"
#    Deputs "----- TAG: $tag -----"
#        
#    chain 
#      
#    set sg_ethernet $stack
#    #-- add pppoe endpoint stack
#    set sg_pppoxEndpoint [ixNet add $sg_ethernet pppoxEndpoint]
#    ixNet setA $sg_pppoxEndpoint -name $this
#    ixNet commit
#    
#    set sg_pppoxEndpoint [lindex [ixNet remapIds $sg_pppoxEndpoint] 0]
#    set hPppox $sg_pppoxEndpoint
#    
#    #-- add range
#    set sg_range [ixNet add $sg_pppoxEndpoint range]
#    ixNet setMultiAttrs $sg_range/macRange \
#        -enabled True 
#    
#    ixNet setMultiAttrs $sg_range/vlanRange \
#        -enabled False \
#    
#    ixNet setMultiAttrs $sg_range/pppoxRange \
#        -enabled True \
#        -numSessions 1
#    
#    ixNet commit
#    set sg_range [ixNet remapIds $sg_range]
#    set handle $sg_range
#    
#    #disable all the interface defined on port
#    foreach int [ ixNet getL $hPort interface ] {
#        ixNet setA $int -enabled false
#    }
#    ixNet commit
#}
#
#body PppoeHost::config { args } {
#    global errorInfo
#    global errNumber
#
#    set tag "body PppoeHost::config [info script]"
#    Deputs "----- TAG: $tag -----"
#        
#    eval { chain } $args
#    
#    set ENcp       [ list ipv4 ipv6 ipv4v6 ]
#    set EAuth      [ list none auto chap_md5 pap ]
#
#    #param collection
#    Deputs "Args:$args "
#    foreach { key value } $args {
#        set key [string tolower $key]
#        switch -exact -- $key {
#            -count {
#                if { [ string is integer $value ] } {
#                    set count $value
#                } else {
#                    error "$errNumber(1) key:$key value:$value"
#                }
#            }
#            -ipcp_encap {
#                set value [ string tolower $value ]
#                if { [ lsearch -exact $ENcp $value ] >= 0 } {
#                    set ipcp_encap $value
#                } else {
#                    error "$errNumber(1) key:$key value:$value"
#                }
#            }
#            -authentication {
#                set value [ string tolower $value ]
#                if { [ lsearch -exact $EAuth $value ] >= 0 } {
#                    set authentication $value
#                } else {
#                    error "$errNumber(1) key:$key value:$value"
#                }
#            }
#            -enable_domain {
#                set trans [ BoolTrans $value ]
#                if { $trans == "1" || $trans == "0" } {
#                    set enable_domain $trans
#                } else {
#                    error "$errNumber(1) key:$key value:$value"
#                }
#            }
#            -domain {
#                set domain $value
#            }
#            -user_name {
#                set user_name $value
#            }
#            -password {
#                set password $value
#            }
#        }
#    }
#    
#    if { [ info exists count ] } {
#        ixNet setMultiAttrs $handle/pppoxRange \
#            -numSessions $count
#    }
#    
#    if { [ info exists ipcp_encap ] } {
#        switch $ipcp_encap {
#            ipv4 {
#                set ipcp_encap IPv4
#            }
#            ipv6 {
#                set ipcp_encap IPv6
#            }
#            ipv4v6 {
#                set ipcp_encap DualStack
#            }
#        }
#        ixNet setA $handle/pppoxRange -ncpType $ipcp_encap
#    }
#    
#    if { [ info exists authentication ] } {
#        switch $authentication {
#            auto {
#                set authentication papOrChap
#                if { [ info exists user_name ] } {
#                    ixNet setMultiAttrs $handle/pppoxRange \
#                        -papUser $user_name \
#                        -chapName $user_name
#                }
#                if { [ info exists password ] } {
#                    ixNet setMultiAttrs $handle/pppoxRange \
#                        -papPassword $password \
#                        -chapSecret $password
#                }    
#            }
#            pap {
#                if { [ info exists user_name ] } {
#                    ixNet setMultiAttrs $handle/pppoxRange \
#                        -papUser $user_name
#                }
#                if { [ info exists password ] } {
#                    ixNet setMultiAttrs $handle/pppoxRange \
#                        -papPassword $password
#                }            
#            }
#            chap_md5 {
#                set authentication chap
#                if { [ info exists user_name ] } {
#                    ixNet setMultiAttrs $handle/pppoxRange \
#                        -chapName $user_name
#                }
#                if { [ info exists password ] } {
#                    ixNet setMultiAttrs $handle/pppoxRange \
#                        -chapSecret $password
#                }            
#            }
#        }
#        ixNet setA $handle/pppoxRange -authType $authentication
#    }
#    
#    if { [ info exists enable_domain ] } {
#        ixNet setA $handle/pppoxRange -enableDomainGroups $enable_domain
#    }
#    
#    if { [ info exists domain ] } {
#        foreach domainGroup [ ixNet getL $handle/pppoxRange domainGroup ] {
#            ixNet remove $domainGroup
#        }
#        
#        foreach domainGroup $domain {
#            set dg [ixNet add $handle/pppoxRange domainGroup ]
#            ixNet setA $dg -baseName $domainGroup
#            ixNet commit
#        }
#    }
#
#    ixNet commit
#    return [GetStandardReturnHeader]
#}
#
#body PppoeHost::get_summary_stats {} {
#    set tag "body PppoeHost::get_summary_stats [info script]"
#    Deputs "----- TAG: $tag -----"
#        
#    # Í³¼ÆÏî
#    # attempted_count
#    # avg_success_transaction_count
#    # connected_success_count
#    # disconnected_success_count
#    # failed_connect_count
#    # failed_disconnect_count
#    # max_setup_time
#    # min_setup_time
#    # retry_count
#    # rx_chap_count
#    # rx_ipcp_count
#    # rx_ipv6cp_count
#    # rx_lcp_config_ack_count
#    # rx_lcp_config_nak_count
#    # rx_lcp_config_reject_count
#    # rx_lcp_config_request_count
#    # rx_lcp_echo_reply_count
#    # rx_lcp_echo_request_count
#    # rx_lcp_term_ack_count
#    # rx_lcp_term_request_count
#    # rx_pap_count
#    # hosts
#    # success_setup_rate
#    # hosts_up
#    # tx_chap_count
#    # tx_ipcp_count
#    # tx_ipv6cp_count
#    # tx_lcp_config_ack_count
#    # tx_lcp_config_nak_count
#    # tx_lcp_config_reject_count
#    # tx_lcp_config_request_count
#    # tx_lcp_echo_reply_count
#    # tx_lcp_echo_request_count
#    # tx_lcp_term_ack_count
#    # tx_lcp_term_request_count
#    # tx_pap_count
#
#    set root [ixNet getRoot]
#    set view {::ixNet::OBJ-/statistics/view:"PPP General Statistics"}
#    Deputs "view:$view"
#    
#    set captionList                 [ ixNet getA $view/page -columnCaptions ]
#    Deputs "caption list:$captionList"
#    
#    set port_name                   [ lsearch -exact $captionList {Stat Name} ]
#    set attempted_count             [ lsearch -exact $captionList {Sessions Initiated} ]
#    set connected_success_count     [ lsearch -exact $captionList {Sessions Succeeded} ]
#
#    set ret [ GetStandardReturnHeader ]
#    
#    set stats [ ixNet getA $view/page -rowValues ]
#    Deputs "stats:$stats"
#
#    set connectionInfo [ ixNet getA $hPort -connectionInfo ]
#    Deputs "connectionInfo :$connectionInfo"
#    regexp -nocase {chassis=\"([0-9\.]+)\" card=\"([0-9\.]+)\" port=\"([0-9\.]+)\"} $connectionInfo match chassis card port
#    Deputs "chas:$chassis card:$card port$port"
#
#    foreach row $stats {
#        eval {set row} $row
#        Deputs "row:$row"
#        Deputs "portname:[ lindex $row $port_name ]"
#        if { [ string length $card ] == 1 } {
#            set card "0$card"
#        }
#        if { [ string length $port ] == 1 } {
#            set port "0$port"
#        }
#        if { "${chassis}/Card${card}/Port${port}" != [ lindex $row $port_name ] } {
#            continue
#        }
#
#        set statsItem   "attempted_count"
#        set statsVal    [ lindex $row $attempted_count ]
#        Deputs "stats val:$statsVal"
#        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
#             
#        set statsItem   "connected_success_count"
#        set statsVal    [ lindex $row $connected_success_count ]
#        Deputs "stats val:$statsVal"
#        set ret $ret[ GetStandardReturnBody $statsItem $statsVal ]
#              
#        Deputs "ret:$ret"
#    }
#        
#    return $ret
#}
#
#body PppoeHost::wait_connect_complete { args } {
#    set tag "body PppoeHost::wait_connect_complete [info script]"
#    Deputs "----- TAG: $tag -----"
#
#    set timeout 300
#
#    foreach { key value } $args {
#        set key [string tolower $key]
#        switch -exact -- $key {
#            -timeout {
#                set trans [ TimeTrans $value ]
#                if { [ string is integer $trans ] } {
#                    set timeout $trans
#                } else {
#                    error "$errNumber(1) key:$key value:$value"
#                }
#            }
#
#        }
#    }
#    
#    set startClick [ clock seconds ]
#    
#    while { 1 } {
#        set click [ clock seconds ]
#        if { [ expr $click - $startClick ] >= $timeout } {
#            return [ GetErrorReturnHeader "timeout" ]
#        }
#        
#        set stats [ get_summary_stats ]
#        set initStats [ GetStatsFromReturn $stats attempted_count ]
#        set succStats [ GetStatsFromReturn $stats connected_success_count ]
#        Deputs "initStats:$initStats == succStats:$succStats ?"        
#        if { $succStats != "" && $succStats >= $initStats && $initStats > 0 } {
#            break    
#        }    
#        after 1000
#    }
#    return [GetStandardReturnHeader]
#}

#Topology/DeviceGroup/Ethernet/PPPoXClient
#Child Lists:
# bgpIpv4Peer (kList : add, remove, getList)
# bgpIpv6Peer (kList : add, remove, getList)
# connector (kOptional : add, remove, getList)
# dhcpv6client (kList : add, remove, getList)
# igmpHost (kList : add, remove, getList)
# igmpQuerier (kList : add, remove, getList)
# mldHost (kList : add, remove, getList)
# mldQuerier (kList : add, remove, getList)
# ospfv2 (kList : add, remove, getList)
# ospfv3 (kList : add, remove, getList)
# pimV4Interface (kList : add, remove, getList)
# pimV6Interface (kList : add, remove, getList)
# port (kManaged : getList)
# tag (kList : add, remove, getList)
# vxlan (kList : add, remove, getList)
#Attributes:
# -acMatchMac (readOnly=False, type=kMultiValue)
# -acMatchName (readOnly=False, type=kMultiValue)
# -acOptions (readOnly=False, type=kMultiValue)
# -actualRateDownstream (readOnly=False, type=kMultiValue)
# -actualRateUpstream (readOnly=False, type=kMultiValue)
# -agentCircuitId (readOnly=False, type=kMultiValue)
# -agentRemoteId (readOnly=False, type=kMultiValue)
# -authRetries (readOnly=False, type=kMultiValue)
# -authTimeout (readOnly=False, type=kMultiValue)
# -authType (readOnly=False, type=kMultiValue)
# -chapName (readOnly=False, type=kMultiValue)
# -chapSecret (readOnly=False, type=kMultiValue)
# -clientDnsOptions (readOnly=False, type=kMultiValue)
# -clientLocalIp (readOnly=False, type=kMultiValue)
# -clientLocalIpv6Iid (readOnly=False, type=kMultiValue)
# -clientNcpOptions (readOnly=False, type=kMultiValue)
# -clientNetmask (readOnly=False, type=kMultiValue)
# -clientNetmaskOptions (readOnly=False, type=kMultiValue)
# -clientPrimaryDnsAddress (readOnly=False, type=kMultiValue)
# -clientSecondaryDnsAddress (readOnly=False, type=kMultiValue)
# -clientSignalIWF (readOnly=False, type=kMultiValue)
# -clientSignalLoopChar (readOnly=False, type=kMultiValue)
# -clientSignalLoopEncapsulation (readOnly=False, type=kMultiValue)
# -clientSignalLoopId (readOnly=False, type=kMultiValue)
# -clientV6NcpOptions (readOnly=False, type=kMultiValue)
# -clientWinsOptions (readOnly=False, type=kMultiValue)
# -clientWinsPrimaryAddress (readOnly=False, type=kMultiValue)
# -clientWinsSecondaryAddress (readOnly=False, type=kMultiValue)
# -connectedVia (readOnly=False, type=kArray[kObjref=/globals/topology/...,/topology/...], deprecated)
# -count (readOnly=True, type=kInteger64)
# -dataLink (readOnly=False, type=kMultiValue)
# -descriptiveName (readOnly=True, type=kString, changeOnTheFly)
# -discoveredIpv4Addresses (readOnly=True, type=kArray[kIPv4])
# -discoveredIpv6Addresses (readOnly=True, type=kArray[kIPv6])
# -discoveredMacs (readOnly=True, type=kArray[kMAC])
# -discoveredRemoteSessionIds (readOnly=True, type=kArray[kInteger])
# -discoveredRemoteTunnelIds (readOnly=True, type=kArray[kInteger])
# -discoveredSessionIds (readOnly=True, type=kArray[kInteger])
# -discoveredTunnelIds (readOnly=True, type=kArray[kInteger])
# -discoveredTunnelIPs (readOnly=True, type=kArray[kIPv4])
# -domainList (readOnly=False, type=kMultiValue)
# -echoReqInterval (readOnly=False, type=kMultiValue)
# -enableDomainGroups (readOnly=False, type=kMultiValue)
# -enableEchoReq (readOnly=False, type=kMultiValue)
# -enableEchoRsp (readOnly=False, type=kMultiValue)
# -enableHostUniq (readOnly=False, type=kMultiValue)
# -enableMaxPayload (readOnly=False, type=kMultiValue)
# -enableRedial (readOnly=False, type=kMultiValue)
# -encaps1 (readOnly=False, type=kMultiValue)
# -encaps2 (readOnly=False, type=kMultiValue)
# -errors (readOnly=True, type=kArray[kStruct[kObjref=//...|kArray[kString]]])
# -hostUniq (readOnly=False, type=kMultiValue)
# -lcpAccm (readOnly=False, type=kMultiValue)
# -lcpEnableAccm (readOnly=False, type=kMultiValue)
# -lcpMaxFailure (readOnly=False, type=kMultiValue)
# -lcpRetries (readOnly=False, type=kMultiValue)
# -lcpStartDelay (readOnly=False, type=kMultiValue)
# -lcpTermRetries (readOnly=False, type=kMultiValue)
# -lcpTimeout (readOnly=False, type=kMultiValue)
# -maxPayload (readOnly=False, type=kMultiValue)
# -mruNegotiation (readOnly=False, type=kMultiValue)
# -mtu (readOnly=False, type=kMultiValue)
# -multiplier (readOnly=False, type=kInteger64)
# -name (readOnly=False, type=kString, changeOnTheFly)
# -ncpRetries (readOnly=False, type=kMultiValue)
# -ncpTimeout (readOnly=False, type=kMultiValue)
# -ncpType (readOnly=False, type=kMultiValue)
# -padiRetries (readOnly=False, type=kMultiValue)
# -padiTimeout (readOnly=False, type=kMultiValue)
# -padrRetries (readOnly=False, type=kMultiValue)
# -padrTimeout (readOnly=False, type=kMultiValue)
# -papPassword (readOnly=False, type=kMultiValue)
# -papUser (readOnly=False, type=kMultiValue)
# -redialMax (readOnly=False, type=kMultiValue)
# -redialTimeout (readOnly=False, type=kMultiValue)
# -serviceName (readOnly=False, type=kMultiValue)
# -serviceOptions (readOnly=False, type=kMultiValue)
# -sessionInfo (readOnly=True, type=kArray[kEnumValue=cLS_CFG_REJ_AUTH,cLS_CHAP_PEER_DET_FAIL,cLS_CHAP_PEER_RESP_BAD,cLS_CODE_REJ_IPCP,cLS_CODE_REJ_IPV6CP,cLS_CODE_REJ_LCP,cLS_ERR_PPP_NO_BUF,cLS_ERR_PPP_SEND_PKT,cLS_LINK_DISABLE,cLS_LOC_IPADDR_BROADCAST,cLS_LOC_IPADDR_CLASS_E,cLS_LOC_IPADDR_INVAL_ACKS_0,cLS_LOC_IPADDR_INVAL_ACKS_DIFF,cLS_LOC_IPADDR_LOOPBACK,cLS_LOC_IPADDR_PEER_MATCH_LOC,cLS_LOC_IPADDR_PEER_NO_GIVE,cLS_LOC_IPADDR_PEER_NO_HELP,cLS_LOC_IPADDR_PEER_NO_TAKE,cLS_LOC_IPADDR_PEER_REJ,cLS_LOOPBACK_DETECT,cLS_NO_NCP,cLS_NONE,cLS_PAP_BAD_PASSWD,cLS_PEER_DISCONNECTED,cLS_PEER_IPADDR_MATCH_LOC,cLS_PEER_IPADDR_PEER_NO_SET,cLS_PPOE_AC_SYSTEM_ERROR,cLS_PPOE_GENERIC_ERROR,cLS_PPP_DISABLE,cLS_PPPOE_NO_HOST_UNIQ,cLS_PPPOE_PADI_TIMEOUT,cLS_PPPOE_PADO_TIMEOUT,cLS_PPPOE_PADR_TIMEOUT,cLS_PROTO_REJ_IPCP,cLS_PROTO_REJ_IPv6CP,cLS_TIMEOUT_CHAP_CHAL,cLS_TIMEOUT_CHAP_RESP,cLS_TIMEOUT_IPCP_CFG_REQ,cLS_TIMEOUT_IPV6CP_CFG_REQ,cLS_TIMEOUT_IPV6CP_RA,cLS_TIMEOUT_LCP_CFG_REQ,cLS_TIMEOUT_LCP_ECHO_REQ,cLS_TIMEOUT_PAP_AUTH_REQ,cLS_TUN_AUTH_FAILED,cLS_TUN_NO_RESOURCES,cLS_TUN_TIMEOUT_ICRQ,cLS_TUN_TIMEOUT_SCCRQ,cLS_TUN_VENDOR_SPECIFIC_ERR])
# -sessionStatus (readOnly=True, type=kArray[kEnumValue=down,notStarted,up])
# -stackedLayers (readOnly=False, type=kArray[kObjref=/globals/topology/...,/topology/...], changeOnTheFly)
# -stateCounts (readOnly=True, type=kStruct[kInteger64|kInteger64|kInteger64|kInteger64])
# -status (readOnly=True, type=kEnumValue=error,mixed,notStarted,started,starting,stopping)
# -unlimitedRedialAttempts (readOnly=False, type=kMultiValue)
#Execs:
# closeIpcp (kObjref=/topology/.../pppoxclient)
# closeIpcp (kObjref=/topology/.../pppoxclient,kArray[kInteger64])
# closeIpcp (kObjref=/topology/.../pppoxclient,kString)
# closeIpv6cp (kObjref=/topology/.../pppoxclient)
# closeIpv6cp (kObjref=/topology/.../pppoxclient,kArray[kInteger64])
# closeIpv6cp (kObjref=/topology/.../pppoxclient,kString)
# openIpcp (kObjref=/topology/.../pppoxclient)
# openIpcp (kObjref=/topology/.../pppoxclient,kArray[kInteger64])
# openIpcp (kObjref=/topology/.../pppoxclient,kString)
# openIpv6cp (kObjref=/topology/.../pppoxclient)
# openIpv6cp (kObjref=/topology/.../pppoxclient,kArray[kInteger64])
# openIpv6cp (kObjref=/topology/.../pppoxclient,kString)
# restartDown (kArray[kObjref=/topology/.../pppoxclient])
# restartDown (kArray[kObjref=/topology/.../pppoxclient],kArray[kInteger64])
# restartDown (kArray[kObjref=/topology/.../pppoxclient],kString)
# sendPing (kObjref=/topology/.../pppoxclient,kString)
# sendPing (kObjref=/topology/.../pppoxclient,kString,kArray[kInteger64])
# sendPing (kObjref=/topology/.../pppoxclient,kString,kString)
# sendPing6 (kObjref=/topology/.../pppoxclient,kString)
# sendPing6 (kObjref=/topology/.../pppoxclient,kString,kArray[kInteger64])
# sendPing6 (kObjref=/topology/.../pppoxclient,kString,kString)
# start (kArray[kObjref=/topology/.../pppoxclient])
# start (kArray[kObjref=/topology/.../pppoxclient],kArray[kInteger64])
# start (kArray[kObjref=/topology/.../pppoxclient],kString)
# stop (kArray[kObjref=/topology/.../pppoxclient])
# stop (kArray[kObjref=/topology/.../pppoxclient],kArray[kInteger64])
# stop (kArray[kObjref=/topology/.../pppoxclient],kString)
#
#
#Topology/DeviceGroup/Ethernet/PPPoXServer
#Child Lists:
# bgpIpv4Peer (kList : add, remove, getList)
# bgpIpv6Peer (kList : add, remove, getList)
# connector (kOptional : add, remove, getList)
# dhcpv6server (kList : add, remove, getList)
# igmpHost (kList : add, remove, getList)
# igmpQuerier (kList : add, remove, getList)
# mldHost (kList : add, remove, getList)
# mldQuerier (kList : add, remove, getList)
# ospfv2 (kList : add, remove, getList)
# ospfv3 (kList : add, remove, getList)
# pimV4Interface (kList : add, remove, getList)
# pimV6Interface (kList : add, remove, getList)
# port (kManaged : getList)
# pppoxServerSessions (kRequired : getList)
# vxlan (kList : add, remove, getList)
#Attributes:
# -acceptAnyAuthValue (readOnly=False, type=kMultiValue)
# -acName (readOnly=False, type=kMultiValue)
# -authRetries (readOnly=False, type=kMultiValue)
# -authTimeout (readOnly=False, type=kMultiValue)
# -authType (readOnly=False, type=kMultiValue)
# -clientBaseIID (readOnly=False, type=kMultiValue, deprecated)
# -clientBaseIp (readOnly=False, type=kMultiValue)
# -clientIID (readOnly=False, type=kMultiValue)
# -clientIIDIncr (readOnly=False, type=kMultiValue)
# -clientIpIncr (readOnly=False, type=kMultiValue)
# -connectedVia (readOnly=False, type=kArray[kObjref=/globals/topology/...,/topology/...], deprecated)
# -count (readOnly=True, type=kInteger64)
# -descriptiveName (readOnly=True, type=kString, changeOnTheFly)
# -dnsServerList (readOnly=False, type=kMultiValue)
# -echoReqInterval (readOnly=False, type=kMultiValue)
# -enableDnsRa (readOnly=False, type=kMultiValue)
# -enableEchoReq (readOnly=False, type=kMultiValue)
# -enableEchoRsp (readOnly=False, type=kMultiValue)
# -enableMaxPayload (readOnly=False, type=kMultiValue)
# -errors (readOnly=True, type=kArray[kStruct[kObjref=//...|kArray[kString]]])
# -ipv6AddrPrefixLen (readOnly=False, type=kMultiValue)
# -ipv6PoolPrefix (readOnly=False, type=kMultiValue)
# -ipv6PoolPrefixLen (readOnly=False, type=kMultiValue)
# -lcpAccm (readOnly=False, type=kMultiValue)
# -lcpEnableAccm (readOnly=False, type=kMultiValue)
# -lcpMaxFailure (readOnly=False, type=kMultiValue)
# -lcpRetries (readOnly=False, type=kMultiValue)
# -lcpStartDelay (readOnly=False, type=kMultiValue)
# -lcpTermRetries (readOnly=False, type=kMultiValue)
# -lcpTimeout (readOnly=False, type=kMultiValue)
# -mruNegotiation (readOnly=False, type=kMultiValue)
# -mtu (readOnly=False, type=kMultiValue)
# -multiplier (readOnly=False, type=kInteger64)
# -name (readOnly=False, type=kString, changeOnTheFly)
# -ncpRetries (readOnly=False, type=kMultiValue)
# -ncpTimeout (readOnly=False, type=kMultiValue)
# -ncpType (readOnly=False, type=kMultiValue)
# -pppoxServerGlobalAndPortData (readOnly=True, type=kObjref=/globals/topology/...,/topology/...)
# -serverBaseIID (readOnly=False, type=kMultiValue, deprecated)
# -serverBaseIp (readOnly=False, type=kMultiValue)
# -serverDnsOptions (readOnly=False, type=kMultiValue)
# -serverIID (readOnly=False, type=kMultiValue)
# -serverIIDIncr (readOnly=False, type=kMultiValue)
# -serverIpIncr (readOnly=False, type=kMultiValue)
# -serverNcpOptions (readOnly=False, type=kMultiValue)
# -serverNetmask (readOnly=False, type=kMultiValue)
# -serverNetmaskOptions (readOnly=False, type=kMultiValue)
# -serverPrimaryDnsAddress (readOnly=False, type=kMultiValue)
# -serverSecondaryDnsAddress (readOnly=False, type=kMultiValue)
# -serverSignalIWF (readOnly=False, type=kMultiValue)
# -serverSignalLoopChar (readOnly=False, type=kMultiValue)
# -serverSignalLoopEncapsulation (readOnly=False, type=kMultiValue)
# -serverSignalLoopId (readOnly=False, type=kMultiValue)
# -serverV6NcpOptions (readOnly=False, type=kMultiValue)
# -serverWinsOptions (readOnly=False, type=kMultiValue)
# -serverWinsPrimaryAddress (readOnly=False, type=kMultiValue)
# -serverWinsSecondaryAddress (readOnly=False, type=kMultiValue)
# -serviceName (readOnly=False, type=kMultiValue)
# -sessionsCount (readOnly=False, type=kInteger64)
# -sessionStatus (readOnly=True, type=kArray[kEnumValue=down,notStarted,up])
# -stackedLayers (readOnly=False, type=kArray[kObjref=/globals/topology/...,/topology/...], changeOnTheFly)
# -stateCounts (readOnly=True, type=kStruct[kInteger64|kInteger64|kInteger64|kInteger64])
# -status (readOnly=True, type=kEnumValue=error,mixed,notStarted,started,starting,stopping)
#Execs:
# restartDown (kArray[kObjref=/topology/.../pppoxserver])
# restartDown (kArray[kObjref=/topology/.../pppoxserver],kArray[kInteger64])
# restartDown (kArray[kObjref=/topology/.../pppoxserver],kString)
# start (kArray[kObjref=/topology/.../pppoxserver])
# start (kArray[kObjref=/topology/.../pppoxserver],kArray[kInteger64])
# start (kArray[kObjref=/topology/.../pppoxserver],kString)
# stop (kArray[kObjref=/topology/.../pppoxserver])
# stop (kArray[kObjref=/topology/.../pppoxserver],kArray[kInteger64])
# stop (kArray[kObjref=/topology/.../pppoxserver],kString)
#
#
#Topology/DeviceGroup/Ethernet/PPPoXServer/PPPoXServerSessions
#Child Lists:
# port (kManaged : getList)
# tag (kList : add, remove, getList)
#Attributes:
# -chapName (readOnly=False, type=kMultiValue)
# -chapSecret (readOnly=False, type=kMultiValue)
# -count (readOnly=True, type=kInteger64)
# -descriptiveName (readOnly=True, type=kString, changeOnTheFly)
# -discoveredClientsMacs (readOnly=True, type=kArray[kMAC])
# -discoveredRemoteSessionIds (readOnly=True, type=kArray[kInteger])
# -discoveredRemoteTunnelIds (readOnly=True, type=kArray[kInteger])
# -discoveredSessionIds (readOnly=True, type=kArray[kInteger])
# -discoveredTunnelIds (readOnly=True, type=kArray[kInteger])
# -discoveredTunnelIPs (readOnly=True, type=kArray[kIPv4])
# -domainList (readOnly=False, type=kMultiValue)
# -enableDomainGroups (readOnly=False, type=kMultiValue)
# -name (readOnly=False, type=kString, changeOnTheFly)
# -papPassword (readOnly=False, type=kMultiValue)
# -papUser (readOnly=False, type=kMultiValue)
# -serverIpv4Addresses (readOnly=True, type=kArray[kIPv4])
# -serverIpv6Addresses (readOnly=True, type=kArray[kIPv6])
#           -sessionInfo (readOnly=True,       type=kArray[kEnumValue=cLS_CFG_REJ_AUTH,cLS_CHAP_PEER_DET_FAIL,cLS_CHAP_PEER_RESP_BAD,cLS_CODE_REJ_IPCP,cLS_CODE_REJ_IPV6CP,cLS_CODE_REJ_LCP,cLS_ERR_PPP_NO_BUF,cLS_ERR_PPP_SEND_PKT,cLS_LINK_DISABLE,cLS_LOC_IPADDR_BROADCAST,cLS_LOC_IPADDR_CLASS_E,cLS_LOC_IPADDR_INVAL_ACKS_0,cLS_LOC_IPADDR_INVAL_ACKS_DIFF,cLS_LOC_IPADDR_LOOPBACK,cLS_LOC_IPADDR_PEER_MATCH_LOC,cLS_LOC_IPADDR_PEER_NO_GIVE,cLS_LOC_IPADDR_PEER_NO_HELP,cLS_LOC_IPADDR_PEER_NO_TAKE,cLS_LOC_IPADDR_PEER_REJ,cLS_LOOPBACK_DETECT,cLS_NO_NCP,cLS_NONE,cLS_PAP_BAD_PASSWD,cLS_PEER_DISCONNECTED,cLS_PEER_IPADDR_MATCH_LOC,cLS_PEER_IPADDR_PEER_NO_SET,cLS_PPOE_AC_SYSTEM_ERROR,cLS_PPOE_GENERIC_ERROR,cLS_PPP_DISABLE,cLS_PPPOE_PADI_TIMEOUT,cLS_PPPOE_PADO_TIMEOUT,cLS_PPPOE_PADR_TIMEOUT,cLS_PROTO_REJ_IPCP,cLS_PROTO_REJ_IPv6CP,cLS_TIMEOUT_CHAP_CHAL,cLS_TIMEOUT_CHAP_RESP,cLS_TIMEOUT_IPCP_CFG_REQ,cLS_TIMEOUT_IPV6CP_CFG_REQ,cLS_TIMEOUT_IPV6CP_RA,cLS_TIMEOUT_LCP_CFG_REQ,cLS_TIMEOUT_LCP_ECHO_REQ,cLS_TIMEOUT_PAP_AUTH_REQ])
#Execs:
# closeIpcp (kArray[kObjref=/topology/.../pppoxServerSessions])
# closeIpcp (kArray[kObjref=/topology/.../pppoxServerSessions],kArray[kInteger64])
# closeIpcp (kArray[kObjref=/topology/.../pppoxServerSessions],kString)
# closeIpv6cp (kArray[kObjref=/topology/.../pppoxServerSessions])
# closeIpv6cp (kArray[kObjref=/topology/.../pppoxServerSessions],kArray[kInteger64])
# closeIpv6cp (kArray[kObjref=/topology/.../pppoxServerSessions],kString)
