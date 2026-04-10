open_checkpoint synth.dcp
opt_design
place_design
route_design
report_timing_summary -max_paths 2 -report_unconstrained -file timing.rpt -warn_on_violation
report_utilization -file utilization.rpt
write_bitstream -force design.bit
write_checkpoint -force implement.dcp