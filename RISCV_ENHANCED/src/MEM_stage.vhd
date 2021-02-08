library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.risc_package.all;

entity MEM_stage is

    port(
		--inputs
		WB_MEM_in         :  in std_logic_vector(WB_length -1 downto 0);
		BranchCtrl		  :  in std_logic;
		JAL_PC_4_MEM_in	  :  in std_logic_vector(instruction_parallelism - 1 downto 0);
		rd_MEM_in         :  in std_logic_vector(dest_reg-1 downto 0);
		TAddr_MEM_in      :	 in std_logic_vector(instruction_parallelism-1 downto 0);
		z_MEM_in          :	 in std_logic;
		immediate_MEM_in  :  in std_logic_vector(data_parallelism - 1 downto 0);
		ALUout_MEM_in     :  in std_logic_vector(data_parallelism-1 downto 0);
		
		--outputs
		WB_MEM_out        :	 out std_logic_vector(WB_length -1 downto 0);
		JAL_PC_4_MEM_out  :  out std_logic_vector(instruction_parallelism - 1 downto 0);
		ALUout_MEM_out    :  out std_logic_vector(data_parallelism-1 downto 0);
		immediate_MEM_out :  out std_logic_vector(data_parallelism - 1 downto 0);
		rd_MEM_out        :  out std_logic_vector(dest_reg-1 downto 0);
		PCsrc             :  out std_logic;
		TAddr_MEM_out     :	 out std_logic_vector(instruction_parallelism-1 downto 0)	
		 );   

end MEM_stage;

architecture behavioural of MEM_stage is 

component AND_Gate is 
port(
	 z_MEM_in  : in std_logic;     
	 BranchCTRL: in std_logic;      
     PCsrc     : out std_logic
	);
end component;

signal z_MEM_in_s, BranchCtrl_s, PCsrc_s: std_logic; 

begin

BranchCtrl_s<=BranchCtrl;
z_MEM_in_s<=z_MEM_in;
PCsrc<=PCsrc_s;

WB_MEM_out<=WB_MEM_in;
JAL_PC_4_MEM_out<=JAL_PC_4_MEM_in;
rd_MEM_out<=rd_MEM_in;
TAddr_MEM_out<=TAddr_MEM_in;
ALUout_MEM_out<=ALUout_MEM_in;
immediate_MEM_out<=immediate_MEM_in;


and_port: AND_Gate port map(
							z_MEM_in  => z_MEM_in_s,
							BranchCTRL=> BranchCtrl_s,
                            PCsrc     => PCsrc_s
							);

end behavioural;
	
