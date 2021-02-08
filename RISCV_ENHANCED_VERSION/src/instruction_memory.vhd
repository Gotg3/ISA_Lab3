library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;
use work.risc_package.all;

entity instruction_memory is
	port (
			ADDR: 	 in std_logic_vector(address_parallelism-1 downto 0);
			DATA_IN:  in std_logic_vector(instruction_parallelism-1 downto 0);
			RAM_WR:   in std_logic;
			CLK: 		 in std_logic;
			DATA_OUT: out std_logic_vector(instruction_parallelism-1 downto 0);
			IF_ID_write:    in std_logic;
			PC_write:       in std_logic;
			PC_src:			in std_logic;
			rst		  : in std_logic
			);
end instruction_memory;

architecture Behavioral of instruction_memory is

type RAM_ARRAY is array (0 to 20) of std_logic_vector (instruction_parallelism-1 downto 0);

signal RAM: RAM_ARRAY :=(
0  =>   "00000000011100000000100000010011",
1  =>   "00001111110000010000001000010111",
2  =>   "11111111110000100000001000010011", 
3  =>   "00001111110000010000001010010111", 
4  =>   "00000001000000101000001010010011",
5  =>   "01000000000000000000011010110111",
6  =>   "11111111111101101000011010010011",
7  =>   "00000010000010000000001001100011", 
8  =>   "00000000000000100010010000000011",
9  =>   "00000000100000000001010100110011", 
10 =>   "00000000010000100000001000010011", 
11 =>   "11111111111110000000100000010011", 
12 =>   "00000000110101010010010110110011",
13 =>   "11111110000001011000010011100011", 
14 =>   "00000000000001010000011010110011",
15 =>   "11111110000111111111000011101111",
16 =>   "00000000110100101010000000100011", 
17 =>	"00000000000000000000000011101111", 
18 =>   "00000000000000000000000000010011",--nop
19 =>   "00000000000000000000000000010011",--nop
20 =>   "00000000000000000000000000010011"--nop
 
   ); 
	
signal decoded_address, encoded_address : std_logic_vector(address_parallelism-1 downto 0);
signal data_out_s : std_logic_vector(address_parallelism-1 downto 0):=(others=>'0');
signal PC_out_s   :std_logic_vector(address_parallelism-1 downto 0);
signal ADDR_s : std_logic_vector(address_parallelism-1 downto 0);
signal DATA_IN_s: std_logic_vector(address_parallelism-1 downto 0):=(others=>'0');

	
begin

encoded_address <= ADDR_s;
decoded_address <= std_logic_vector((unsigned(encoded_address) - "00000000010000000000000000000000")/4);



process(CLK,rst) begin --IF/ID reg + RAM

if (rst='1') then 

	DATA_OUT<= "00000000000000000000000000010011";
else
if(CLK'EVENT AND CLK='1') then 
 if(RAM_WR='1') then RAM(to_integer(unsigned(decoded_address))) <= DATA_IN_s; --synchronous write
 else 
	if( IF_ID_write = '0') then  -- if 1 stall
	DATA_OUT <= RAM(to_integer(unsigned(decoded_address))); --DATA_OUT uscita 
	end if;
 end if;
end if;
end if;
end process;


process(clk,rst) begin --PC REG
if(rst='1') then 
	ADDR_s<="00000000010000000000000000000000"; --1st instruction
else
if(CLK'EVENT AND CLK='1') then 

	

	if( (PC_write='0' AND PC_src='0' ) OR (PC_write='0' AND PC_src='1' ) OR (PC_write='1' AND PC_src='1' )   ) then -- tiene in considerazione che se deve saltare deve caricare l'indirizzo di salto
		ADDR_s<=ADDR;
		DATA_IN_s<=DATA_IN;
	end if;
     end if;
end if;
end process;


end Behavioral;