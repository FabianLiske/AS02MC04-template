## Project-specific AS02MC04 board-port mapping.
##
## This file is the intended place for mappings from named board pins in the
## installed Vivado board file to this project's top-level RTL ports.
##
## You can leave unused example mappings in place. They are emitted only when
## the referenced top-level port exists in the current design.

proc emit_project_board_constraints {fh pins c emitted_ports_var} {
    upvar $emitted_ports_var emitted_ports

    set board_xml [dict get $c board_xml]
    set clk_freq [board_clock_frequency $board_xml diff_100mhz_clk 100000000]
    set clk_period [format %.3f [expr {1000000000.0 / double($clk_freq)}]]
    set led_iostandard [dict get $c led_iostandard]

    puts $fh "## Project mapping: default 100 MHz differential system clock."
    if {[emit_optional_board_port_constraint $fh $pins diff_100mhz_clk_p clk_100mhz_p BOARD emitted_ports]} {
        emit_optional_board_port_constraint $fh $pins diff_100mhz_clk_n clk_100mhz_n BOARD emitted_ports
        emit_optional_clock_constraint $fh clk_100mhz_p $clk_period clk_100mhz
    }

    puts $fh "## Project mapping: default 7 user LEDs."
    puts $fh "## LED_IOSTANDARD=$led_iostandard; use LED_IOSTANDARD=NONE to omit it or override with e.g. LVCMOS33."
    emit_optional_board_port_constraint $fh $pins GPIO_LED_R {led[0]} $led_iostandard emitted_ports
    emit_optional_board_port_constraint $fh $pins GPIO_LED_G {led[1]} $led_iostandard emitted_ports
    emit_optional_board_port_constraint $fh $pins GPIO_LED_H {led[2]} $led_iostandard emitted_ports
    emit_optional_board_port_constraint $fh $pins GPIO_LED_1 {led[3]} $led_iostandard emitted_ports
    emit_optional_board_port_constraint $fh $pins GPIO_LED_2 {led[4]} $led_iostandard emitted_ports
    emit_optional_board_port_constraint $fh $pins GPIO_LED_3 {led[5]} $led_iostandard emitted_ports
    emit_optional_board_port_constraint $fh $pins GPIO_LED_4 {led[6]} $led_iostandard emitted_ports
}
