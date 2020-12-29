library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.risc_package.all;

entity PC is
	  port  (clk: 			               		    in std_logic;
				rst: 			        		    in std_logic;
				PC_src:		                        in std_logic;
				PC_write:           		        in std_logic;  --enable register
				branch_instruction_address:         in std_logic_vector(address_parallelism-1 downto 0);
				PC_out:  	        			    out std_logic_vector(address_parallelism-1 downto 0);
				seq_address:					    out std_logic_vector(address_parallelism-1 downto 0));
end PC;

architecture behavioural of PC is

signal current_address, tmp_address, next_address: std_logic_vector(address_parallelism-1 downto 0);

component mux21 is
generic(n: integer);
	port(
		in1		:in std_logic_vector(n-1 downto 0);
		in2		:in std_logic_vector(n-1 downto 0);
		sel		:in std_logic;
		output	:out std_logic_vector(n-1 downto 0)
	);
end component;

begin


next_address <=  std_logic_vector(unsigned(current_address) + 4); --PC+4 

mux: mux21 generic map(address_parallelism) port map(next_address, branch_instruction_address, PC_src, tmp_address);

	process(clk, rst)
	begin
	
		if (rst = '1') then current_address <= (others => '0');
		
		elsif(clk'event and clk = '1') then
		
			if( PC_write = '1') then current_address <= tmp_address;					
			end if;
			
		end if;
		
	end process;
	
	PC_out <= current_address;
	seq_address <= next_address;
	
end behavioural;