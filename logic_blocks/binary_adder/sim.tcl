# sim.tcl - xsim batch stimulus + prints

restart

log_wave -r /binary_adder/*
add_wave -r /binary_adder/*

puts "A  B  | O"
puts "---------"

for {set a 0} {$a < 4} {incr a} {
  for {set b 0} {$b < 4} {incr b} {
    set A [format "%02b" $a]
    set B [format "%02b" $b]

    # Force inputs (adjust paths if your top instance name differs)
    add_force -radix bin /binary_adder/A $A
    add_force -radix bin /binary_adder/B $B

    run 1 ns

    set O [get_value -radix bin /binary_adder/O]
    puts "$A $B | $O"

    run 9 ns
  }
}

