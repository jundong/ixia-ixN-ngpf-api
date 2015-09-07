
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
    method wait_connect_complete { args } {}
    method get_view_stats { args } {}
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

#==================================================================
#函数名：  get_view_stats
#功能：    通过结果视图名字和列名取得指定结果数据
#输入参数：args
#          -view_name - 结果视图名字，默认设置为“Protocols Summary“
#          -captions - 结果视图列名, 如果没有指定，将返回全部列结果
#返回值：  
#          按指定列，序列的按行返回所以结果
#          caption1 caption2 caption3
#              1       1        1
#              2       2        2
#==================================================================
body PppoeObject::get_view_stats { args } {
    set tag "body PppoeObject::get_view_stats [info script]"
    Deputs "----- TAG: $tag -----"
    
    set view_name ""
    set captions [list]
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -view_name {
                set view_name [ getViewObject $value ]
                if { $view_name == "" } {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
            -captions {
                set captions $value
            }
            default {
                continue
            }
        }
    }
    
    if { $view_name == "" } {
        set view_name [ getViewObject "Protocols Summary" ]
    }
    Deputs "view:$view_name"
    
    set captionList [ ixNet getA $view_name/page -columnCaptions ]
    set statList [ ixNet getA $view_name/page -rowValues ]
    
    if { [llength $captions] == 0 } {
        set captions $captionList
    }
        
    set retList [list]
    lappend retList $captions
    foreach row $statList {
        eval {set row} $row
        set rowValues [list]
        foreach caption $captions {
            set index [ lsearch -exact $captionList $caption ]
            lappend rowValues [ lindex $row $index ]
            Deputs "$caption: [ lindex $row $index ]"
        }
        if { [llength $rowValues] != 0 } {
            lappend retList $rowValues
        }
    }
        
    return $retList
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
    method wait_connect_complete { args } {}
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

body PppoeClientDevice::wait_connect_complete { args } {
    set tag "body PppoeClientDevice::wait_connect_complete [info script]"
    Deputs "----- TAG: $tag -----"

    set timeout 300
    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -timeout {
                set trans [ TimeTrans $value ]
                if { [ string is integer $trans ] } {
                    set timeout $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }
        }
    }
    
    set startClick [ clock seconds ]
    while { 1 } {
        set click [ clock seconds ]
        if { [ expr $click - $startClick ] >= $timeout } {
            return [ GetErrorReturnHeader "timeout" ]
        }
        
        set stats [ get_view_stats -view_name "Protocols Summary" -captions [list {Protocol Type} {Sessions Up} {Sessions Total}]]
        set totalSessions 0
        set upSessions    0
        foreach results $stats {
            if { [lindex $results 0] == "PPPoX Client" } {
                set totalSessions [lindex $results 2]
                set upSessions [lindex $results 1]
                Deputs "Total Sessions:$totalSessions == Sessions Up:$upSessions ?"  
            }
        }     
        if { $upSessions != 0 && $totalSessions > 0 && $upSessions == $totalSessions } {
            break    
        }    
        after 1000
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
    method wait_connect_complete { args } {}
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

body PppoeServerDevice::wait_connect_complete { args } {
    set tag "body PppoeServerDevice::wait_connect_complete [info script]"
    Deputs "----- TAG: $tag -----"

    set timeout 300

    foreach { key value } $args {
        set key [string tolower $key]
        switch -exact -- $key {
            -timeout {
                set trans [ TimeTrans $value ]
                if { [ string is integer $trans ] } {
                    set timeout $trans
                } else {
                    error "$errNumber(1) key:$key value:$value"
                }
            }

        }
    }
    
    set startClick [ clock seconds ]
    while { 1 } {
        set click [ clock seconds ]
        if { [ expr $click - $startClick ] >= $timeout } {
            return [ GetErrorReturnHeader "timeout" ]
        }
        
        set stats [ get_view_stats -view_name "Protocols Summary" -captions [list {Protocol Type} {Sessions Up} {Sessions Total}]]
        set totalSessions 0
        set upSessions    0
        foreach results $stats {
            if { [lindex $results 0] == "PPPoX Server" } {
                set totalSessions [lindex $results 2]
                set upSessions [lindex $results 1]
                Deputs "Total Sessions:$totalSessions == Sessions Up:$upSessions ?"  
            }
        }     
        if { $upSessions != 0 && $totalSessions > 0 && $upSessions == $totalSessions } {
            break    
        }    
        after 1000
    }
    return [GetStandardReturnHeader]
}
