add_wave .

add_force cin 0

# Simulate positive binary + negative binary
add_force a 00000001
add_force b 10000001
run 10 ns

# Simulate adding two positive binary numbers w/o overflow
add_force a 00000001
add_force b 00000010
run 10 ns

# Simulate adding two positive binary numbers w/ overflow
add_force a 01111111
add_force b 01111110
run 10 ns

# Simulate two negative binary numbers without overflow
add_force a 10000001
add_force b 10000010
run 10 ns

# Simulate two negative binary numbers with overflow
add_force a 11111111
add_force b 11111110
run 10 ns