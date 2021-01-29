library verilog;
use verilog.vl_types.all;
entity RISCV_DW01_add_4 is
    port(
        A               : in     vl_logic_vector(31 downto 0);
        B               : in     vl_logic_vector(31 downto 0);
        CI              : in     vl_logic;
        SUM             : out    vl_logic_vector(31 downto 0);
        CO              : out    vl_logic
    );
end RISCV_DW01_add_4;
