`include "defines.v"

module sopc(
    input clk,
    input rst
);

wire[`InstAddrBus] inst_addr;
(*keep = "true"*) wire[`InstBus] inst;
wire rom_ce;

//实例化my_mips_cpu
my_mips_cpu my_mips_cpu_inst0(
    .clk(clk),
    .rst(rst),
    .rom_data_i(inst),
    .rom_addr_o(inst_addr),
    .rom_ce_o(rom_ce)
);


//实例化ROM
rom_program rom_program_inst0(
    .clk(clk),
    .rom_addr_i(inst_addr),
    .rom_ce_i(rom_ce),
    .rom_data_o(inst)
);


endmodule