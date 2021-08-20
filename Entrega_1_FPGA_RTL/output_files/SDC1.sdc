# 50MHz board input clock
create_clock -period 20 [get_ports clk]

# Automatically apply a generate clock on the output of phase-locked loops (PLLs) 
derive_pll_clocks