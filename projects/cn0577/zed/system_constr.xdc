
# cn0577

set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports ref_clk_p]; #G02  FMC_LPC_CLK1_M2C_P
set_property -dict {PACKAGE_PIN C19 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports ref_clk_n]; #G03  FMC_LPC_CLK1_M2C_N
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports dco_p]; #H04  FMC_LPC_CLK0_M2C_P
set_property -dict {PACKAGE_PIN L19 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports dco_n]; #H05  FMC_LPC_CLK0_M2C_N
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports da_p]; #H07  FMC_LPC_LA02_P
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports da_n]; #H08  FMC_LPC_LA02_N
set_property -dict {PACKAGE_PIN M21 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports db_p]; #H10  FMC_LPC_LA04_P
set_property -dict {PACKAGE_PIN M22 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports db_n]; #H11  FMC_LPC_LA04_N
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVDS_25} [get_ports clk_p]; #G06  FMC_LPC_LA00_CC_P
set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVDS_25} [get_ports clk_n]; #G07  FMC_LPC_LA00_CC_N
set_property -dict {PACKAGE_PIN N19 IOSTANDARD LVDS_25} [get_ports cnv_p]; #D08  FMC_LPC_LA01_CC_P
set_property -dict {PACKAGE_PIN N20 IOSTANDARD LVDS_25} [get_ports cnv_n]; #D09  FMC_LPC_LA01_CC_N
set_property -dict {PACKAGE_PIN P22 IOSTANDARD LVCMOS25} [get_ports cnv_en]; #G10  FMC_LPC_LA03_N
set_property -dict {PACKAGE_PIN J20 IOSTANDARD LVCMOS25} [get_ports pd_cntrl]; #G18  FMC_LPC_LA16_P
set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS25} [get_ports testpat_cntrl]; #G21  FMC_LPC_LA20_P
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS25} [get_ports twolanes_cntrl]; #G24  FMC_LPC_LA22_P

# differential propagation delay for ref_clk
set tref_early 0.3
set tref_late  1.5

# 120MHz clock
set clk_period 8.333
# level translator propagation delay of 0.225ns
# 8.333/2 + 0.225 = 4.3915 ~= 4.392

# clocks

create_clock -period $clk_period -name dco [get_ports dco_p]
create_clock -period $clk_period -name ref_clk [get_ports ref_clk_p]
create_clock -period $clk_period -name virt_clk -waveform {0.225 4.392}

# minimum source latency value
set_clock_latency -source -early $tref_early [get_clocks ref_clk]
# maximum source latency value
set_clock_latency -source -late  $tref_late  [get_clocks ref_clk]

set_input_delay -clock dco -max 0.200 [get_ports da_p]
set_input_delay -clock dco -min -0.200 [get_ports da_p]
set_input_delay -clock dco -clock_fall -max -add_delay 0.200 [get_ports da_p]
set_input_delay -clock dco -clock_fall -min -add_delay -0.200 [get_ports da_p]

set_input_delay -clock dco -max 0.200 [get_ports db_p]
set_input_delay -clock dco -min -0.200 [get_ports db_p]
set_input_delay -clock dco -clock_fall -max -add_delay 0.200 [get_ports db_p]
set_input_delay -clock dco -clock_fall -min -add_delay -0.200 [get_ports db_p]

set_output_delay -clock [get_clocks virt_clk] -min [expr -($clk_period + 4.1 - 0.3)] [get_ports cnv_en]
set_output_delay -clock [get_clocks virt_clk] -max [expr -($clk_period + 4.1 - 1.4)] [get_ports cnv_en]

set_clock_groups -name async_dco_ref_clk -asynchronous -group [get_clocks dco] -group [get_clocks ref_clk]

#set_multicycle_path 2 -setup -end   -from dco -to ref_clk
#set_multicycle_path 1 -hold  -start -from dco -to ref_clk

set_property IDELAY_VALUE 27 [get_cells i_system_wrapper/system_i/axi_ltc2387/inst/i_if/i_rx_db/i_rx_data_idelay]
set_property IDELAY_VALUE 27 [get_cells i_system_wrapper/system_i/axi_ltc2387/inst/i_if/i_rx_da/i_rx_data_idelay]
