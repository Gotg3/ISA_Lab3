library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.risc_package.all;

entity mux21 is
generic(n: integer);
	port(
		in1		:in std_logic_vector(n-1 downto 0);
		in2		:in std_logic_vector(n-1 downto 0);
		sel		:in std_logic;
		output	:out std_logic_vector(n-1 downto 0)
	);
end entity;
	
	architecture structural of mux21 is
	
	signal output_s: std_logic_vector(n-1 downto 0);
	
	begin
	
		process (sel,in1,in2) 
		begin
		
			case sel is
			
			when '0' => output_s<=in1;
						
			when others => output_s<=in2;
			
			end case;
		
		end process;
		
		output<=output_s;
	
	end structural;
	
