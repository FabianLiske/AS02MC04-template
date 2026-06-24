## Local AS02MC04 constraints and overrides.
##
## Pin constraints for the default template are generated from the installed
## Vivado board files by scripts/board_constraints.tcl and written to:
##   build/<name>/generated/as02mc04_board.xdc
##
## Keep this file for project-specific constraints that are not present in the
## board files, or for deliberate local overrides after verifying the hardware.
##
## Example override if your board's LED VCCO measurement requires LVCMOS33
## instead of the board-file value:
##
## set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]
