
vcom -93 -work ./work ../src/risc_package.vhd
vcom -93 -work ./work ../src/instruction_memory.vhd
vcom -93 -work ./work ../src/data_memory.vhd

vlog -work ./work ../netlist/RISCV.v
vcom -93 -work ./work ../tb/tb_RISCV.vhd


vsim -L /software/dk/nangate45/verilog/msim6.2g work.tb_RISCV
vsim -L /software/dk/nangate45/verilog/msim6.2g -sdftyp /tb_RISCV/RISCV_comp=../netlist/RISCV.sdf work.tb_RISCV

vcd file ../vcd/myriscv_syn.vcd
vcd add /tb_RISCV/RISCV_comp/*
add wave *
add wave sim:/tb_riscv/dm_comp/ram
run 10 us




