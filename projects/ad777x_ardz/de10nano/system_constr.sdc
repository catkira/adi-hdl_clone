create_clock -period "20.000 ns"  -name sys_clk     [get_ports {sys_clk}]
create_clock -period "16.666 ns"  -name usb1_clk    [get_ports {usb1_clk}]
create_clock -period "488.00 ns"  -name adc_clk     [get_ports {adc_clk_in}]

derive_pll_clocks
derive_clock_uncertainty

set fall_min            194;       # period/2(=244) - skew_bfe(=50)        
set fall_max            294;       # period/2(=244) + skew_are(=50)  

set_input_delay -clock adc_clk -max  $fall_max  [get_ports adc_data_in[*]] -clock_fall -add_delay;
set_input_delay -clock adc_clk -min  $fall_min  [get_ports adc_data_in[*]] -clock_fall -add_delay;

set_input_delay -clock adc_clk -min  $fall_min  [get_ports adc_ready_in  ] -clock_fall -add_delay;
set_input_delay -clock adc_clk -min  $fall_min  [get_ports adc_ready_in  ] -clock_fall -add_delay;
