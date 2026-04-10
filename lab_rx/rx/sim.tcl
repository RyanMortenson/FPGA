##########################################################################
# Filename: sim.tcl
#
# Author: Ryan Mortenson
# Description: tcl for rx
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

add_force rst 1
run 20ns
add_force rst 0
run 20ns


# ------------------------------------------------------------
# 3) Set reset=1 and default values for all inputs, run a few cycles
# ------------------------------------------------------------
add_force rst 1
add_force Sin 1
add_force ReceiveAck 0
run 200ns

# ------------------------------------------------------------
# 4) Deassert reset and run a few cycles
# ------------------------------------------------------------
add_force rst 0
run 200ns

# ------------------------------------------------------------
# Bit time for 19,200 baud = 52.083us = 52083ns
# ------------------------------------------------------------

# ------------------------------------------------------------
# 5) Transmit 0x41 (ASCII 'A') with CORRECT ODD parity
# 0x41 = 0100_0001 (LSB-first bits: 1,0,0,0,0,0,1,0)
# Ones in data = 2 (even) => ODD parity bit must be 1
# Frame: start(0), 8 data bits, parity, stop(1)
# ------------------------------------------------------------

# start bit
add_force Sin 0
run 52083ns

# data bits b0..b7 (LSB first) for 0x41: 1 0 0 0 0 0 1 0
add_force Sin 1
run 52083ns
add_force Sin 0
run 52083ns
add_force Sin 0
run 52083ns
add_force Sin 0
run 52083ns
add_force Sin 0
run 52083ns
add_force Sin 0
run 52083ns
add_force Sin 1
run 52083ns
add_force Sin 0
run 52083ns

# parity bit (correct ODD) = 1
add_force Sin 1
run 52083ns

# stop bit
add_force Sin 1
run 52083ns

# ------------------------------------------------------------
# 6) Run at least 100 us after end of serial transmission
# ------------------------------------------------------------
run 100us

# ------------------------------------------------------------
# 7) Assert ReceiveAck and run for 10 us
# ------------------------------------------------------------
add_force ReceiveAck 1
run 10us
add_force ReceiveAck 0

# ------------------------------------------------------------
# 8) Transmit 0x5E (ASCII '^') with INCORRECT ODD parity
# 0x5E = 0101_1110 (LSB-first bits: 0,1,1,1,1,0,1,0)
# Ones in data = 5 (odd) => correct ODD parity bit would be 0
# INCORRECT => send parity bit = 1
# ------------------------------------------------------------

# start bit
add_force Sin 0
run 52083ns

# data bits b0..b7 (LSB first) for 0x5E: 0 1 1 1 1 0 1 0
add_force Sin 0
run 52083ns
add_force Sin 1
run 52083ns
add_force Sin 1
run 52083ns
add_force Sin 1
run 52083ns
add_force Sin 1
run 52083ns
add_force Sin 0
run 52083ns
add_force Sin 1
run 52083ns
add_force Sin 0
run 52083ns

# parity bit (INCORRECT ODD) = 1
add_force Sin 1
run 52083ns

# stop bit
add_force Sin 1
run 52083ns

# (extra time to observe Receive/parityErr on the second byte)
run 150us


