read_verilog -netlist ../netlist/RISCV.v
read_saif -input ../saif/myriscv_syn.saif -instance tb_riscv/riscv_comp -unit ns -scale 1
create_clock -name MY_CLK clk
report_power > ./report_power_RISCV.txt

