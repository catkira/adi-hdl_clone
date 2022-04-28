proc gen_fmc_constr {{fmc_index1 fmc} {fmc_index2 {}}} {
  
  set cwd [pwd]
  set carrier [file tail $cwd]
  set eval_board [file tail [file dirname $cwd]]
  
  variable col0_max 0
  variable col1_max 0
  variable col2_max 0
  variable col3_max 0
  variable io_standard_max 0
  variable temp_pin_e 0
  variable last_gbt_pin 0
  variable gbt_exist_flag 0
  
  set carrier_path [glob ../../common/$carrier/$carrier\_$fmc_index1*.txt]
  set carrier_file [open $carrier_path r]
  set carrier_data [read $carrier_file]
  close $carrier_file
  set line_c [join $carrier_data " "]
  
  set constr_file [open "fmc_constr.xdc" w+]
  
  if {[string length $fmc_index2] == 0} {
    set eval_board_path [glob ../common/*_fmc*.txt]
    set eval_board_file [open $eval_board_path r]
    set eval_board_data [read $eval_board_file]
    close $eval_board_file
    set line_e [join $eval_board_data " "]
    for {set i 1} {$i < [expr [llength $line_e] / 6]} {incr i} {
      if {[string match $carrier vcu118] && [string match $fmc_index1 fmcp] && [string match *[lindex $line_e [expr $i*6]]* "D4D5B20B21"]} {
        set last_gbt_pin [lindex $line_e [expr $i*6]]
    	set gbt_exist_flag 1
      }
      if {[string compare $temp_pin_e "-"] == 0} {
        if {[string compare [lindex $line_e [expr $i*6]] $temp_pin_e] != 0 && ![string is digit [string index [lindex $line_e [expr $i*6]] 1]]} {
          puts "[lindex $line_e [expr $i*6]] [lindex $line_e [expr $i*6+1]] [lindex $line_e [expr $i*6]+2] [lindex $line_e [expr $i*6]+3] [lindex $line_e [expr $i*6]+4] [lindex $line_e [expr $i*6]+5]"
          set line_e [linsert  $line_e [expr $i*6-1] "-"]
          incr i -1
          continue
        }
      }
      set temp_pin_e [lindex $line_e [expr $i*6]]
      for {set j 1} {$j < [expr [llength $line_c] / 5]} {incr j} { 
        if {[string compare [lindex $line_e [expr $i*6]] [lindex $line_c [expr $j*5]]] == 0} {
          if {[string compare [lindex $line_c [expr $j*5+2]] "#N/A"] != 0} {
            if {[string length [lindex $line_c [expr $j*5]]] > $col0_max} {
              set col0_max [string length [lindex $line_c [expr $j*5]]]
            }
            if {[string length [lindex $line_c [expr $j*5+1]]] > $col1_max} {
              set col1_max [string length [lindex $line_c [expr $j*5+1]]]
            }
            if {[string length [lindex $line_c [expr $j*5+2]]] > $col2_max} {
              set col2_max [string length [lindex $line_c [expr $j*5+2]]] 
            }
          }
        }  
        if {[string length [lindex $line_e [expr $i*6+3]]] > $col3_max} {
          set col3_max [string length [lindex $line_e [expr $i*6+3]]]
        }
        if {[string compare [lindex $line_e [expr $i*6+4]] "#N/A"] != 0} {
          set io_standard [lindex $line_e [expr $i*6+4]]
          if {[string compare [lindex $line_e [expr $i*6+5]] "#N/A"] != 0} {
            append io_standard " [lindex $line_e [expr $i*6+5]]"
          }
          if {[string length $io_standard] > $io_standard_max} {
            set io_standard_max [string length $io_standard]
          }
        }
      }  
    }
    if {[string match $carrier vcu118] && [string match $fmc_index1 fmcp] && $gbt_exist_flag} {
      puts $constr_file "#----------------------------------------------------------THIS SECTION NEEDS MANUAL EDITING----------------------------------------------------------"
    }
    for {set i 1} {$i < [expr [llength $line_e] / 6]} {incr i} {
      if {[string compare [lindex $line_e [expr $i*6]] "-"] == 0} {
        if {[string compare [lindex $line_e [expr $i*6]] $temp_pin_e] == 0} {continue}
        puts $constr_file ""
      }
      set temp_pin_e [lindex $line_e [expr $i*6]]
      for {set j 1} {$j < [expr [llength $line_c] / 5]} {incr j} {
        if {[string compare [lindex $line_e [expr $i*6]] [lindex $line_c [expr $j*5]]] == 0} {
          if {[string compare [lindex $line_c [expr $j*5+2]] "#N/A"] != 0} {
            set spaces_0 ""
            set spaces_1 ""
            set spaces_2 ""
            set spaces_3 ""
            for {set k 0} {$k < [expr $col0_max - [string length [lindex $line_c [expr $j*5]]]]} {incr k} {append spaces_0 " "}
            for {set k 0} {$k < [expr $col1_max - [string length [lindex $line_c [expr $j*5+1]]]]} {incr k} {append spaces_1 " "}
            for {set k 0} {$k < [expr $col2_max - [string length [lindex $line_c [expr $j*5+2]]]]} {incr k} {append spaces_2 " "}
            for {set k 0} {$k < [expr $col3_max - [string length [lindex $line_e [expr $i*6+3]]]]} {incr k} {append spaces_3 " "}
            if {[string compare [lindex $line_e [expr $i*6+4]] "#N/A"] != 0} {
              set io_standard "$spaces_2 IOSTANDARD [lindex $line_e [expr $i*6+4]]"
              if {[string compare [lindex $line_e [expr $i*6+5]] "#N/A"] != 0} {
                append io_standard " [lindex $line_e [expr $i*6+5]]"
              }
            } else {
                set io_standard ""
            }
            set io_standard [string map -nocase {"," " "} $io_standard]
            if {[string length $io_standard] > 0} {
              for {set k 0} {$k < [expr $io_standard_max + [string length $spaces_2] + 12 - [string length $io_standard]]} {incr k} {append spaces_3 " "}
              puts $constr_file "set_property -dict \{PACKAGE_PIN [lindex $line_c [expr $j*5+2]]$io_standard\} \[get_ports [lindex $line_e [expr $i*6+3]]\]$spaces_3 ; ## [lindex $line_c [expr $j*5]]$spaces_0  [lindex $line_c [expr $j*5+1]] $spaces_1 [lindex $line_c [expr $j*5+3]]"
            } else {
                for {set k 0} {$k < [expr $io_standard_max + 12 - [string length $io_standard]]} {incr k} {append spaces_3 " "}
                puts $constr_file "set_property -dict \{PACKAGE_PIN [lindex $line_c [expr $j*5+2]]\}$spaces_2 \[get_ports [lindex $line_e [expr $i*6+3]]\]$spaces_3 ; ## [lindex $line_c [expr $j*5]]$spaces_0  [lindex $line_c [expr $j*5+1]] $spaces_1 [lindex $line_c [expr $j*5+3]]"
              }
            if {[string match $carrier vcu118] && [string match $fmc_index1 fmcp] && [string match [lindex $line_c [expr $j*5]] $last_gbt_pin] && ![string match [lindex $line_c [expr ($j+2)*5]] $last_gbt_pin] && [string match [lindex $line_e [expr $i*6]] $last_gbt_pin] && ![string match [lindex $line_e [expr ($i+2)*6]] $last_gbt_pin]} {
              puts $constr_file "#-----------------------------------------------------------------------------------------------------------------------------------------------------"
            }
          }
        }
      }
    }
  } else {
      set eval_board_path [glob ../common/*_fmc1.txt]
      set eval_board_file [open $eval_board_path r]
      set eval_board_data [read $eval_board_file]
      close $eval_board_file
      set line_e [join $eval_board_data " "]
      puts $constr_file "#  FMC0\n"
      for {set i 1} {$i < [expr [llength $line_e] / 6]} {incr i} {
        if {[string match $carrier vcu118] && [string match $fmc_index1 fmcp] && [string match *[lindex $line_e [expr $i*6]]* "D4D5B20B21"]} {
          set last_gbt_pin [lindex $line_e [expr $i*6]]
          set gbt_exist_flag 1
        }
        if {[string compare $temp_pin_e "-"] == 0} {
          if {[string compare [lindex $line_e [expr $i*6]] $temp_pin_e] != 0 && ![string is digit [string index [lindex $line_e [expr $i*6]] 1]]} {
            puts "[lindex $line_e [expr $i*6]] [lindex $line_e [expr $i*6+1]] [lindex $line_e [expr $i*6]+2] [lindex $line_e [expr $i*6]+3] [lindex $line_e [expr $i*6]+4] [lindex $line_e [expr $i*6]+5]"
            set line_e [linsert  $line_e [expr $i*6-1] "-"]
            incr i -1
            continue
           }
        }
        set temp_pin_e [lindex $line_e [expr $i*6]]
        for {set j 1} {$j < [expr [llength $line_c] / 5]} {incr j} {
          if {[string compare [lindex $line_e [expr $i*6]] [lindex $line_c [expr $j*5]]] == 0} {
            if {[string compare [lindex $line_c [expr $j*5+2]] "#N/A"] != 0} {
              if {[string length [lindex $line_c [expr $j*5]]] > $col0_max} {
                set col0_max [string length [lindex $line_c [expr $j*5]]]
              }
              if {[string length [lindex $line_c [expr $j*5+1]]] > $col1_max} {
                set col1_max [string length [lindex $line_c [expr $j*5+1]]]
              }
              if {[string length [lindex $line_c [expr $j*5+2]]] > $col2_max} {
                set col2_max [string length [lindex $line_c [expr $j*5+2]]]
              }
            }
          }
          if {[string length [lindex $line_e [expr $i*6+3]]] > $col3_max} {
            set col3_max [string length [lindex $line_e [expr $i*6+3]]]
          }
          if {[string compare [lindex $line_e [expr $i*6+4]] "#N/A"] != 0} {
            set io_standard [lindex $line_e [expr $i*6+4]]
            if {[string compare [lindex $line_e [expr $i*6+5]] "#N/A"] != 0} {
              append io_standard " [lindex $line_e [expr $i*6+5]]"
            }
            if {[string length $io_standard] > $io_standard_max} {
              set io_standard_max [string length $io_standard]
            }
          }
        }
      }
      if {[string match $carrier vcu118] && [string match $fmc_index1 fmcp] && $gbt_exist_flag} {
        puts $constr_file "#----------------------------------------------------------THIS SECTION NEEDS MANUAL EDITING----------------------------------------------------------"
      }
      for {set i 1} {$i < [expr [llength $line_e] / 6]} {incr i} {
        if {[string compare [lindex $line_e [expr $i*6]] "-"] == 0} {
          if {[string compare [lindex $line_e [expr $i*6]] $temp_pin_e] == 0} {continue}
          puts $constr_file ""
        }
        set temp_pin_e [lindex $line_e [expr $i*6]]
        for {set j 1} {$j < [expr [llength $line_c] / 5]} {incr j} {
          if {[string compare [lindex $line_e [expr $i*6]] [lindex $line_c [expr $j*5]]] == 0} {
            if {[string compare [lindex $line_c [expr $j*5+2]] "#N/A"] != 0} {
              set spaces_0 ""
              set spaces_1 ""
              set spaces_2 ""
              set spaces_3 ""
              for {set k 0} {$k < [expr $col0_max - [string length [lindex $line_c [expr $j*5]]]]} {incr k} {append spaces_0 " "}
              for {set k 0} {$k < [expr $col1_max - [string length [lindex $line_c [expr $j*5+1]]]]} {incr k} {append spaces_1 " "}
              for {set k 0} {$k < [expr $col2_max - [string length [lindex $line_c [expr $j*5+2]]]]} {incr k} {append spaces_2 " "}
              for {set k 0} {$k < [expr $col3_max - [string length [lindex $line_e [expr $i*6+3]]]]} {incr k} {append spaces_3 " "}
              if {[string compare [lindex $line_e [expr $i*6+4]] "#N/A"] != 0} {
                set io_standard "$spaces_2 IOSTANDARD [lindex $line_e [expr $i*6+4]]"
                if {[string compare [lindex $line_e [expr $i*6+5]] "#N/A"] != 0} {
                  append io_standard " [lindex $line_e [expr $i*6+5]]"
                }
              } else {
                  set io_standard ""
              }
              set io_standard [string map -nocase {"," " "} $io_standard]
              if {[string length $io_standard] > 0} {
                for {set k 0} {$k < [expr $io_standard_max + [string length $spaces_2] + 12 - [string length $io_standard]]} {incr k} {append spaces_3 " "}
                puts $constr_file "set_property -dict \{PACKAGE_PIN [lindex $line_c [expr $j*5+2]]$io_standard\} \[get_ports [lindex $line_e [expr $i*6+3]]\]$spaces_3 ; ## [lindex $line_c [expr $j*5]]$spaces_0  [lindex $line_c [expr $j*5+1]] $spaces_1 [lindex $line_c [expr $j*5+3]]"
              } else {
                  for {set k 0} {$k < [expr $io_standard_max + 12 - [string length $io_standard]]} {incr k} {append spaces_3 " "}
                  puts $constr_file "set_property -dict \{PACKAGE_PIN [lindex $line_c [expr $j*5+2]]\}$spaces_2 \[get_ports [lindex $line_e [expr $i*6+3]]\]$spaces_3 ; ## [lindex $line_c [expr $j*5]]$spaces_0  [lindex $line_c [expr $j*5+1]] $spaces_1 [lindex $line_c [expr $j*5+3]]"
                }
              if {[string match $carrier vcu118] && [string match $fmc_index1 fmcp] && [string match [lindex $line_c [expr $j*5]] $last_gbt_pin] && ![string match [lindex $line_c [expr ($j+2)*5]] $last_gbt_pin] && [string match [lindex $line_e [expr $i*6]] $last_gbt_pin] && ![string match [lindex $line_e [expr ($i+2)*6]] $last_gbt_pin]} {
                puts $constr_file "#-----------------------------------------------------------------------------------------------------------------------------------------------------"
              }
            }
          }
        }
      }
      set carrier_path [glob ../../common/$carrier/$carrier\_$fmc_index2*.txt]
      set carrier_file [open $carrier_path r]
      set carrier_data [read $carrier_file]
      close $carrier_file
      set line_c [join $carrier_data " "]
      
      set eval_board_path [glob ../common/*_fmc2.txt]
      set eval_board_file [open $eval_board_path r]
      set eval_board_data [read $eval_board_file]
      close $eval_board_file
      set line_e [join $eval_board_data " "]
      
      puts $constr_file "\n#  FMC1\n"
      for {set i 1} {$i < [expr [llength $line_e] / 6]} {incr i} {
        if {[string match $carrier vcu118] && [string match $fmc_index1 fmcp] && [string match *[lindex $line_e [expr $i*6]]* "D4D5B20B21"]} {
          set last_gbt_pin [lindex $line_e [expr $i*6]]
          set gbt_exist_flag 1
        }
        if {[string compare $temp_pin_e "-"] == 0} {
          if {[string compare [lindex $line_e [expr $i*6]] $temp_pin_e] != 0 && ![string is digit [string index [lindex $line_e [expr $i*6]] 1]]} {
            puts "[lindex $line_e [expr $i*6]] [lindex $line_e [expr $i*6+1]] [lindex $line_e [expr $i*6]+2] [lindex $line_e [expr $i*6]+3] [lindex $line_e [expr $i*6]+4] [lindex $line_e [expr $i*6]+5]"
            set line_e [linsert  $line_e [expr $i*6-1] "-"]
            incr i -1
            continue
          }
        }
        set temp_pin_e [lindex $line_e [expr $i*6]]
        for {set j 1} {$j < [expr [llength $line_c] / 5]} {incr j} {
          if {[string compare [lindex $line_e [expr $i*6]] [lindex $line_c [expr $j*5]]] == 0} {
            if {[string compare [lindex $line_c [expr $j*5+2]] "#N/A"] != 0} {
              if {[string length [lindex $line_c [expr $j*5]]] > $col0_max} {
                set col0_max [string length [lindex $line_c [expr $j*5]]]
              }
              if {[string length [lindex $line_c [expr $j*5+1]]] > $col1_max} {
                set col1_max [string length [lindex $line_c [expr $j*5+1]]]
              }
              if {[string length [lindex $line_c [expr $j*5+2]]] > $col2_max} {
                set col2_max [string length [lindex $line_c [expr $j*5+2]]]
              }
            }
          }
          if {[string length [lindex $line_e [expr $i*6+3]]] > $col3_max} {
            set col3_max [string length [lindex $line_e [expr $i*6+3]]]
          }
          if {[string compare [lindex $line_e [expr $i*6+4]] "#N/A"] != 0} {
            set io_standard [lindex $line_e [expr $i*6+4]]
            if {[string compare [lindex $line_e [expr $i*6+5]] "#N/A"] != 0} {
              append io_standard " [lindex $line_e [expr $i*6+5]]"
            }
            if {[string length $io_standard] > $io_standard_max} {
              set io_standard_max [string length $io_standard]
            }
          }
        }
      }
      if {[string match $carrier vcu118] && [string match $fmc_index1 fmcp] && $gbt_exist_flag} {
        puts $constr_file "#----------------------------------------------------------THIS SECTION NEEDS MANUAL EDITING----------------------------------------------------------"
      }
      for {set i 1} {$i < [expr [llength $line_e] / 6]} {incr i} {
        if {[string compare [lindex $line_e [expr $i*6]] "-"] == 0} {
          if {[string compare [lindex $line_e [expr $i*6]] $temp_pin_e] == 0} {continue}
          puts $constr_file ""
        }
        set temp_pin_e [lindex $line_e [expr $i*6]]
        for {set j 1} {$j < [expr [llength $line_c] / 5]} {incr j} {
          if {[string compare [lindex $line_e [expr $i*6]] [lindex $line_c [expr $j*5]]] == 0} {
            if {[string compare [lindex $line_c [expr $j*5+2]] "#N/A"] != 0} {
              set spaces_0 ""
              set spaces_1 ""
              set spaces_2 ""
              set spaces_3 ""
              for {set k 0} {$k < [expr $col0_max - [string length [lindex $line_c [expr $j*5]]]]} {incr k} {append spaces_0 " "}
              for {set k 0} {$k < [expr $col1_max - [string length [lindex $line_c [expr $j*5+1]]]]} {incr k} {append spaces_1 " "}
              for {set k 0} {$k < [expr $col2_max - [string length [lindex $line_c [expr $j*5+2]]]]} {incr k} {append spaces_2 " "}
              for {set k 0} {$k < [expr $col3_max - [string length [lindex $line_e [expr $i*6+3]]]]} {incr k} {append spaces_3 " "}
              if {[string compare [lindex $line_e [expr $i*6+4]] "#N/A"] != 0} {
                set io_standard "$spaces_2 IOSTANDARD [lindex $line_e [expr $i*6+4]]"
                if {[string compare [lindex $line_e [expr $i*6+5]] "#N/A"] != 0} {
                  append io_standard " [lindex $line_e [expr $i*6+5]]"
                }
              } else {
                  set io_standard ""
              }
              set io_standard [string map -nocase {"," " "} $io_standard]
              if {[string length $io_standard] > 0} {
                for {set k 0} {$k < [expr $io_standard_max + [string length $spaces_2] + 12 - [string length $io_standard]]} {incr k} {append spaces_3 " "}
                puts $constr_file "set_property -dict \{PACKAGE_PIN [lindex $line_c [expr $j*5+2]]$io_standard\} \[get_ports [lindex $line_e [expr $i*6+3]]\]$spaces_3 ; ## [lindex $line_c [expr $j*5]]$spaces_0  [lindex $line_c [expr $j*5+1]] $spaces_1 [lindex $line_c [expr $j*5+3]]"
              } else {
                  for {set k 0} {$k < [expr $io_standard_max + 12 - [string length $io_standard]]} {incr k} {append spaces_3 " "}
                  puts $constr_file "set_property -dict \{PACKAGE_PIN [lindex $line_c [expr $j*5+2]]\}$spaces_2 \[get_ports [lindex $line_e [expr $i*6+3]]\]$spaces_3 ; ## [lindex $line_c [expr $j*5]]$spaces_0  [lindex $line_c [expr $j*5+1]] $spaces_1 [lindex $line_c [expr $j*5+3]]"
                }
              if {[string match $carrier vcu118] && [string match $fmc_index1 fmcp] && [string match [lindex $line_c [expr $j*5]] $last_gbt_pin] && ![string match [lindex $line_c [expr ($j+2)*5]] $last_gbt_pin] && [string match [lindex $line_e [expr $i*6]] $last_gbt_pin] && ![string match [lindex $line_e [expr ($i+2)*6]] $last_gbt_pin]} {
                puts $constr_file "#-----------------------------------------------------------------------------------------------------------------------------------------------------"
              }
            }
          }
        }
      }
    }
  close $constr_file
  add_files -fileset constrs_1 -norecurse fmc_constr.xdc
}
