source [file join [file dirname [info script]] common.tcl]

set c [cfg]
set hw_freq [dict get $c hw_freq]

open_hw_manager
connect_hw_server

set targets [get_hw_targets -quiet]
if {[llength $targets] == 0} {
    fail "No hardware targets found."
}

set target [lindex $targets 0]
puts "Opening hardware target: $target"
open_hw_target $target
set_property PARAM.FREQUENCY $hw_freq $target
puts "Set JTAG frequency to $hw_freq Hz"

set devices [get_hw_devices -quiet]
if {[llength $devices] == 0} {
    fail "No hardware devices found on JTAG target."
}

foreach device $devices {
    puts ""
    puts "Device: $device"
    foreach prop [lsort [list_property $device]] {
        set value [get_property $prop $device]
        puts "  $prop = $value"
    }
}

close_hw_target
disconnect_hw_server
close_hw_manager
