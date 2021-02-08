library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.risc_package.all;

entity forwarding_unit is
	port(
	rwrite_ex_mem	:in std_logic;
	rwrite_mem_wb	:in std_logic;
	rd_in_ex_mem	:in std_logic_vector(source_reg-1 downto 0);
	rd_in_mem_wb	:in std_logic_vector(source_reg-1 downto 0);
	rs1_in_id_ex	:in std_logic_vector(source_reg-1 downto 0);
	rs2_in_id_ex	:in std_logic_vector(source_reg-1 downto 0);
	forward1 		:out std_logic_vector(mux_ctrl-1 downto 0);
	forward2   		:out std_logic_vector(mux_ctrl-1 downto 0)
	);
end entity;


architecture structural of forwarding_unit is
	
	signal forward1_s :std_logic_vector(mux_ctrl-1 downto 0); --:="00";
	signal forward2_s :std_logic_vector(mux_ctrl-1 downto 0);--:="00";
	
	
	begin

	process(rwrite_ex_mem,rd_in_ex_mem,rs1_in_id_ex,rwrite_mem_wb,rd_in_mem_wb) 
	begin

	--forward1
	if(rwrite_mem_wb = '1' AND (unsigned(rd_in_mem_wb) /= to_unsigned(0, rd_in_mem_wb'length)) AND rd_in_mem_wb = rs1_in_id_ex ) then
	
			
		forward1_s<="10"; --select MEM/WB
	
	
	elsif (rwrite_ex_mem = '1' AND (unsigned(rd_in_ex_mem) /= to_unsigned(0, rd_in_ex_mem'length)) AND rd_in_ex_mem = rs1_in_id_ex ) then
	
	
		forward1_s<="01"; --select EX/MEM
	
	
	else
	
		forward1_s<="00"; --normal
		
	end if;
	
	end process;



	process(rwrite_ex_mem,rd_in_ex_mem,rs2_in_id_ex,rwrite_mem_wb,rd_in_mem_wb) 
	begin
	--forward2
	if(rwrite_mem_wb = '1' AND (unsigned(rd_in_mem_wb) /= to_unsigned(0, rd_in_mem_wb'length)) AND rd_in_mem_wb = rs2_in_id_ex ) then
	
			
		forward2_s<="10"; --select MEM/WB
	
	
	elsif (rwrite_ex_mem = '1' AND (unsigned(rd_in_ex_mem) /= to_unsigned(0, rd_in_ex_mem'length)) AND rd_in_ex_mem = rs2_in_id_ex ) then
	
	
		forward2_s<="01"; --select EX/MEM
	
	
	else
	
		forward2_s<="00"; --normal
		
	end if;
	end process;

	
	forward1<=forward1_s;
	forward2<=forward2_s;

	
	
end structural;