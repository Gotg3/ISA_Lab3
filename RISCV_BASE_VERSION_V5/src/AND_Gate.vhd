library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.risc_package.all;

entity AND_Gate is

    port(
		 z_MEM_in : in std_logic;     
		 BranchCTRL: in std_logic;      
         PCsrc : out std_logic
		);    

end AND_Gate;

architecture behavioural of AND_Gate is

 begin

    PCsrc <= z_MEM_in AND BranchCTRL;

end behavioural; 