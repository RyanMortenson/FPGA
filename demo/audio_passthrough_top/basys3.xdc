## Basys3 top-level constraints for demo/audio_passthrough_top

## Clock signal
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## LEDs
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports {led[2]}]

## Buttons
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports btnc]

## Pmod Header JC
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports jc1_dac_mclk]
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports jc2_dac_lrck]
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports jc3_dac_sclk]
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports jc4_dac_sdin]
set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33 } [get_ports jc7_adc_mclk]
set_property -dict { PACKAGE_PIN M19   IOSTANDARD LVCMOS33 } [get_ports jc8_adc_lrck]
set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports jc9_adc_sclk]
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports jc10_adc_sdout]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
