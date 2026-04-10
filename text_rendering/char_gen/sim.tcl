##########################################################################
# Filename: sim.tcl
#
# Author: Ryan Mortenson
# Description: tcl for char_gen
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

# add oscillating clock input with 10ns period (100MHz)
add_force clk {0 0} {1 5ns} -repeat_every 10ns

add_force -radix hex char_we 1
add_force -radix hex char_addr 000
add_force -radix hex char_value 41


run 20ns

add_force -radix hex pixel_y 2
add_force -radix hex pixel_x 0
run 20ns
add_force -radix hex pixel_x 1
run 20ns
add_force -radix hex pixel_x 2
run 20ns
add_force -radix hex pixel_x 3
run 20ns
add_force -radix hex pixel_x 4
run 20ns
add_force -radix hex pixel_x 5
run 20ns
add_force -radix hex pixel_x 6
run 20ns
add_force -radix hex pixel_x 7

run 20ns

add_force -radix hex pixel_y 3
add_force -radix hex pixel_x 0
run 20ns
add_force -radix hex pixel_x 1
run 20ns
add_force -radix hex pixel_x 2
run 20ns
add_force -radix hex pixel_x 3
run 20ns
add_force -radix hex pixel_x 4
run 20ns
add_force -radix hex pixel_x 5
run 20ns
add_force -radix hex pixel_x 6
run 20ns
add_force -radix hex pixel_x 7
run 20ns

