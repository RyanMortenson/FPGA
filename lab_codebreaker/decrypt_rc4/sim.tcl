##########################################################################
# Filename: sim.tcl
#
# Author: Ryan Mortenson
# Description: tcl for decrypt_rc4
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

# Run the decrypt function by setting enable to 1 with the following inputs:
# key = 24'h010203
# ciphertext = 128'h5745204C4F5645204543454E20333230
add_force -radix hex enable 1
add_force -radix hex key 010203
add_force -radix hex bytes_in 5745204C4F5645204543454E20333230

# Run for 11 us (the decryption should be done by this time)
run 11us

# Set enable to 0 and run for 1 us
add_force -radix hex enable 0
run 1us

#Run the decrypt function by setting enable to 1 with the following inputs:
#key = 24'h3fe21b
#ciphertext = 128'h0f844e5b0b4e42d35d063c6a1a5a1524
add_force -radix hex enable 1
add_force -radix hex key 3fe21b
add_force -radix hex bytes_in 0f844e5b0b4e42d35d063c6a1a5a1524

# Run for 11 us (the decryption should be done by this time)
run 11us

#Set enable to 0 and run for 1 us
add_force -radix hex enable 0
run 1us


