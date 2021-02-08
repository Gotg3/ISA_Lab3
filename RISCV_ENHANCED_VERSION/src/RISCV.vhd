library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.risc_package.all;

entity RISCV is
port(
	--in
	clk					:in std_logic;
	rst                 :in std_logic;
	instruction_ID_in   :in std_logic_vector(instruction_parallelism-1 downto 0); --to ID stage
	Read_data_WB_in     :in std_logic_vector(data_parallelism-1 downto 0); --to WB stage
	--out
	PCWrite_IF_ID_Write :out std_logic;
	PCSrc_MEM_out		:out std_logic; --from MEM stage
	ALUout_EX_out       :out std_logic_vector(data_parallelism-1 downto 0);--from EX stage
	ALU_bypass_EX_out   :out std_logic_vector(data_parallelism-1 downto 0);--from EX stage
	MemRead	            :out std_logic;
	MemWrite            :out std_logic;
	mux_IF_out          :out std_logic_vector(address_parallelism-1 downto 0)
	);
end RISCV;

architecture structural of RISCV is

	component IF_stage
	port(
		clk							: 			                in std_logic;
		rst							: 			                in std_logic;
		PC_src						:			                in std_logic;
		PC_write					:   		                in std_logic;  --enable register
		branch_instruction_address	: 							in std_logic_vector(address_parallelism-1 downto 0); --from branch pred
		out_mux_IF_out				:							out std_logic_vector(address_parallelism-1 downto 0); --to IM
		next_seq_address			:							out std_logic_vector(address_parallelism-1 downto 0); --to WB
		current_address				:    				        out std_logic_vector(address_parallelism-1 downto 0)--to IF/ID pipe reg
	);
	end component;
	
	component ID_stage
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
		PCWrite_IF_ID_Write	: out std_logic;
		WB_ID_out            : out std_logic_vector(WB_length -1 downto 0);
		M_ID_out             : out std_logic_vector(M_length -1 downto 0);
		EX_ID_out            : out std_logic_vector(EX_length -1 downto 0);
		rs1_ID_out           : out std_logic_vector(source_reg - 1 downto 0);
		rs2_ID_out           : out std_logic_vector(source_reg - 1 downto 0);
		or_OUTPUT_ID_out     : out std_logic
	);    
	end component;
	
	component EX_stage
	port(
		--in
		rst						:in std_logic;
		PC_EX_in				 :in std_logic_vector(instruction_parallelism-1 downto 0);
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
		WB_EX_in			    :in std_logic_vector(WB_length-1 downto 0);
		
		--in M
		M_EX_in		         	:in std_logic_vector(M_length-1 downto 0);
		
		--out 
		
		ALUout_EX_out			:out std_logic_vector(data_parallelism-1 downto 0);
		ALU_bypass_EX_out		:out std_logic_vector(data_parallelism-1 downto 0);
		z_EX_out				:out std_logic;
		TAddr_EX_out			:out std_logic_vector(instruction_parallelism-1 downto 0);
		rd_EX_out				:out std_logic_vector(dest_reg-1 downto 0);
		JAL_PC_4_EX_out		    :out std_logic_vector(instruction_parallelism-1 downto 0);
		immediate_EX_out        :out std_logic_vector(data_parallelism-1 downto 0);
		
		--out WB
		WB_EX_out	            :out std_logic_vector(WB_length-1 downto 0);
		
		--out M
		M_EX_out			    :out std_logic_vector(M_length-1 downto 0);
		MemRead_out             :out std_logic;--from EX to ID
		
		--forwarding unit special inputs
		
		rs1_EX_in				:in std_logic_vector(source_reg-1 downto 0);
		rs2_EX_in				:in std_logic_vector(source_reg-1 downto 0);
		RegWrite_MEM_in			:in std_logic;
		RegWrite_WB_in			:in std_logic;
		rd_MEM_in				:in std_logic_vector(dest_reg-1 downto 0);
		rd_WB_in				:in std_logic_vector(dest_reg-1 downto 0)

		
	);
	end component;
	
	component MEM_stage
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
	end component;
	
	component WB_stage
	port(
		ALUout_WB_in        :    in std_logic_vector(instruction_parallelism-1 downto 0);
	    immediate_WB_in     :    in std_logic_vector(instruction_parallelism-1 downto 0);
	    JAL_PC_4_WB_in      :    in std_logic_vector(instruction_parallelism-1 downto 0);
	    Read_data_WB_in     :    in std_logic_vector(data_parallelism-1 downto 0);
	    sel_WB_in           :    in std_logic_vector(2 downto 0);
	    output_WB_out       :    out std_logic_vector(data_parallelism-1 downto 0)
	);
	end component;
	
	component reg_jal_PC_IF_ID
	port(
		clk			: in std_logic;
		rst			: in std_logic;
		IF_ID_write : in std_logic;
		d 			:  in std_logic_vector(instruction_parallelism-1 downto 0);
		q 			:  out std_logic_vector(instruction_parallelism-1 downto 0)
	);
	end component;
	
	component reg
	generic ( n: integer := 32 );
	port(
		clk: in std_logic;
		rst: in std_logic;
		d :  in std_logic_vector(n-1 downto 0);
		q :  out std_logic_vector(n-1 downto 0)
	);
	end component;
	
	component reg_zero
	port(
		clk: in std_logic;
		rst: in std_logic;
		d :  in std_logic;
		N_en:in std_logic;
		q :  out std_logic	
	);
	end component;
	
	component reg_NOP
	generic ( n: integer := 32 );
	port (
    	clk: in std_logic;
		rst: in std_logic;
    	d :  in std_logic_vector(n-1 downto 0);
		N_en: in std_logic;
		q :  out std_logic_vector(n-1 downto 0)
	);
	end component;
	
	
	
	signal JAL_IF_out_s, PC_IF_out_s : std_logic_vector(instruction_parallelism - 1 downto 0); -- IF stage output signals --IF/ID pipeline regs input
	signal JAL_ID_in_s, PC_ID_in_s : std_logic_vector(instruction_parallelism - 1 downto 0); -- ID stage input signals --IF/ID pipeline regs output
	signal IF_ID_Write_ID_out_s, delayed_PC_src_s: std_logic; --output signal from ID stage to IF/ID pipeline regs to hazard detection
	signal ID_EX_MemRead_ID_in_s: std_logic; --from ex stage to ID stage
	signal rd_backward_ID_in_s: std_logic_vector(source_reg - 1 downto 0); --from EX stage to ID stage
	signal JAL_ID_out_s, PC_ID_out_s, PC_EX_in_s, JAL_EX_in_s, TAddr_EX_out_s, JAL_PC_4_EX_out_s, JAL_PC_4_MEM_in_s, TAddr_MEM_in_s, JAL_PC_4_MEM_out_s, TAddr_MEM_out_s, JAL_PC_4_WB_in_s: std_logic_vector(instruction_parallelism - 1 downto 0);
	signal read_data_1_ID_out_s, read_data_2_ID_out_s, immediate_ID_out_s, imm_EX_in_s, immediate_EX_out_s, Read_data1_EX_in_s, Read_data2_EX_in_s, ALUout_EX_out_s, immediate_MEM_in_s, ALUout_MEM_in_s, immediate_MEM_out_s, ALUout_WB_in_s, immediate_WB_in_s: std_logic_vector(data_parallelism-1 downto 0);
	signal to_ALU_control_ID_out_s, to_ALU_ctrl_EX_in_s: std_logic_vector(alu_ctrl - 1 downto 0);
	signal rd_ID_out_s, rd_EX_in_s: std_logic_vector(rd_length - 1 downto 0); 
	signal PCWrite_ID_out_s: std_logic; --from ID stage to PC and to instruction memory
	signal WB_ID_out_s, WB_EX_in_s, WB_EX_out_s, WB_MEM_in_s, WB_MEM_out_s, WB_WB_in_s: std_logic_vector(WB_length -1 downto 0);--from ID stage to ID/EX pipeline registers
	signal M_ID_out_s, M_EX_in_s, M_EX_out_s, M_MEM_in_s: std_logic_vector(M_length -1 downto 0);--from ID stage to ID/EX pipeline registers
	signal EX_ID_out_s, EX_EX_in_s: std_logic_vector(EX_length -1 downto 0);--from ID stage to ID/EX pipeline registers
	signal ALU_backward_MEM_out_s, output_WB_out_s: std_logic_vector(data_parallelism-1 downto 0);--from MEM stage to EX stage
	signal z_EX_out_s, z_MEM_in_s: std_logic;--from EX stage to EX/MEM stage
	signal rs1_ID_out_s, rs2_ID_out_s, rs1_EX_in_s, rs2_EX_in_s: std_logic_vector(source_reg-1 downto 0);
	signal rd_MEM_in_s, rd_WB_in_s, rd_MEM_out_s: std_logic_vector(dest_reg-1 downto 0);
	signal PCsrc_s, or_OUTPUT_ID_out_s: std_logic; --from MEM stage to IF stage
	constant zero_fix_s: std_logic:='0';
	constant one_fix_s: std_logic:='1';
	signal or_IF_ID_Write_s: std_logic; --questo segnale mischia i segnali di IF_ID_Write ed il segnale in uscita dalla or e va ai registri di pipe ID/EX e EX/MEM in modo che quando il PCsrc è alto vengano resettati ma anche quando il reset è attivo vengano resettati.
	signal PCWrite_IF_ID_Write_s: std_logic; --segnale unico di IF_ID_WRITE e PC_WRITE
	begin
	
	or_IF_ID_Write_s<=or_OUTPUT_ID_out_s OR PCWrite_IF_ID_Write_s;
	
	--IF stage
	IF_block: IF_stage port map(
								clk							=>clk,
	                            rst							=>rst,
	                            PC_src						=>PCsrc_s,
	                            PC_write					=>PCWrite_IF_ID_Write_s,
	                            branch_instruction_address	=>TAddr_MEM_out_s,
	                            out_mux_IF_out				=>mux_IF_out,
	                            next_seq_address			=>JAL_IF_out_s,
	                            current_address				=>PC_IF_out_s
								);
	
	--IF/ID pipeline registers
	reg_jal_IF_ID: reg_jal_PC_IF_ID port map (
											clk	=>	clk,	
	                                        rst	=>	rst,	
	                                        IF_ID_write => PCWrite_IF_ID_Write_s,
	                                        d => JAL_IF_out_s,		
	                                        q => JAL_ID_in_s
											);
											
	reg_PC_IF_ID: reg_jal_PC_IF_ID port map (
											clk	=>	clk,	
	                                        rst	=>	rst,	
	                                        IF_ID_write => PCWrite_IF_ID_Write_s,
	                                        d => PC_IF_out_s,		
	                                        q => PC_ID_in_s
											);
	
	reg_delayed_PCsrc: reg_zero port map(
										clk => clk,
	                                    rst => rst,
	                                    d   => PCsrc_s,
										N_en=> zero_fix_s,
	                                    q   => delayed_PC_src_s
										);
	
	
	--ID stage
	ID: ID_stage port map (
						--inputs
	                    clk					 => clk,
	                    rst					 => rst,
	                    RegWrite_ID_in		 => WB_WB_in_s(0),
	                    ID_EX_MemRead_ID_in  => ID_EX_MemRead_ID_in_s,
	                    jal_ID_in			 => JAL_ID_in_s,
	                    pc_ID_in			 => PC_ID_in_s,
	                    write_register_ID_in => rd_WB_in_s,
	                    write_data_ID_in	 => output_WB_out_s,
	                    instruction_ID_in    => instruction_ID_in,
	                    rd_backward_ID_in    => rd_backward_ID_in_s,
							PCsrc_ID_in			 => PCsrc_s,
							delayed_PCsrc_ID_in  => delayed_PC_src_s,
	                    --outputs
	                    jal_ID_out			 => JAL_ID_out_s,
	                    pc_ID_out		     => PC_ID_out_s,
	                    read_data_1_ID_out	 => read_data_1_ID_out_s,
	                    read_data_2_ID_out   => read_data_2_ID_out_s,
	                    immediate_ID_out     => immediate_ID_out_s,
	                    to_ALU_control_ID_out=> to_ALU_control_ID_out_s,
	                    rd_ID_out			 => rd_ID_out_s,
							  PCWrite_IF_ID_Write => PCWrite_IF_ID_Write_s,
	                    --PCWrite_ID_out       => PCWrite_ID_out_s,
	                    --IF_ID_Write_ID_out   => IF_ID_Write_ID_out_s,
	                    WB_ID_out            => WB_ID_out_s,
	                    M_ID_out             => M_ID_out_s,
	                    EX_ID_out  	         => EX_ID_out_s,
						rs1_ID_out			 => rs1_ID_out_s,
						rs2_ID_out			 => rs2_ID_out_s,
						or_OUTPUT_ID_out     => or_OUTPUT_ID_out_s
						);
						
	--ID/EX pipeline registers
	reg_jal_ID_EX: reg_NOP generic map(32) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => JAL_ID_out_s,
												N_en=> or_OUTPUT_ID_out_s,
	                                            q  	=> JAL_EX_in_s
												);
	reg_pc_ID_EX: reg_NOP generic map(32) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => PC_ID_out_s,
												N_en=> or_OUTPUT_ID_out_s,
	                                            q  	=> PC_EX_in_s
												);	
	
	reg_read_data_1_ID_EX: reg_NOP generic map(32) port map (
												clk 		=> clk,
	                                            rst 		=> rst,
	                                            d   		=> read_data_1_ID_out_s,
												N_en 		=> or_IF_ID_Write_s,
	                                            q  			=> Read_data1_EX_in_s
												);
	
	reg_read_data_2_ID_EX: reg_NOP generic map(32) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => read_data_2_ID_out_s,
												N_en=> or_OUTPUT_ID_out_s,
	                                            q  	=> Read_data2_EX_in_s
												);	
	
	reg_immediate_ID_EX: reg_NOP generic map(32) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => immediate_ID_out_s,
												N_en => or_IF_ID_Write_s,
	                                            q  	=> imm_EX_in_s
												);	
	 
	reg_to_ALU_control_ID_EX: reg_NOP generic map(4) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => to_ALU_control_ID_out_s,
												N_en=> or_OUTPUT_ID_out_s,
	                                            q  	=> to_ALU_ctrl_EX_in_s
												);	
	
	reg_rd_ID_EX: reg_NOP generic map(5) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => rd_ID_out_s,
												N_en => or_IF_ID_Write_s,
	                                            q  	=> rd_EX_in_s
												);	
	
	reg_WB_ID_EX: reg_NOP generic map(4) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => WB_ID_out_s,
												N_en=> or_OUTPUT_ID_out_s,
	                                            q  	=> WB_EX_in_s
												);
	
	reg_M_ID_EX: reg_NOP generic map(3) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => M_ID_out_s,
												N_en=> or_OUTPUT_ID_out_s,
	                                            q  	=> M_EX_in_s
												);
	reg_EX_ID_EX: reg_NOP generic map(6) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => EX_ID_out_s,
												N_en=> or_OUTPUT_ID_out_s,
	                                            q  	=> EX_EX_in_s
												);	
	
	reg_rs1_ID_EX: reg_NOP generic map(5) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => rs1_ID_out_s,
												N_en => or_IF_ID_Write_s,
	                                            q  	=> rs1_EX_in_s
												);	
												
	reg_rs2_ID_EX: reg_NOP generic map(5) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => rs2_ID_out_s,
												N_en => or_IF_ID_Write_s,
	                                            q  	=> rs2_EX_in_s
												);
												
												
												
												
	
	--EX stage
	EX: EX_stage port map(
						--in                   
						rst					   => rst,
						PC_EX_in			   => PC_EX_in_s,
						imm_EX_in			   => imm_EX_in_s,
						Read_data1_EX_in	   => Read_data1_EX_in_s,
						Read_data2_EX_in	   => Read_data2_EX_in_s,
						imm30_EX_in			   => to_ALU_ctrl_EX_in_s(3),
						funct3_EX_in		   => to_ALU_ctrl_EX_in_s(2 downto 0),
						rd_EX_in			   => rd_EX_in_s,
						ALU_backward_MEM_out   => ALU_backward_MEM_out_s,
						muxout_backward_WB_out => output_WB_out_s,
						JAL_PC_4_EX_in		   => JAL_EX_in_s,
											  
						-- in EX              
						ALUsrc1_EX_in		   => EX_EX_in_s(1),
						ALUsrc2_EX_in		   => EX_EX_in_s(0),
						ALU_op_EX_in		   => EX_EX_in_s(5 downto 2),
											 										 
						--in WB               
						WB_EX_in		  	   => WB_EX_in_s,
											  
						--in M                 
						M_EX_in		  		   => M_EX_in_s,
											  
						--out                 
											  
						ALUout_EX_out		   => ALUout_EX_out_s,
						ALU_bypass_EX_out	   => ALU_bypass_EX_out,
						z_EX_out			   => z_EX_out_s,
						TAddr_EX_out		   => TAddr_EX_out_s,
						rd_EX_out			   => rd_backward_ID_in_s,
						JAL_PC_4_EX_out	       => JAL_PC_4_EX_out_s,
						immediate_EX_out       => immediate_EX_out_s,
						
						--out WB               
						WB_EX_out	           => WB_EX_out_s,
											  
						--out M                
						M_EX_out	           => M_EX_out_s,
						MemRead_out            =>ID_EX_MemRead_ID_in_s,
						
						--forwarding unit special inputs
						
						rs1_EX_in			   => rs1_EX_in_s,
						rs2_EX_in			   => rs2_EX_in_s,
						RegWrite_MEM_in	       => WB_MEM_in_s(0),
						RegWrite_WB_in		   => WB_WB_in_s(0),
						rd_MEM_in			   => rd_MEM_in_s,
						rd_WB_in			   => rd_WB_in_s
						);
					
	--EX/MEM pipeline registers
	reg_WB_EX_MEM: reg_NOP generic map(4) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => WB_EX_out_s,
												N_en=> or_OUTPUT_ID_out_s,
	                                            q  	=> WB_MEM_in_s
												);
												
	reg_M_EX_MEM:  reg_NOP generic map(3) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => M_EX_out_s,
												N_en=> or_OUTPUT_ID_out_s,
	                                            q  	=> M_MEM_in_s
												);	
    
	reg_JAL_EX_MEM: reg_NOP generic map(32) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => JAL_PC_4_EX_out_s,
												N_en=> or_OUTPUT_ID_out_s,
	                                            q  	=> JAL_PC_4_MEM_in_s
												);
												
	reg_rd_EX_MEM: reg_NOP generic map(5) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => rd_backward_ID_in_s,
												N_en=> or_OUTPUT_ID_out_s,
	                                            q  	=> rd_MEM_in_s
												);	
												
	reg_TAddr_EX_MEM: reg_NOP generic map(32) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => TAddr_EX_out_s,
												N_en=> or_OUTPUT_ID_out_s,
	                                            q  	=> TAddr_MEM_in_s
												);
	
	reg_z_EX_MEM: reg_zero port map (
									clk => clk,
									rst => rst,
									d   => z_EX_out_s,
									N_en=> or_OUTPUT_ID_out_s,
									q  	=> z_MEM_in_s
									);
												
	reg_ALUout_EX_MEM: reg_NOP generic map(32) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => ALUout_EX_out_s,
												N_en=> or_OUTPUT_ID_out_s,
	                                            q  	=> ALUout_MEM_in_s
												);
												
	reg_immediate_EX_MEM: reg_NOP generic map(32) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => immediate_EX_out_s,
												N_en=> or_OUTPUT_ID_out_s,
	                                            q  	=> immediate_MEM_in_s
												);
	

	--MEM stage
	MEM: MEM_stage port map(
	                        --inputs
							WB_MEM_in         => WB_MEM_in_s,
							BranchCtrl		  => M_MEM_in_s(0),
							JAL_PC_4_MEM_in	  => JAL_PC_4_MEM_in_s,
							rd_MEM_in         => rd_MEM_in_s,
							TAddr_MEM_in      => TAddr_MEM_in_s,
							z_MEM_in          => z_MEM_in_s,
							immediate_MEM_in  => immediate_MEM_in_s,
							ALUout_MEM_in     => ALUout_MEM_in_s,
											 
							--outputs        
							WB_MEM_out        => WB_MEM_out_s,
							JAL_PC_4_MEM_out  => JAL_PC_4_MEM_out_s,
							ALUout_MEM_out    => ALU_backward_MEM_out_s,
							immediate_MEM_out => immediate_MEM_out_s,
							rd_MEM_out        => rd_MEM_out_s,
							PCsrc             => PCsrc_s,
							TAddr_MEM_out	  => TAddr_MEM_out_s
							);
							
	--MEM/WB pipeline registers
	reg_WB_MEM_WB: reg generic map(4) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => WB_MEM_out_s,
	                                            q  	=> WB_WB_in_s
												);
	
	reg_JAL_MEM_WB: reg generic map(32) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => JAL_PC_4_MEM_out_s,
	                                            q  	=> JAL_PC_4_WB_in_s
												);
												
	reg_ALUout_MEM_WB: reg generic map(32) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => ALU_backward_MEM_out_s,
	                                            q  	=> ALUout_WB_in_s
												);
												
	reg_immediate_MEM_WB: reg generic map(32) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => immediate_MEM_out_s,
	                                            q  	=> immediate_WB_in_s
												);	

	reg_rd_MEM_WB: reg_NOP generic map(5) port map (
												clk => clk,
	                                            rst => rst,
	                                            d   => rd_MEM_out_s,
						    N_en=> PCsrc_s,
	                                            q  	=> rd_WB_in_s
												);												
	
	--WB stage
    WB: WB_stage port map(
						ALUout_WB_in    => ALUout_WB_in_s,
	                    immediate_WB_in => immediate_WB_in_s,
	                    JAL_PC_4_WB_in  => JAL_PC_4_WB_in_s,
	                    Read_data_WB_in => Read_data_WB_in,
	                    sel_WB_in       => WB_WB_in_s(3 downto 1),
	                    output_WB_out   => output_WB_out_s	
						);	
	
    PCWrite_IF_ID_Write<=PCWrite_IF_ID_Write_s;	
	ALUout_EX_out <= ALUout_EX_out_s;
    MemWrite <= M_MEM_in_s(2);
	MemRead <= M_MEM_in_s(1);
	PCSrc_MEM_out<=PCsrc_s;
	
end structural;
