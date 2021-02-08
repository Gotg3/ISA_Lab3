library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;
use work.risc_package.all;

entity data_memory is
	port (
			ADDR: 	 		in std_logic_vector(address_parallelism-1 downto 0);
			DATA_IN:  		in std_logic_vector(data_parallelism-1 downto 0);
			RAM_WR:   		in std_logic;
			RAM_RD:			in std_logic;
			CLK: 			in std_logic;
			DATA_OUT: 		out std_logic_vector(data_parallelism-1 downto 0);
			rst:				in std_logic
			);
end data_memory;

architecture Behavioral of data_memory is

type RAM_ARRAY is array (0 to 21) of std_logic_vector (data_parallelism-1 downto 0);

signal RAM: RAM_ARRAY :=(
0   =>   "00000000000000000000000000001010",
1   =>   "11111111111111111111111111010001",
2   =>   "00000000000000000000000000010110", 
3   =>   "11111111111111111111111111111101", 
4   =>   "00000000000000000000000000001111",
5   =>   "00000000000000000000000000011011",
6   =>   "11111111111111111111111111111100",
7   =>   "00000000000000000000000000000000", 
8   =>   "00000000000000000000000000000000",
9   =>   "00000000000000000000000000000000", 
10  =>   "00000000000000000000000000000000", 
11  =>   "00000000000000000000000000000000",
12  =>   "00000000000000000000000000000000",
13  =>   "00000000000000000000000000000000", 
14  =>   "00000000000000000000000000000000", 
15  =>   "00000000000000000000000000000000",
16  =>   "00000000000000000000000000000000", 
17  =>   "00000000000000000000000000000000",
18  =>   "00000000000000000000000000000000",
19  =>   "00000000000000000000000000000000", 
20  =>   "00000000000000000000000000000000", 
21  =>   "00000000000000000000000000000000"
   ); 
   
   
	
   
   
	
signal decoded_address, encoded_address : std_logic_vector(address_parallelism-1 downto 0);
signal data_out_s: std_logic_vector(data_parallelism-1 downto 0):=(others=>'0');
signal data_in_s :std_logic_vector(data_parallelism-1 downto 0);
signal addr_s	 :std_logic_vector(address_parallelism-1 downto 0);

constant offset : unsigned(data_parallelism-1 downto 0):="00010000000000010000000000000000";
	 
begin 


encoded_address <= addr_s;
decoded_address <= std_logic_vector((unsigned(encoded_address) - offset)/4);


process(clk,rst) begin			--in pipe stage

		if(CLK'EVENT AND CLK='1') then 
		data_in_s<=data_in;
		addr_s<=addr;
		end if;
	
		
end process;





process(CLK,rst) begin --out pipe stage
if (rst='1') then
DATA_OUT<=(others=>'0');
else

if(CLK'EVENT AND CLK='1') then 
 if(RAM_WR='1') then RAM(to_integer(unsigned(decoded_address))) <= data_in_s; --synchronous write
 end if;
 
 if(RAM_RD='1') then 
  DATA_OUT <= RAM(to_integer(unsigned(decoded_address)));
 end if;
end if;
end if;
end process;



end Behavioral;