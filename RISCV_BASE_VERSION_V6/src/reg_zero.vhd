library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.risc_package.all;

entity reg_zero is
port (
    clk: in std_logic;
	rst: in std_logic;
    d :  in std_logic;
	N_en: in std_logic;
	q :  out std_logic
	);
end reg_zero;

architecture  behavioural of reg_zero is
begin
	process (clk, rst)
		begin
		if (rst = '1') then
				q <= '0';
			elsif (clk'event and clk = '1') then
			
				if (N_en='1') then 
				
					q<= '0';
					
					else 
					
					q <= d;
					
				end if;
		    end if;
	end process;
end behavioural;