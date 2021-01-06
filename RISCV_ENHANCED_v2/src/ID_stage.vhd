library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.risc_package.all;

entity ID_stage is 
	port(
	    --inputs
	    clk					 : in  std_logic;
		rst					 : in  std_logic;--reset attivo alto
		RegWrite_ID_in		 : in  std_logic;
		ID_EX_MemRead_ID_in  : in std_logic;-- attivo alto
		jal_ID_in			 : in  std_logic_vector(instruction_parallelism - 1 downto 0);
		pc_ID_in			 : in  std_logic_vector(instruction_parallelism - 1 downto 0);
		write_register_ID_in : in  std_logic_vector(length_in_RF-1 downto 0);
		write_data_ID_in	 : in  std_logic_vector(data_parallelism - 1 downto 0);
		instruction_ID_in    : in  std_logic_vector(instruction_parallelism - 1 downto 0);
     	rd_backward_ID_in    : in std_logic_vector(source_reg - 1 downto 0);
		PCsrc_ID_in          : in std_logic;
		delayed_PCsrc_ID_in  : in std_logic;
		--outputs
		jal_ID_out			 : out std_logic_vector(instruction_parallelism - 1 downto 0);
		pc_ID_out		     : out std_logic_vector(instruction_parallelism - 1 downto 0);
		read_data_1_ID_out	 : out std_logic_vector(data_parallelism-1 downto 0);
		read_data_2_ID_out   : out std_logic_vector(data_parallelism-1 downto 0);
		immediate_ID_out     : out std_logic_vector(data_parallelism - 1 downto 0);
		to_ALU_control_ID_out: out std_logic_vector(alu_ctrl - 1 downto 0);
		rd_ID_out			 : out std_logic_vector(rd_length - 1 downto 0);
		PCWrite_ID_out       : out std_logic;
		IF_ID_Write_ID_out   : out std_logic;
		WB_ID_out            : out std_logic_vector(WB_length -1 downto 0);
		M_ID_out             : out std_logic_vector(M_length -1 downto 0);
		EX_ID_out            : out std_logic_vector(EX_length -1 downto 0);
		rs1_ID_out           : out std_logic_vector(source_reg - 1 downto 0);
		rs2_ID_out           : out std_logic_vector(source_reg - 1 downto 0);
		or_OUTPUT_ID_out     : out std_logic
	);    
end ID_stage; 

architecture behavioural of ID_stage is

component imm_gen is
port(
		rst: in std_logic;--reset attivo alto                                   --v
		sel: in std_logic_vector(sel_imm-1 downto 0);                           --v
		instruction: in std_logic_vector(instruction_parallelism - 1 downto 0); --v
		immediate: out std_logic_vector(data_parallelism - 1 downto 0)          --v
		
	); 
end component;

component register_file is
port(
		clk: in std_logic;                                                       --v
		rst: in std_logic;--reset attivo alto		                             --v
		RegWrite: in std_logic; -- write enable                                  --v
		read_en: in std_logic; --read enable                                     --v
		read_register_1: in std_logic_vector(length_in_RF-1 downto 0);           --v
		read_register_2: in std_logic_vector(length_in_RF-1 downto 0);           --v
		write_register: in std_logic_vector(length_in_RF-1 downto 0);            --v
		write_data_in: in std_logic_vector(data_parallelism-1 downto 0);         --v
		read_data_1_out: out std_logic_vector(data_parallelism-1 downto 0);      --v
		read_data_2_out: out std_logic_vector(data_parallelism-1 downto 0)       --v
		
	); 
end component;

component HDU is
port(
		ID_EX_MemRead: in std_logic;-- attivo alto                                             --v
		rs1: in std_logic_vector(length_in_RF - 1 downto 0);-- instruction bits from 19 to 15  --v
		rs2: in std_logic_vector(length_in_RF - 1 downto 0);-- instruction bits from 24 to 20  --v
		rd : in std_logic_vector(length_in_RF - 1 downto 0);-- instruction bits from 11 to 7   --v
		PCWrite: out std_logic;                                                                --v
		IF_ID_Write: out std_logic;                                                            --v
		sel_mux: out std_logic                                                                 --v
		
	); 
end component;

component mux_ID is
port(
        in_ctrl: in std_logic_vector(out_ctrl -1 downto 0);              --v
		zeros: in std_logic_vector(out_ctrl -1 downto 0):=(others=>'0'); --v
		q: out std_logic_vector(out_ctrl -1 downto 0);                   --v
		sel: in std_logic
    );
end component;

component CU is
port(
		rst: in std_logic; --attivo alto                                          --v
	    opcode: in std_logic_vector(opcode_size -1 downto 0);                     --v
		funct3: in std_logic_vector(funct -1 downto 0);                           --v
		ctrl: out std_logic_vector(out_ctrl -1 downto 0)                          --v
    );
end component;

component OR_Gate is
port(
		PCsrc : in std_logic;     
		delayed_PCsrc: in std_logic;      
		output : out std_logic


	);
end component;

signal clk_s, rst_s, RegWrite_s, ID_EX_MemRead_s, PCWrite_s, IF_ID_Write_s, sel_s  : std_logic;
signal read_register_1_s, read_register_2_s, write_register_s, rd_backward_s                  : std_logic_vector(length_in_RF -1 downto 0);
signal write_data_in_s, read_data_1_out_s, read_data_2_out_s   : std_logic_vector(data_parallelism -1 downto 0);
signal q_s, ctrl_s                                             : std_logic_vector(out_ctrl -1 downto 0); --signal for the mux_ID output
signal instruction_s                                           : std_logic_vector(instruction_parallelism -1 downto 0);
signal immediate_s                                             : std_logic_vector(data_parallelism -1 downto 0);
--signal zeros_s                                                 : std_logic_vector(out_ctrl -1 downto 0);
signal opcode_s                                                : std_logic_vector(opcode_size -1 downto 0);
signal funct3_s                                                : std_logic_vector(funct -1 downto 0);
constant read_en_s                                             : std_logic:='1';
constant zeros_s                                               : std_logic_vector(out_ctrl -1 downto 0):=(others=>'0');

begin

clk_s <= clk;
rst_s <= rst;

--register file signals
RegWrite_s <= RegWrite_ID_in;
--read_en_s  <= read_en_ID_in;
read_register_1_s <=instruction_ID_in(19 downto 15);
read_register_2_s <=instruction_ID_in(24 downto 20);
write_register_s  <= write_register_ID_in;
write_data_in_s <= write_data_ID_in;
read_data_1_ID_out <= read_data_1_out_s;
read_data_2_ID_out <= read_data_2_out_s;

--immediate generator signals
instruction_s <= instruction_ID_in;
immediate_ID_out <= immediate_s;

--HDU
ID_EX_MemRead_s<=ID_EX_MemRead_ID_in;
rd_backward_s<=rd_backward_ID_in;
PCWrite_ID_out<=PCWrite_s;
IF_ID_Write_ID_out<=IF_ID_Write_s;

--CU
opcode_s<=instruction_ID_in(6 downto 0);
funct3_s<=instruction_ID_in(14 downto 12);



immediate_generator: imm_gen port map(
									rst_s,
									q_s(15 downto 13),
									instruction_s,
									immediate_s
									);
									
RF: register_file port map(
						clk_s,
						rst_s,
						RegWrite_s,
						read_en_s,
						read_register_1_s,
						read_register_2_s,
						write_register_s,
						write_data_in_s,
						read_data_1_out_s,
						read_data_2_out_s
						);

Hazard: HDU port map(
					ID_EX_MemRead_s,
                    read_register_1_s,
					read_register_2_s,
					rd_backward_s,
					PCWrite_s,
					IF_ID_Write_s,
					sel_s
					);

mux: mux_ID port map(
					ctrl_s,
				    zeros_s,
					q_s,
					sel_s
					);

control_unit: CU port map(
						rst_s,
						opcode_s,
						funct3_s,
						ctrl_s
						);
						
OR_port: OR_Gate port map(
						PCsrc_ID_in,
						delayed_PCsrc_ID_in,
						or_OUTPUT_ID_out
						);
						 

jal_ID_out <= jal_ID_in;
pc_ID_out  <= pc_ID_in;
to_ALU_control_ID_out <= (instruction_ID_in(30) & instruction_ID_in(14 downto 12));
rd_ID_out <= instruction_ID_in(11 downto 7);
WB_ID_out<=q_s(12 downto 9);
M_ID_out<=q_s(8 downto 6);
EX_ID_out<=q_s(5 downto 0);
rs1_ID_out<=read_register_1_s;
rs2_ID_out<=read_register_2_s ;

end behavioural;
