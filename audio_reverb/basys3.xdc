## Basys3 constraints for audio_reverb_top

## Clock
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## Reset
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports btnc]

## Effect enable switch
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports {sw[0]}]

## Pmod I2S2 ADC / line-in on JC
set_property -dict { PACKAGE_PIN L17 IOSTANDARD LVCMOS33 } [get_ports jc7_adc_mclk]
set_property -dict { PACKAGE_PIN M19 IOSTANDARD LVCMOS33 } [get_ports jc8_adc_lrck]
set_property -dict { PACKAGE_PIN P17 IOSTANDARD LVCMOS33 } [get_ports jc9_adc_sclk]
set_property -dict { PACKAGE_PIN R18 IOSTANDARD LVCMOS33 } [get_ports jc10_adc_sdout]

## Pmod I2S2 DAC / line-out on JC
set_property -dict { PACKAGE_PIN K17 IOSTANDARD LVCMOS33 } [get_ports jc1_dac_mclk]
set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33 } [get_ports jc2_dac_lrck]
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports jc3_dac_sclk]
set_property -dict { PACKAGE_PIN P18 IOSTANDARD LVCMOS33 } [get_ports jc4_dac_sdin]

## Basys3 config
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
