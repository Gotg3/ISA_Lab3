library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.risc_package.all;

entity mux_ID is
	port(
	in_ctrl: in std_logic_vector(out_ctrl -1 downto 0);
	zeros: in std_logic_vector(out_ctrl -1 downto 0):=(others=>'0');
	q: out std_logic_vector(out_ctrl -1 downto 0);
	sel: in std_logic
	);
end mux_ID;

	architecture behavioural of mux_ID is
		begin
			mux_proc:process(in_ctrl,zeros,sel)
			begin
				case sel is
					when '0' =>
						q<=in_ctrl; -- prende l'uscita della control unit
					when others =>
						q<=zeros; -- da in uscita tutti zeri come conseguenza della HDU
				end case;
			end process mux_proc;
	end behavioural;
			