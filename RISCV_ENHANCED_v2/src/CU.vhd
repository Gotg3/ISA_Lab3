library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.risc_package.all;

entity CU is 
	port(
		rst: in std_logic; --attivo alto
	   	opcode: in std_logic_vector(opcode_size -1 downto 0);
		funct3: in std_logic_vector(funct -1 downto 0);
		ctrl: out std_logic_vector(out_ctrl -1 downto 0) -- 3 bits immediate; 4 bits ((3 bits)MemtoReg, (1 bit) RegWrite) wb; 3 bits (MemWrite, MemRead, BranchCtrl) mem; 6 bits (ALU_op (4 bits), ALU_src1(1 bit), ALU_src2(1 bit))ex
	);
end CU;

architecture arch of CU is 

begin

process(rst, funct3, opcode)
begin
	if(rst='1') then
       ctrl<=(others=>'0');
	  
	else
	
	case opcode is
	
	when "0110011" =>   --ADD, XOR, SLT 
	
		if (funct3="000") then --ADD
		
			ctrl<="1110111000010000";
		
		elsif(funct3="100") then --XOR
		
			ctrl<="1110111000010000";
		
		elsif (funct3="010") then --SLT
		
			ctrl<="1110111000010000";
			
		elsif (funct3="001") then --ABS
		
			ctrl<="1110111000010000";
		
		else
		
			ctrl<=(others=>'0');
		
		end if;
	
	when "0010011" =>--ADDI, SRAI, ANDI
	
		if (funct3="000") then --ADDI
		
			ctrl<="0000111000000101";
		
		elsif(funct3="101") then --SRAI
		
			ctrl<="1010111000000101";
		
		elsif (funct3="111") then --ANDI
		
			ctrl<="0000111000000101";
		
		else
		
			ctrl<=(others=>'0');
		
		end if; 
		
	when "0010111" => --AUIPC
	
		ctrl<="0010111000001011";
		
	when "0110111" =>--LUI
	
		ctrl<="0010101000100001"; -- forward imm to out alu
		
	when "1100011" => --BEQ
	
		ctrl<="1001000001010100";
	
	when "0000011" => --LW
	
		ctrl<="0000001010000001";
		
	when "1101111" => --JAL
	
		ctrl<="0100011001011100";			

	when "0100011" => --SW
	
		ctrl<="0111000100001101";
		
	when others=>
	
		ctrl<=(others=>'0');
		
	end case;
end if;
end process;
end arch;