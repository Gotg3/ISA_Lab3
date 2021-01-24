library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.risc_package.all;

entity mux31 is
	port(
		in1		:in std_logic_vector(data_parallelism-1 downto 0);
		in2		:in std_logic_vector(data_parallelism-1 downto 0);
		in3		:in std_logic_vector(data_parallelism-1 downto 0);
		sel		:in std_logic_vector(mux_ctrl-1 downto 0); --2 bit selection
		output	:out std_logic_vector(data_parallelism-1 downto 0)
	);
end entity;
	
	architecture structural of mux31 is
	
	signal output_s: std_logic_vector(data_parallelism-1 downto 0);
	
	begin
	
		process (sel,in1,in2,in3) 
		begin
		
			case sel is
			
			when "00" => output_s<=in1;
					
			when "01" => output_s<=in2;
			
			when others => output_s<=in3;
			
			end case;
		
		end process;
		
		output<=output_s;
	
	end structural;
	
