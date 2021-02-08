library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.risc_package.all;

entity reg_NOP is
generic ( n: integer := 32 );
port (
    clk: in std_logic;
	rst: in std_logic;
    d :  in std_logic_vector(n-1 downto 0);
	N_en: in std_logic;--enable attivo basso
	q :  out std_logic_vector(n-1 downto 0));
end reg_NOP;

architecture  behavioural of reg_NOP is
begin
	process (clk, rst)
		begin
		if (rst = '1') then
		
				q <= (others => '0');
				
			elsif (clk'event and clk = '1') then
				
				if (N_en='1') then 
				
					q <= (others=>'0');
					
				else
				
					q<=d;
					
				end if;
		    end if;
	end process;
end behavioural;