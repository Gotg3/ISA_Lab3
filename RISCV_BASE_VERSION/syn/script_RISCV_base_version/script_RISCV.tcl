analyze -f vhdl -lib work ../src/risc_package.vhd
analyze -f vhdl -lib work ../src/AddSum.vhd
analyze -f vhdl -lib work ../src/ALU.vhd
analyze -f vhdl -lib work ../src/ALU_control.vhd
analyze -f vhdl -lib work ../src/AND_Gate.vhd
analyze -f vhdl -lib work ../src/OR_Gate.vhd
analyze -f vhdl -lib work ../src/CU.vhd
analyze -f vhdl -lib work ../src/forwarding_unit.vhd
analyze -f vhdl -lib work ../src/HDU.vhd
analyze -f vhdl -lib work ../src/imm_gen.vhd
analyze -f vhdl -lib work ../src/mux_ID.vhd
analyze -f vhdl -lib work ../src/mux21.vhd
analyze -f vhdl -lib work ../src/mux31.vhd
analyze -f vhdl -lib work ../src/PC.vhd
analyze -f vhdl -lib work ../src/PC_instr_mem.vhd
analyze -f vhdl -lib work ../src/reg.vhd
analyze -f vhdl -lib work ../src/reg_zero.vhd
analyze -f vhdl -lib work ../src/reg_NOP.vhd
analyze -f vhdl -lib work ../src/reg_jal_PC_IF_ID.vhd
analyze -f vhdl -lib work ../src/register_file.vhd
analyze -f vhdl -lib work ../src/EX_stage.vhd
analyze -f vhdl -lib work ../src/ID_stage.vhd
analyze -f vhdl -lib work ../src/IF_stage.vhd
analyze -f vhdl -lib work ../src/MEM_stage.vhd
analyze -f vhdl -lib work ../src/WB_stage.vhd
analyze -f vhdl -lib work ../src/RISCV.vhd
elaborate RISCV -arch structural -lib WORK > ./elaborate_RISCV.txt

