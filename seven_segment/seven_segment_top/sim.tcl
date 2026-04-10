##########################################################################
# Filename: sim.tcl
#
# Author: Ryan Mortenson
# Description: tcl for top level module seven_segment
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

foreach sw {0000 0001 0010 0011 0100 0101 0110 0111 1000 1001 1010 1011 1100 1101 1110 1111} {
    add_force sw $sw
    run 10ns
    puts "sw=${sw} => [get_value -radix bin seg]"
    run 10ns
}


run 10ns
add_force btnl 0
add_force btnc 0
add_force btnr 0

run 10ns
add_force btnl 0
add_force btnc 0
add_force btnr 1

run 10ns
add_force btnl 0
add_force btnc 1
add_force btnr 0

run 10ns
add_force btnl 0
add_force btnc 1
add_force btnr 1

run 10ns
add_force btnl 1
add_force btnc 0
add_force btnr 0

run 10ns
add_force btnl 1
add_force btnc 0
add_force btnr 1

run 10ns
add_force btnl 1
add_force btnc 1
add_force btnr 0

run 10ns
add_force btnl 1
add_force btnc 1
add_force btnr 1