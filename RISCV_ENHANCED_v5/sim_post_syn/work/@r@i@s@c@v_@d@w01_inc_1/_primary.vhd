library verilog;
use verilog.vl_types.all;
entity RISCV_DW01_inc_1 is
    port(
        A               : in     vl_logic_vector(31 downto 0);
        SUM             : out    vl_logic_vector(31 downto 0)
    );
end RISCV_DW01_inc_1;
