##########################################################################
# Filename: sim.tcl
#
# Author: Ryan Mortenson
# Description: tcl for reg4
#
###########################################################################


set curr_wave [current_wave_config]
if { [string length $curr_wave] == 0 } {
    # If no waveform configuration exists, create one and add top-level signals
    if { [llength [get_objects]] > 0 } {
        add_wave /
        set_property needs_save false [current_wave_config]
    } else {
        # Warning if no top-level signals are found
        send_msg_id Add_Wave-1 WARNING "No top-level signals found. Simulator will start without a wave window. If you want to open a wave window, go to 'File->New Waveform Configuration' or type 'create_wave_config' in the Tcl console."
    }
}

# add oscillating clock input with 10ns period
add_force clk {0 0} {1 5ns} -repeat_every 10ns

run 30ns

#initialize
add_force din 0000
add_force load 0
add_force clr 0

run 100ns

add_force din 0001
add_force load 1
run 10ns
add_force load 0
run 10ns


add_force din 0010
add_force load 1
run 10ns
add_force load 0
run 10ns


add_force din 0011
add_force load 1
run 10ns
add_force load 0
run 10ns


add_force din 0100
add_force load 1
run 10ns
add_force load 0
run 10ns


add_force clr 1
run 10ns
add_force clr 0


add_force din 0101
add_force load 1
run 10ns
add_force load 0
run 10ns


