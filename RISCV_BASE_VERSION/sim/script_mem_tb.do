vcom -93 -work ./work ../src/risc_package.vhd
vcom -93 -work ./work ../src/instruction_memory.vhd


vcom -93 -work ./work ../src/data_memory.vhd

vcom -93 -work ./work ../tb/tb_RISCV.vhd

vsim work.tb_RISCV

add wave *
add wave -position insertpoint  sim:/tb_riscv/IM_comp/DATA_OUT


run 3000 ns

