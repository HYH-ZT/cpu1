
`include "defines.v"

module if_id(   //取指令阶段 instruction fetch to instruction decode
    input clk,
    input rst,
    input wire[`InstAddrBus] if_pc, //指令地址
    input wire[`InstBus] if_inst,   //指令，从指令存储器来，这里还没有指令存储器的模块？

    output reg[`InstAddrBus] id_pc, 
    output reg[`InstBus] id_inst
);
    always@(posedge clk) begin 
        if(rst == `RstEnable) begin
            id_pc <= 0;
            id_inst <= 0;
        end
        else begin
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
    end

endmodule