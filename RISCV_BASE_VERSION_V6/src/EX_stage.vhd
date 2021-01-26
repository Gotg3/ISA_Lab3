library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.risc_package.all;

entity EX_stage is
port(

--in
rst						:in std_logic;
PC_EX_in				   :in std_logic_vector(instruction_parallelism-1 downto 0);
imm_EX_in				:in std_logic_vector(data_parallelism-1 downto 0);
Read_data1_EX_in		:in std_logic_vector(data_parallelism-1 downto 0);
Read_data2_EX_in		:in std_logic_vector(data_parallelism-1 downto 0);
imm30_EX_in				:in std_logic;
funct3_EX_in			:in std_logic_vector(funct-1 downto 0);
rd_EX_in					:in std_logic_vector(dest_reg-1 downto 0);
ALU_backward_MEM_out	:in std_logic_vector(data_parallelism-1 downto 0);
muxout_backward_WB_out	:in std_logic_vector(data_parallelism-1 downto 0);
JAL_PC_4_EX_in			:in std_logic_vector(instruction_parallelism-1 downto 0);

-- in EX
ALUsrc1_EX_in			:in std_logic;
ALUsrc2_EX_in			:in std_logic;
ALU_op_EX_in			:in std_logic_vector(aluOP-1 downto 0);


--in WB
WB_EX_in			:in std_logic_vector(WB_length-1 downto 0);

--in M
M_EX_in			    :in std_logic_vector(M_length-1 downto 0);

--out 

ALUout_EX_out		:out std_logic_vector(data_parallelism-1 downto 0);
ALU_bypass_EX_out	:out std_logic_vector(data_parallelism-1 downto 0);
z_EX_out			:out std_logic;
TAddr_EX_out		:out std_logic_vector(instruction_parallelism-1 downto 0);
rd_EX_out			:out std_logic_vector(dest_reg-1 downto 0);
JAL_PC_4_EX_out	    :out std_logic_vector(instruction_parallelism-1 downto 0);
immediate_EX_out    :out std_logic_vector(data_parallelism-1 downto 0);

--out WB
WB_EX_out	:out std_logic_vector(WB_length-1 downto 0);

--out M
M_EX_out			    :out std_logic_vector(M_length-1 downto 0);
MemRead_out             :out std_logic;--from EX to ID

--forwarding unit special inputs

rs1_EX_in			:in std_logic_vector(source_reg-1 downto 0);
rs2_EX_in			:in std_logic_vector(source_reg-1 downto 0);
RegWrite_MEM_in	:in std_logic;
RegWrite_WB_in		:in std_logic;
rd_MEM_in			:in std_logic_vector(dest_reg-1 downto 0);
rd_WB_in				:in std_logic_vector(dest_reg-1 downto 0)

);
end entity;

architecture structural of EX_stage is 

	
	signal ALU_ctr  				:std_logic_vector(alu_ctrl-1 downto 0);
	signal forward1_s   			:std_logic_vector(mux_ctrl-1 downto 0);
	signal forward2_s   			:std_logic_vector(mux_ctrl-1 downto 0);
	signal ALU_in1_s				:std_logic_vector(data_parallelism-1 downto 0);
	signal ALU_in2_s				:std_logic_vector(data_parallelism-1 downto 0);
	signal M2_out_s					:std_logic_vector(data_parallelism-1 downto 0);
	signal M1_out_s					:std_logic_vector(data_parallelism-1 downto 0);
	signal ALUsrc1					:std_logic;
	signal ALUsrc2					:std_logic;
	signal rd_s						:std_logic_vector(dest_reg-1 downto 0);	
	signal JAL_PC_4_s				:std_logic_vector(instruction_parallelism-1 downto 0);
	signal WB_EX_s					:std_logic_vector(WB_length-1 downto 0);
	signal M_EX_s                   :std_logic_vector(M_length-1 downto 0);
	signal immediate_s              :std_logic_vector(data_parallelism-1 downto 0);
	
	component ALU
	port(
	in1    :in std_logic_vector(data_parallelism-1 downto 0); --rs1,PC
	in2    :in std_logic_vector(data_parallelism-1 downto 0); --rs2,IMM
	output :out std_logic_vector(data_parallelism-1 downto 0);
	z      :out std_logic;
	ctrl   :in std_logic_vector(alu_ctrl-1 downto 0);
	rst    :in std_logic
	);
	end component;
	
	component ALU_control
	port
	(
	ALUop		:in std_logic_vector(aluOP-1 downto 0);
	imm30		:in std_logic;
	funct3	:in std_logic_vector(funct-1 downto 0);
	rst		:in std_logic;
	ctrlALU 	:out std_logic_vector(alu_ctrl-1 downto 0)
	);
	end component;
	
	component AddSum
	port(
	BA  		:in std_logic_vector(instruction_parallelism-1 downto 0);
	Offset	:in std_logic_vector(instruction_parallelism-1 downto 0);
	TA			:out std_logic_vector(instruction_parallelism-1 downto 0)
	);
	end component;
	
	component forwarding_unit
	port(
	rwrite_ex_mem	:in std_logic;
	rwrite_mem_wb	:in std_logic;
	rd_in_ex_mem	:in std_logic_vector(source_reg-1 downto 0);
	rd_in_mem_wb	:in std_logic_vector(source_reg-1 downto 0);
	rs1_in_id_ex	:in std_logic_vector(source_reg-1 downto 0);
	rs2_in_id_ex	:in std_logic_vector(source_reg-1 downto 0);
	forward1 		:out std_logic_vector(mux_ctrl-1 downto 0);
	forward2   		:out std_logic_vector(mux_ctrl-1 downto 0)
	);
	end component;
	
	component mux31
	port(
		in1		:in std_logic_vector(data_parallelism-1 downto 0);
		in2		:in std_logic_vector(data_parallelism-1 downto 0);
		in3		:in std_logic_vector(data_parallelism-1 downto 0);
		sel		:in std_logic_vector(mux_ctrl-1 downto 0); --2 bit selection
		output	:out std_logic_vector(data_parallelism-1 downto 0)
	);
	end component;
	
	component mux21
	generic(n: integer);
	port(
		in1		:in std_logic_vector(n-1 downto 0);
		in2		:in std_logic_vector(n-1 downto 0);
		sel		:in std_logic;
		output	:out std_logic_vector(n-1 downto 0)
	);
	end component;
	
	begin
	
	mux1_ex : mux31 
	port map(
	in1		=>Read_data1_EX_in,
	in2		=>ALU_backward_MEM_out,
	in3		=>muxout_backward_WB_out,
    sel		=>forward1_s,    				
    output	=>M1_out_s              
	);     
	
	mux2_ex : mux31  
	port map(
	in1		=>Read_data2_EX_in,
	in2		=>ALU_backward_MEM_out,
	in3		=>muxout_backward_WB_out,
    sel		=>forward2_s,
    output	=>M2_out_s
	);
	
	mux3_ex : mux21
	generic map ( n=> data_parallelism)
	port map(
	in1			=> M2_out_s,  --1
	in2			=> imm_EX_in, --0
	sel			=> ALUsrc2,
    output		=> ALU_in2_s
	);
	
	mux4_Ex : mux21
	generic map ( n=> data_parallelism)
	port map(
	in1			=> M1_out_s, --0
	in2			=> PC_EX_in, --1
	sel			=> ALUsrc1,
    output		=> ALU_in1_s 
	);
	
	
	ALUcomp : ALU
	port map(
	in1    => ALU_in1_s,
	in2    => ALU_in2_s,
	output => ALUout_EX_out,
	z      => z_EX_out, 
	ctrl   => ALU_ctr,
	rst    => rst
	);

	ALUcontrolcomp : ALU_control
	port map(
	ALUop	=>ALU_op_EX_in,
	imm30	=>imm30_EX_in,
	funct3	=>funct3_EX_in,
	rst		=>rst,
    ctrlALU =>ALU_ctr
	);
	
	AddSumcomp : AddSum
	port map(
	BA		=>  PC_EX_in,	
	Offset	=>	immediate_s,
	TA		=>	TAddr_EX_out
	);
	
	forwarding_unitcomp : forwarding_unit
	port map(
	rwrite_ex_mem	=>  RegWrite_MEM_in,	
	rwrite_mem_wb	=>  RegWrite_WB_in,
    rd_in_ex_mem	=>  rd_MEM_in,	
    rd_in_mem_wb	=>  rd_WB_in,	
    rs1_in_id_ex	=>  rs1_EX_in,
    rs2_in_id_ex	=>  rs2_EX_in,
    forward1 		=>  forward1_s,
    forward2        =>  forward2_s
	);
	--rd connection
	rd_s<=rd_EX_in;
	rd_EX_out<=rd_s;
	-----
	--JAL connection
	JAL_PC_4_s<=JAL_PC_4_EX_in;
	JAL_PC_4_EX_out<=JAL_PC_4_s;
	---
	--ALUsrc connection	
	ALUsrc1<=ALUsrc1_EX_in;
	ALUsrc2<=ALUsrc2_EX_in;
	--
	--ALU_bypass connection
	ALU_bypass_EX_out<=M2_out_s; -- connect to the selection of 2n mux
	--
	--immediate connection
	immediate_s<=imm_EX_in;
	immediate_EX_out<=immediate_s;
	--
	--WB connection
	WB_EX_s<=WB_EX_in;
	WB_EX_out<=WB_EX_s;
	--
	--M connection
	M_EX_s<=M_EX_in;
	M_EX_out<=M_EX_s;
	
	MemRead_out<=M_EX_s(1);
	
	
	
	end structural;


	