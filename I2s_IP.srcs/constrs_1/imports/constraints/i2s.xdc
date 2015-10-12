create_clock -period 434.972 -name BCLK -waveform {0.000 217.486} [get_ports BCLK]
create_clock -period 10.000 -name s_axi_aclk -waveform {0.000 5.000} [get_ports s_axi_aclk]
#set_input_delay -clock [get_clocks BCLK] -clock_fall -min -add_delay 0.000 [get_ports PBLRC]
#set_input_delay -clock [get_clocks BCLK] -clock_fall -max -add_delay 10.000 [get_ports PBLRC]
#set_output_delay -clock [get_clocks BCLK] -min -add_delay 30.000 [get_ports PBDAT]
#set_output_delay -clock [get_clocks BCLK] -max -add_delay 100.000 [get_ports PBDAT]

set_false_path -rise_from [get_clocks s_axi_aclk] -fall_to [get_clocks BCLK]
set_false_path -fall_from [get_clocks BCLK] -rise_to [get_clocks s_axi_aclk]

#create_clock -period 20833.000 -name PBLRC -waveform {0.000 10416.500} [get_ports PBLRC]
