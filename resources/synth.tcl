read_verilog -sv $env(SV_FILES)
read_xdc $env(XDC_PATH)
source ../$env(REPO_PATH)/resources/messages.tcl
synth_design -top $env(MODULE_NAME) -part xc7a35tcpg236-1 -verbose {*}$env(SYNTH_PARAMS)
write_verilog -force synth.v
write_checkpoint -force synth.dcp