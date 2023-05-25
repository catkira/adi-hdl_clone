# ip

source ../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

global VIVADO_IP_LIBRARY

exec -ignorestderr python3 -m pip install -U --user pip
exec -ignorestderr python3 -m pip install --user --no-deps py3gpp
exec python3 ../../submodules/open5G_phy/tools/generate_FFT_demod_tap_file.py --NFFT=8 --CP_LEN=18 --CP_ADVANCE=9 --OUT_DW=16
exec python3 ../../submodules/open5G_phy/tools/generate_PSS_tap_file.py --PSS_LEN=128 --TAP_DW=32 --N_id_2=0
exec python3 ../../submodules/open5G_phy/tools/generate_PSS_tap_file.py --PSS_LEN=128 --TAP_DW=32 --N_id_2=1
exec python3 ../../submodules/open5G_phy/tools/generate_PSS_tap_file.py --PSS_LEN=128 --TAP_DW=32 --N_id_2=2

adi_ip_create open5G_phy
set_property part xc7z010clg400-1 [current_project]
set proj_fileset [get_filesets sources_1]
add_files -norecurse -scan_for_includes -fileset $proj_fileset [list \
  "hdl/receiver.sv" \
  "hdl/receiver_regmap.sv" \
  "hdl/dot_product.sv" \
  "hdl/Peak_detector.sv" \
  "hdl/atan.sv" \
  "hdl/atan2.sv" \
  "hdl/div.sv" \
  "hdl/LFSR/LFSR.sv" \
  "hdl/AXI_lite_interface.sv" \
  "hdl/AXIS_FIFO.sv" \
  "hdl/CFO_calc.sv" \
  "hdl/frame_sync.sv" \
  "hdl/channel_estimator.sv" \
  "hdl/axis_fifo_asym.sv" \
  "hdl/demap.sv" \
  "hdl/PSS_correlator.sv" \
  "hdl/PSS_correlator_mr.sv" \
  "hdl/PSS_detector.sv" \
  "hdl/PSS_detector_regmap.sv" \
  "hdl/ressource_grid_subscriber.sv" \
  "hdl/SSS_detector.sv" \
  "hdl/axis_axil_fifo.sv" \
  "hdl/FFT_demod.sv" \
  "hdl/FFT/fft/fft.v" \
  "hdl/FFT/fft/int_fftNk.v" \
  "hdl/FFT/fft/int_dif2_fly.v" \
  "hdl/FFT/math/cmult/int_cmult_dsp48.v" \
  "hdl/FFT/math/cmult/int_cmult18x25_dsp48.v" \
  "hdl/FFT/math/cmult/int_cmult_dbl18_dsp48.v" \
  "hdl/FFT/math/cmult/int_cmult_dbl35_dsp48.v" \
  "hdl/FFT/math/cmult/int_cmult_trpl18_dsp48.v" \
  "hdl/FFT/math/cmult/int_cmult_trpl52_dsp48.v" \
  "hdl/FFT/math/mults/mlt35x25_dsp48e1.v" \
  "hdl/FFT/math/mults/mlt35x27_dsp48e2.v" \
  "hdl/FFT/math/mults/mlt42x18_dsp48e1.v" \
  "hdl/FFT/math/mults/mlt44x18_dsp48e2.v" \
  "hdl/FFT/math/mults/mlt52x25_dsp48e1.v" \
  "hdl/FFT/math/mults/mlt52x27_dsp48e2.v" \
  "hdl/FFT/math/mults/mlt59x18_dsp48e1.v" \
  "hdl/FFT/math/mults/mlt61x18_dsp48e2.v" \
  "hdl/FFT/math/int_addsub_dsp48.v" \
  "hdl/FFT/buffers/dynamic_block_scaling.v" \
  "hdl/FFT/buffers/inbuf_half_path.v" \
  "hdl/FFT/buffers/outbuf_half_path.v" \
  "hdl/FFT/buffers/int_bitrev_order.v" \
  "hdl/FFT/twiddle/rom_twiddle_int.v" \
  "hdl/FFT/twiddle/row_twiddle_tay.v" \
  "hdl/FFT/delay/int_align_fft.v" \
  "hdl/FFT/delay/int_delay_line.v" \
  "hdl/CIC/cic_d.sv" \
  "hdl/CIC/comb.sv" \
  "hdl/CIC/integrator.sv" \
  "hdl/CIC/downsampler.sv" \
  "hdl/CIC/downsampler_variable.sv" \
  "hdl/DDS/dds.sv" \
  "hdl/complex_multiplier/complex_multiplier.sv" \
  "hdl/axil_interconnect_wrap_1x4.v" \
  "hdl/verilog-axi/axil_interconnect.v" \
  "hdl/verilog-axi/arbiter.v" \
  "hdl/verilog-axi/priority_encoder.v"]

set_property top receiver $proj_fileset
update_compile_order -fileset sources_1

adi_ip_properties_lite open5G_phy
set_property vendor_display_name Catkira [ipx::current_core]
set_property vendor Catkira [ipx::current_core]
set_property company_url http://www.github.com/catkira/open5G_phy [ipx::current_core]
set_property display_name "Open5G_phy" [ipx::current_core]
set_property description "Open5G PHY" [ipx::current_core]
adi_ip_ttcl open5G_phy "open5G_phy_constr.ttcl"

set project_dir [get_property DIRECTORY [current_project]]/
set_property value $project_dir [ipx::get_user_parameters TAP_FILE_PATH -of_objects [ipx::current_core]]
set_property value $project_dir [ipx::get_hdl_parameters TAP_FILE_PATH -of_objects [ipx::current_core]]

adi_add_bus "s_axis_in" "slave" \
	"xilinx.com:interface:axis_rtl:1.0" \
	"xilinx.com:interface:axis:1.0" \
	{
		{"s_axis_in_tvalid" "TVALID"} \
		{"s_axis_in_tdata"  "TDATA"} \
	}
adi_add_bus_clock "sample_clk_i" "s_axis_in"

adi_add_bus "m_axis_out" "master" \
	"xilinx.com:interface:axis_rtl:1.0" \
	"xilinx.com:interface:axis:1.0" \
	{
		{"m_axis_out_tvalid" "TVALID"} \
		{"m_axis_out_tdata"  "TDATA"} \
	}

adi_ip_infer_mm_interfaces open5G_phy
set memory_maps [ipx::get_memory_maps * -of_objects [ipx::current_core]]
foreach map $memory_maps {
  ipx::remove_memory_map [lindex $map 2] [ipx::current_core]
}

set raddr_width [expr [get_property SIZE_LEFT [ipx::get_ports -nocase true s_axi_if_araddr -of_objects [ipx::current_core]]] + 1]
set waddr_width [expr [get_property SIZE_LEFT [ipx::get_ports -nocase true s_axi_if_awaddr -of_objects [ipx::current_core]]] + 1]
  if {$raddr_width != $waddr_width} {
    puts [format "WARNING: AXI address width mismatch for %s (r=%d, w=%d)" $ip_name $raddr_width, $waddr_width]
    set range 65536
  } else {
    if {$raddr_width >= 16} {
      set range 65536
    } else {
      set range [expr 1 << $raddr_width]
    }
  }

ipx::add_memory_map {s_axi_if} [ipx::current_core]
set_property slave_memory_map_ref {s_axi_if} [ipx::get_bus_interfaces s_axi_if -of_objects [ipx::current_core]]
ipx::add_address_block {axi_lite} [ipx::get_memory_maps s_axi_if -of_objects [ipx::current_core]]
set_property range $range [ipx::get_address_blocks axi_lite \
  -of_objects [ipx::get_memory_maps s_axi_if -of_objects [ipx::current_core]]]
#ipx::associate_bus_interfaces -clock clk_i -reset reset_n [ipx::current_core]
adi_add_bus_clock "clk_i" "m_axis_out:s_axi_if" "reset_n"

#ipx::infer_bus_interface reset_ni xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]
#ipx::add_bus_parameter POLARITY [ipx::get_bus_interfaces reset_ni -of_objects [ipx::current_core]]
#set_property value ACTIVE_LOW [ipx::get_bus_parameters POLARITY -of_objects [ipx::get_bus_interfaces reset_ni -of_objects [ipx::current_core]]]

ipx::create_xgui_files [ipx::current_core]
ipx::save_core [ipx::current_core]
