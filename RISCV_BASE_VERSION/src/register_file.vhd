library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.risc_package.all;

entity register_file is	
	port(
		clk: in std_logic;
		rst: in std_logic;--reset attivo alto
		
		RegWrite: in std_logic; -- write enable
		read_en: in std_logic; --read enable
		read_register_1: in std_logic_vector(length_in_RF-1 downto 0);
		read_register_2: in std_logic_vector(length_in_RF-1 downto 0);
		write_register: in std_logic_vector(length_in_RF-1 downto 0);
		write_data_in: in std_logic_vector(data_parallelism-1 downto 0);
		read_data_1_out: out std_logic_vector(data_parallelism-1 downto 0);
		read_data_2_out: out std_logic_vector(data_parallelism-1 downto 0)
		
	);
end register_file;

architecture behavioural of register_file is
	type regs is array ( 0 to number_regs-1) of signed(data_parallelism -1 downto 0);
	signal registers: regs;
	signal read_data_1, read_data_2, write_data : std_logic_vector(data_parallelism-1 downto 0);
	
	
	begin
	
	read_proc_1: process(read_register_1, write_register, write_data, registers, read_en, rst, RegWrite)
	begin
		
	if(rst = '1') then
		
		for i in 0 to number_regs-1 loop
						
			read_data_1<=(others=>'0');
						
		end loop;
	else
		
	if (read_en = '1') then
		if((read_register_1 = write_register) and ( RegWrite = '1')) then
						
			
			
			if(read_register_1="00000") then
		
				read_data_1<=(others=>'0');
				
			else
				read_data_1<=write_data;
						
			end if;
			
			
			
			
			
		else
		
		case read_register_1 is
			when "00000" =>
			read_data_1<=(others=>'0'); --because this register is dedicated to a constant equal to zero, so cannot change its value
			when "00001" =>
			read_data_1<=std_logic_vector(registers(1));
			when "00010" =>
			read_data_1<=std_logic_vector(registers(2));
			when "00011" =>
			read_data_1<=std_logic_vector(registers(3));
			when "00100" =>
			read_data_1<=std_logic_vector(registers(4));
			when "00101" =>
			read_data_1<=std_logic_vector(registers(5));
			when "00110" =>
			read_data_1<=std_logic_vector(registers(6));
			when "00111" =>
			read_data_1<=std_logic_vector(registers(7));
			when "01000" =>
			read_data_1<=std_logic_vector(registers(8));
			when "01001" =>
			read_data_1<=std_logic_vector(registers(9));
			when "01010" =>
			read_data_1<=std_logic_vector(registers(10));
			when "01011" =>                            
			read_data_1<=std_logic_vector(registers(11));
			when "01100" =>                            
			read_data_1<=std_logic_vector(registers(12));
			when "01101" =>                            
			read_data_1<=std_logic_vector(registers(13));
			when "01110" =>                            
			read_data_1<=std_logic_vector(registers(14));
			when "01111" =>                            
			read_data_1<=std_logic_vector(registers(15));
			when "10000" =>                            
			read_data_1<=std_logic_vector(registers(16));
			when "10001" =>                            
			read_data_1<=std_logic_vector(registers(17));
			when "10010" =>                            
			read_data_1<=std_logic_vector(registers(18));
			when "10011" =>                            
			read_data_1<=std_logic_vector(registers(19));
			when "10100" =>                            
			read_data_1<=std_logic_vector(registers(20));
			when "10101" =>                            
			read_data_1<=std_logic_vector(registers(21));
			when "10110" =>                            
			read_data_1<=std_logic_vector(registers(22));
			when "10111" =>                            
			read_data_1<=std_logic_vector(registers(23));
			when "11000" =>                            
			read_data_1<=std_logic_vector(registers(24));
			when "11001" =>                            
			read_data_1<=std_logic_vector(registers(25));
			when "11010" =>                            
			read_data_1<=std_logic_vector(registers(26));
			when "11011" =>                            
			read_data_1<=std_logic_vector(registers(27));
			when "11100" =>                            
			read_data_1<=std_logic_vector(registers(28));
			when "11101" =>                            
			read_data_1<=std_logic_vector(registers(29));
			when "11110" =>                            
			read_data_1<=std_logic_vector(registers(30));
			when others =>                            
			read_data_1<=std_logic_vector(registers(31));
		end case;
		end if;
		
		else
		
		    read_data_1<=(others=>'0');
			
		end if;
		end if;
		
	end process read_proc_1;
	
	read_proc_2: process(read_register_2, write_register, write_data, registers, read_en, rst, RegWrite)
	begin
	
	
	if(rst = '1') then
	
	for i in 0 to number_regs-1 loop
					
					read_data_2<=(others=>'0');
					
				end loop;
	else
		
	if (read_en = '1') then
	
		if((read_register_2 = write_register) and ( RegWrite = '1')) then
		
		if(read_register_2="00000") then
		
		read_data_2<=(others=>'0');
		
		else
			read_data_2<=write_data;
						
		end if;
		
			
		else
					
		case read_register_2 is
			when "00000" =>
			read_data_2<=(others=>'0'); --because this register is dedicated to a constant equal to zero, so cannot change its value
			when "00001" =>
			read_data_2<=std_logic_vector(registers(1));
			when "00010" =>
			read_data_2<=std_logic_vector(registers(2));
			when "00011" =>
			read_data_2<=std_logic_vector(registers(3));
			when "00100" =>
			read_data_2<=std_logic_vector(registers(4));
			when "00101" =>
			read_data_2<=std_logic_vector(registers(5));
			when "00110" =>
			read_data_2<=std_logic_vector(registers(6));
			when "00111" =>
			read_data_2<=std_logic_vector(registers(7));
			when "01000" =>
			read_data_2<=std_logic_vector(registers(8));
			when "01001" =>
			read_data_2<=std_logic_vector(registers(9));
			when "01010" =>
			read_data_2<=std_logic_vector(registers(10));
			when "01011" =>                            
			read_data_2<=std_logic_vector(registers(11));
			when "01100" =>                            
			read_data_2<=std_logic_vector(registers(12));
			when "01101" =>                            
			read_data_2<=std_logic_vector(registers(13));
			when "01110" =>                            
			read_data_2<=std_logic_vector(registers(14));
			when "01111" =>                            
			read_data_2<=std_logic_vector(registers(15));
			when "10000" =>                            
			read_data_2<=std_logic_vector(registers(16));
			when "10001" =>                            
			read_data_2<=std_logic_vector(registers(17));
			when "10010" =>                            
			read_data_2<=std_logic_vector(registers(18));
			when "10011" =>                            
			read_data_2<=std_logic_vector(registers(19));
			when "10100" =>                            
			read_data_2<=std_logic_vector(registers(20));
			when "10101" =>                            
			read_data_2<=std_logic_vector(registers(21));
			when "10110" =>                            
			read_data_2<=std_logic_vector(registers(22));
			when "10111" =>                            
			read_data_2<=std_logic_vector(registers(23));
			when "11000" =>                            
			read_data_2<=std_logic_vector(registers(24));
			when "11001" =>                            
			read_data_2<=std_logic_vector(registers(25));
			when "11010" =>                            
			read_data_2<=std_logic_vector(registers(26));
			when "11011" =>                            
			read_data_2<=std_logic_vector(registers(27));
			when "11100" =>                            
			read_data_2<=std_logic_vector(registers(28));
			when "11101" =>                            
			read_data_2<=std_logic_vector(registers(29));
			when "11110" =>                            
			read_data_2<=std_logic_vector(registers(30));
			when others =>                            
			read_data_2<=std_logic_vector(registers(31));
		end case;
		end if;
		
		else
		
		    read_data_2<=(others=>'0');
			
		end if;
		end if;
	end process read_proc_2;
	
	read_data_2_out<=read_data_2;
	read_data_1_out<=read_data_1;
	write_data<=write_data_in;

	write_proc: process(clk, rst)
	begin
	
	if(rst = '1') then
	
	for i in 0 to number_regs-1 loop
	
					registers(i)<=(others=>'0');

					end loop;
	else
		
		if(clk'event and clk = '1') then
		
		      								
				if (RegWrite = '1') then
				
				if (write_register /= "00000") then 
				
					registers(to_integer(unsigned(write_register))) <= signed(write_data);
							
				end if;
				end if;

		end if;
		
	end if;
		
	end process write_proc;
	
end behavioural;
				
				
				
		
		
		
		
	
		