source [file join [file dirname [info script]] common.tcl]

set c [cfg]
if {[dict get $c confirm] ne "1"} {
    fail "Refusing to program without CONFIRM=1. This target only loads an existing bitstream into volatile FPGA configuration over JTAG."
}

set bit [file join [dict get $c build] output "[dict get $c top].bit"]
if {![file exists $bit]} {
    fail "Bitstream not found: $bit. Run make bit first."
}

open_hw_manager
connect_hw_server

set targets [get_hw_targets -quiet]
if {[llength $targets] == 0} {
    fail "No hardware targets found."
}

set target [lindex $targets 0]
puts "Opening hardware target: $target"
open_hw_target $target
set_property PARAM.FREQUENCY [dict get $c hw_freq] $target

set candidates {}
foreach device [get_hw_devices -quiet] {
    set part [string tolower [get_property PART $device]]
    set name [string tolower [get_property NAME $device]]
    if {[string match *xcku3p* $part] || [string match *xcku3p* $name]} {
        lappend candidates $device
    }
}

if {[llength $candidates] == 0} {
    fail "No XCKU3P hardware device found."
}
if {[llength $candidates] > 1} {
    fail "More than one XCKU3P device found: $candidates"
}

set device [lindex $candidates 0]
puts "Programming volatile FPGA device $device with $bit"
set_property PROGRAM.FILE $bit $device
program_hw_devices $device
refresh_hw_device $device

close_hw_target
disconnect_hw_server
close_hw_manager
