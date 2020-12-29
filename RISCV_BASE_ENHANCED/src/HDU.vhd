library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.risc_package.all;

entity HDU is --hazard detection unit
	port(
		ID_EX_MemRead: in std_logic;-- attivo alto
		rs1: in std_logic_vector(length_in_RF - 1 downto 0);-- instruction bits from 19 to 15
		rs2: in std_logic_vector(length_in_RF - 1 downto 0);-- instruction bits from 24 to 20
		rd : in std_logic_vector(length_in_RF - 1 downto 0);-- instruction bits from 11 to 6
		PCWrite: out std_logic;
		IF_ID_Write: out std_logic;
		sel_mux: out std_logic
		
	);    
end HDU; 

architecture arch of HDU is

begin

HDU_proc:process(ID_EX_MemRead, rs1, rs2, rd)

		begin

		if (ID_EX_MemRead= '1') then
			if((rs1=rd) or (rs2=rd)) then
			
			PCWrite<='1' ;
			IF_ID_Write<='1';
			sel_mux<='1';--gira il mux sull'ingresso tutti zero
			
			else
			
			PCWrite<='0';
			IF_ID_Write<='0';
			sel_mux<='0'; --gira il mux sull'ingresso a cui arrivano i controlli della control unit			
			
			end if;
		
		else 
		   PCWrite<='0';
			IF_ID_Write<='0';
			sel_mux<='0';
		end if;

end process;

end arch;