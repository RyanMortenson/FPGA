##########################################################################

# Filename: sim.tcl

#

# Author: Ryan Mortenson

# Description: tcl for char_gen_top

##########################################################################

# ------------------------------------------------------------

# Create a waveform window with only the required signals

# ------------------------------------------------------------

create_wave_config
add_wave clk
add_wave btnc
add_wave sw
add_wave rx_in
add_wave Hsync
add_wave Vsync
add_wave vgaRed
add_wave vgaGreen
add_wave vgaBlue
add_wave char_addr
add_wave char_we
add_wave char_write_value

# ------------------------------------------------------------

# Initialize inputs (prevents Z → X propagation)

# ------------------------------------------------------------

add_force btnd 0
add_force btnc 0
add_force btnl 0
add_force btnr 0
add_force rx_in 1
add_force sw 0

# add oscillating clock input with 10ns period (100MHz)

add_force clk {0 0} {1 5ns} -repeat_every 10ns

# ------------------------------------------------------------

# Reset sequence

# ------------------------------------------------------------

add_force btnd 1
run 100ns
add_force btnd 0
run 100ns

# ------------------------------------------------------------

# Write character 'S' using btnc

# ------------------------------------------------------------

add_force -radix hex sw 0x53
add_force btnc 1
run 5ms
add_force btnc 0

# ------------------------------------------------------------

# Simulate UART sending character 'A' (0x41)

# ------------------------------------------------------------

# start bit

add_force rx_in 0
run 52083ns

# data bits

add_force rx_in 1
run 52083ns
add_force rx_in 0
run 52083ns
add_force rx_in 0
run 52083ns
add_force rx_in 0
run 52083ns
add_force rx_in 0
run 52083ns
add_force rx_in 0
run 52083ns
add_force rx_in 1
run 52083ns
add_force rx_in 0
run 52083ns

# parity bit

add_force rx_in 1
run 52083ns

# stop bit

add_force rx_in 1
run 52083ns

run 5ms
