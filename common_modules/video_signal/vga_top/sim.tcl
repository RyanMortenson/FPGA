##########################################################################
# Filename: sim.tcl
#
# Author: Ryan Mortenson
# Description: tcl for vga_top
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

# add oscillating clock input with 10ns period (100MHz)
add_force clk {0 0} {1 5ns} -repeat_every 10ns

# Defaults
add_force btnc 0
add_force btnl 0
add_force btnr 0
add_force btnd 0
add_force sw -radix hex 000

# Reset pulse
add_force btnd 1
run 100ns
add_force btnd 0
run 50ns

set TEN_LINES 320us

# 1) Bars
add_force btnc 0
add_force btnl 0
add_force btnr 0
add_force sw -radix hex 000
run $TEN_LINES

# 2) White
add_force btnl 1
add_force btnr 0
add_force btnc 0
run $TEN_LINES

# 3) Black
add_force btnl 0
add_force btnr 1
add_force btnc 0
run $TEN_LINES

# 4) Switch colors (2 settings)
add_force btnl 0
add_force btnr 0
add_force btnc 1

add_force sw -radix hex F00
run $TEN_LINES

add_force sw -radix hex F0F
run $TEN_LINES