library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.risc_package.all;

entity PC_instr_mem is
port (
        clk: in std_logic;
	    rst: in std_logic;
		PC_write: in std_logic;--enable register
		address: in std_logic_vector(instruction_parallelism -1 downto 0);
		PC_out:  out std_logic_vector(instruction_parallelism-1 downto 0));
end PC_instr_mem;

architecture  behavioural of PC_instr_mem is

begin

	process(clk, rst)
	begin
	
		if (rst = '1') then
		
			PC_out <= (others => '0');
		
		elsif(clk'event and clk = '1') then
		
			if( PC_write = '0') then
			
				PC_out <= address;					
		 
			end if;
		end if;
	end process;
end behavioural;