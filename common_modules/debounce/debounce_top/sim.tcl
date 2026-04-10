##########################################################################
# Filename: sim.tcl
#
# Author: Ryan Mortemson
# Description: tcl for debounce
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
        send_msg_id Add_Wave-1 WARNING "No top-level signals found. Simulator will start without a wave window. If you want to open a wave window, go to 'File->New Waveform Configuration' or type 'create_wave_config' in the Tcl comsole."
    }
}

# add oscillating clock input with 10ms period (100MHz)
add_force clk {0 0} {1 5ns} -repeat_every 10ns
run 20ms

#reset
add_force btnd 1
add_force btnc 0
run 20ms
add_force btnd 0
run 20ms


#short assert
add_force btnc 1
run 1ms
add_force btnc 0
run 1ms

#short assert
add_force btnc 1
run 3ms
add_force btnc 0
run 3ms

#short assert
add_force btnc 1
run 2ms
add_force btnc 0
run 2ms

#short assert
add_force btnc 1
run 20ms

#long then deassert
add_force btnc 1
run 10ms
add_force btnc 0
run 1ms
add_force btnc 1
run 10ms

#short assert
add_force btnc 0
run 10ms
add_force btnc 1
run 4ms
add_force btnc 0
run 10ms


