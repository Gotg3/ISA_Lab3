library verilog;
use verilog.vl_types.all;
entity RISCV is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        instruction_ID_in: in     vl_logic_vector(31 downto 0);
        Read_data_WB_in : in     vl_logic_vector(31 downto 0);
        PCWrite_IF_ID_Write: out    vl_logic;
        PCSrc_MEM_out   : out    vl_logic;
        ALUout_EX_out   : out    vl_logic_vector(31 downto 0);
        ALU_bypass_EX_out: out    vl_logic_vector(31 downto 0);
        MemRead         : out    vl_logic;
        MemWrite        : out    vl_logic;
        mux_IF_out      : out    vl_logic_vector(31 downto 0)
    );
end RISCV;
