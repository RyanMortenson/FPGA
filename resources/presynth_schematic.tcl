read_verilog -sv $env(SV_FILES)
synth_design -top $env(MODULE_NAME) -rtl -rtl_skip_mlo -part xc7a35tcpg236-1 -verbose