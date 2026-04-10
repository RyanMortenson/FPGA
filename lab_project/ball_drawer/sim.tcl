##########################################################################
# Filename: sim.tcl
#
# Author: Ryan Mortenson
# Description: tcl for ball_drawer
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

run 100ns

restart

# add oscillating clock input with 10ns period (100MHz)
add_force clk {0 0} {1 5ns} -repeat_every 10ns

# reset values
add_force -radix hex reset 1


run 20ns

add_force -radix hex reset 0
add_force -radix hex start 1
add_force -radix hex x_in 100
add_force -radix hex y_in 50
run 200ns




