
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.risc_package.all;

entity AddSum is
	port(
	BA  	:in std_logic_vector(instruction_parallelism-1 downto 0);
	Offset	:in std_logic_vector(instruction_parallelism-1 downto 0);
	TA		:out std_logic_vector(instruction_parallelism-1 downto 0)
	
	);
end entity;


architecture structural of AddSum is	

	signal Offsetx2	: signed(instruction_parallelism-1 downto 0);
	signal BAs		: signed(instruction_parallelism-1 downto 0);
	
	begin
	
	Offsetx2<=shift_left(signed(Offset),1);
	BAs<=signed(BA);
	
	TA<=std_logic_vector(BAs + Offsetx2);
	
	end structural;