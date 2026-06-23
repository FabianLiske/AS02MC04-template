## AS02MC04 minimal constraints.
## Pins are only taken from the sources listed in README.md; no inferred pins.

## 100 MHz differential system clock.
## Sources:
## - Essenceia article alibaba_cloud.xdc: E18/D18, LVDS, 10 ns period.
## - TiferKing/as02mc04_hack as02mc04/1.0/part0_pins.xml:
##   diff_100mhz_clk_p E18 LVDS, diff_100mhz_clk_n D18 LVDS.
set_property PACKAGE_PIN E18 [get_ports clk_100mhz_p]
set_property IOSTANDARD LVDS [get_ports clk_100mhz_p]
set_property PACKAGE_PIN D18 [get_ports clk_100mhz_n]
set_property IOSTANDARD LVDS [get_ports clk_100mhz_n]
create_clock -period 10.000 -name clk_100mhz [get_ports clk_100mhz_p]

## Four user LEDs used by the default blinky design.
## Sources:
## - Essenceia article alibaba_cloud.xdc: Led_o[0..3] -> B11/C11/A10/B10.
## - TiferKing/as02mc04_hack as02mc04/1.0/part0_pins.xml:
##   GPIO_LED_1..4 -> B11/C11/A10/B10.
##
## IOSTANDARD is intentionally not active here:
## - Essenceia and TiferKing list these LEDs as LVCMOS18.
## - Chester Gillon's notes report that LED and PCI_PERSTN IOSTANDARD were corrected
##   to LVCMOS33 after measuring VCCO with SYSMON.
## Resolve this on your own board before bitstream generation by uncommenting exactly
## one of the IOSTANDARD blocks below.
set_property PACKAGE_PIN B11 [get_ports {led[0]}]
set_property PACKAGE_PIN C11 [get_ports {led[1]}]
set_property PACKAGE_PIN A10 [get_ports {led[2]}]
set_property PACKAGE_PIN B10 [get_ports {led[3]}]

## Option A, documented by Essenceia and TiferKing board files:
# set_property IOSTANDARD LVCMOS18 [get_ports {led[*]}]

## Option B, reported by Chester Gillon after VCCO measurement:
# set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]
