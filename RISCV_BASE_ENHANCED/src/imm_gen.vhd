library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.risc_package.all;

entity imm_gen is 
	port(
		rst: in std_logic;--reset attivo alto
		sel: in std_logic_vector(sel_imm-1 downto 0);
		instruction: in std_logic_vector(instruction_parallelism - 1 downto 0);
		immediate: out std_logic_vector(data_parallelism - 1 downto 0)
		
	);    
end imm_gen; 

architecture structural of imm_gen is
	
	signal instruction_s : std_logic_vector(instruction_parallelism - 1 downto 0);
	signal immediate_s : std_logic_vector(data_parallelism - 1 downto 0);

begin
	
	
   immediate_proc: process(rst, sel, instruction_s)
	begin
	
	if(rst = '1') then
		 		
		immediate_s<=(others=>'0');

	else
	
	case sel is
	
    when "000" => -- ADDI/LW/ANDI I-type
	immediate_s<=std_logic_vector(resize(signed(instruction_s(31 downto 20)), data_parallelism));
	when "001" => --LUI/AUIPC U-type
	immediate_s<=std_logic_vector(shift_left(signed(std_logic_vector(resize(signed(instruction_s(31 downto 12)), data_parallelism))),trailing_zeros));
	when "010" => --JAL J-type
	immediate_s<= std_logic_vector(resize(signed(instruction_s(31) & instruction_s(19 downto 12) & instruction_s(20) & instruction_s(30 downto 21)), data_parallelism));
	when "011" => --SW  S-type
	immediate_s<= std_logic_vector(resize(signed(instruction_s(31 downto 25) & instruction_s(11 downto 7)), data_parallelism));
	when "100" => --BEQ SB-type
	immediate_s<=std_logic_vector(resize(signed(instruction_s(31) & instruction_s(7) & instruction_s(30 downto 25) & instruction_s(11 downto 8)), data_parallelism));
	when "101" => -- SRAI  I-type (special)
	immediate_s<=instruction_s;
	when others =>
	immediate_s<=(others=>'0');
	
end case;
end if;
end process immediate_proc;

instruction_s<=instruction;
immediate<=immediate_s;

end structural;