add_wave .

# Simulate a=0, b=0, cin=0 for 10 ns
add_force a 0
add_force b 0
add_force cin 0
run 10 ns

# Simulate a=0, b=0, cin=1 for 10 ns
add_force a 0
add_force b 0
add_force cin 1
run 10 ns

# Simulate a=0, b=1, cin=0 for 10 ns
add_force a 0
add_force b 1
add_force cin 0
run 10 ns

# Simulate a=0, b=1, cin=1 for 10 ns
add_force a 0
add_force b 1
add_force cin 1
run 10 ns

# Simulate a=1, b=0, cin=0 for 10 ns
add_force a 1
add_force b 0
add_force cin 0
run 10 ns

# Simulate a=1, b=0, cin=1 for 10 ns
add_force a 1
add_force b 0
add_force cin 1
run 10 ns

# Simulate a=1, b=1, cin=0 for 10 ns
add_force a 1
add_force b 1
add_force cin 0
run 10 ns

# Simulate a=1, b=1, cin=1 for 10 ns
add_force a 1
add_force b 1
add_force cin 1
run 10 ns