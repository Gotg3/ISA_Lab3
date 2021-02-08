library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.risc_package.all;

entity OR_Gate is

    port(
		 PCsrc : in std_logic;     
		 delayed_PCsrc: in std_logic;      
         output : out std_logic
		);    

end OR_Gate;

architecture behavioural of OR_Gate is

 begin

    output <= PCsrc OR delayed_PCsrc;

end behavioural; 