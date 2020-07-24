# Setup 
add_force {/design_1_wrapper/S_AXIS_CONFIG_0_tdata} -radix hex {00011 0ns}
add_force {/design_1_wrapper/S_AXIS_CONFIG_0_tvalid} -radix hex {1 0ns}
add_force {/design_1_wrapper/aclk_0} -radix hex {1 0ns} {0 50000ps} -repeat_every 100000ps
add_force {/design_1_wrapper/S_AXIS_DATA_0_tdata} -radix hex {1 0ns}
add_force {/design_1_wrapper/S_AXIS_DATA_0_tvalid} -radix hex {1 0ns}


# Brute-Force random test. 
run 200ns
run 200ns
add_force {/design_1_wrapper/S_AXIS_DATA_0_tlast} -radix hex {1 0ns}
run 200ns
run 200ns
add_force {/design_1_wrapper/S_AXIS_DATA_0_tlast} -radix hex {0 0ns}
add_force {/design_1_wrapper/S_AXIS_DATA_0_tvalid} -radix hex {0 0ns}
run 100 ns
run 100 ns
run 100 ns
add_force {/design_1_wrapper/M_AXIS_DATA_0_tready} -radix hex {1 0ns}
run 100 ns
run 100 ns
run 100 ns
run 100 ns
add_force {/design_1_wrapper/S_AXIS_DATA_0_tdata} -radix hex {12312 0ns}
add_force {/design_1_wrapper/S_AXIS_DATA_0_tvalid} -radix hex {1 0ns}
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
add_force {/design_1_wrapper/S_AXIS_CONFIG_0_tvalid} -radix hex {0 0ns}
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
remove_forces { {/design_1_wrapper/S_AXIS_DATA_0_tvalid} }
add_force {/design_1_wrapper/S_AXIS_DATA_0_tvalid} -radix hex {0 0ns}
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
run 100 ns
add_force {/design_1_wrapper/S_AXIS_DATA_0_tvalid} -radix hex {1 0ns}
run 100 us
add_force {/design_1_wrapper/M_AXIS_DATA_0_tready} -radix hex {0 0ns}
run 100 us
add_force {/design_1_wrapper/S_AXIS_DATA_0_tvalid} -radix hex {0 0ns}
run 100 us


## For second+third figures. 
add_force {/design_1_wrapper/M_AXIS_DATA_0_tready} -radix hex {1 0ns}
run 100 us
add_force {/design_1_wrapper/S_AXIS_DATA_0_tvalid} -radix hex {0 0ns}
add_force {/design_1_wrapper/S_AXIS_DATA_0_tlast} -radix hex {0 0ns}
add_force {/design_1_wrapper/S_AXIS_CONFIG_0_tvalid} -radix hex {0 0ns}
run 100 us
run 100 us
run 100 us
run 10 ns
run 100 us
run 100 us
add_force {/design_1_wrapper/S_AXIS_DATA_0_tvalid} -radix hex {1 0ns}
run 100 us
run 100 us
run 100 us
add_force {/design_1_wrapper/S_AXIS_DATA_0_tdata} -radix hex {132A1 0ns}
add_force {/design_1_wrapper/S_AXIS_DATA_0_tvalid} -radix hex {0 0ns}
run 100 us
run 100 us
add_force {/design_1_wrapper/S_AXIS_DATA_0_tvalid} -radix hex {1 0ns}
run 100 us
run 100 us
run 100 us
run 100 us
run 100 us
run 100 us
run 500 us