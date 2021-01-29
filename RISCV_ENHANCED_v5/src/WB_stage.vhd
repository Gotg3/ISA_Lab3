library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.risc_package.all;

entity WB_stage is
		   port ( 
					 ALUout_WB_in        :    in std_logic_vector(instruction_parallelism-1 downto 0);
					 immediate_WB_in     :    in std_logic_vector(instruction_parallelism-1 downto 0);
					 JAL_PC_4_WB_in      :    in std_logic_vector(instruction_parallelism-1 downto 0);
					 Read_data_WB_in     :    in std_logic_vector(data_parallelism-1 downto 0);
					 sel_WB_in           :    in std_logic_vector(2 downto 0);
					 output_WB_out       :    out std_logic_vector(data_parallelism-1 downto 0)
					 );
end WB_stage;

architecture behavior of WB_stage is

begin

process (sel_WB_in, ALUout_WB_in, immediate_WB_in, JAL_PC_4_WB_in, Read_data_WB_in) 
		begin
		
			case sel_WB_in is
			
			when "011" => output_WB_out <=ALUout_WB_in;
						
			when "010" => output_WB_out <=immediate_WB_in;
			
			when "001" => output_WB_out <=JAL_PC_4_WB_in;
			
			when "000" => output_WB_out <=Read_data_WB_in;
			
			when others => output_WB_out <=(others=>'0');
			
			end case;
		
		end process;
end behavior;

					 