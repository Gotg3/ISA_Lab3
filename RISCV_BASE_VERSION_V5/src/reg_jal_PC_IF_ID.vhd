library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.risc_package.all;

entity reg_jal_PC_IF_ID is
port (
      clk: in std_logic;
		rst: in std_logic;
		IF_ID_write: in std_logic;
		d :  in std_logic_vector(instruction_parallelism-1 downto 0);
		q :  out std_logic_vector(instruction_parallelism-1 downto 0));
end reg_jal_PC_IF_ID;

architecture  behavioural of reg_jal_PC_IF_ID is

signal s: std_logic_vector(instruction_parallelism-1 downto 0);
begin

	reg:process (clk, rst)
		begin
		
		if (rst = '1') then
		
			s <= (others => '0');
		
		else
					
		if(clk'event and clk = '1') then
			
			s <= d;
					
		
		end if;
		end if;
	end process;
	
	mux:process(rst, IF_ID_write,s)
	    begin
		 
		 if (rst = '1') then
		
			q <= (others => '0');
		
		else
		
		if(IF_ID_write = '1') then
		
			q <= (others => '0');--NOP 
		
		else
		
			q <= s;
		
		end if;
		end if;
	end process;
	
end behavioural;