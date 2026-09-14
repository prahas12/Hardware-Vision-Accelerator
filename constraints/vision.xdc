# Clock signal (50MHz clock) - Relaxed to fix setup timing violations
create_clock -period 20.000 -name clk -waveform {0.000 10.000} [get_ports clk]

# Input Delays (Fixes TIMING-18 and XDCH-2 Warnings)
# We tell Vivado that external signals arrive with max/min constraints
set_input_delay -clock [get_clocks clk] -max 2.000 [get_ports rst_n]
set_input_delay -clock [get_clocks clk] -min 0.500 [get_ports rst_n]

set_input_delay -clock [get_clocks clk] -max 2.000 [get_ports valid_in]
set_input_delay -clock [get_clocks clk] -min 0.500 [get_ports valid_in]

set_input_delay -clock [get_clocks clk] -max 2.000 [get_ports {pixel_in[*]}]
set_input_delay -clock [get_clocks clk] -min 0.500 [get_ports {pixel_in[*]}]

# Output Delays (Fixes TIMING-18 and XDCH-2 Warnings)
set_output_delay -clock [get_clocks clk] -max 2.000 [get_ports valid_out]
set_output_delay -clock [get_clocks clk] -min 0.500 [get_ports valid_out]

set_output_delay -clock [get_clocks clk] -max 2.000 [get_ports {pixel_out[*]}]
set_output_delay -clock [get_clocks clk] -min 0.500 [get_ports {pixel_out[*]}]
