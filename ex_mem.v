`include "defines.v"

module ex_mem(
    input clk,
    input rst,

    //取执行阶段结果
    input wire[`RegAddrBus] ex_waddr_reg_i,
    input wire ex_we_reg_i,
    input wire[`RegBus] ex_wdata_i,

    //给访存阶段
    output reg[`RegAddrBus] mem_waddr_reg_o,
    output reg mem_we_reg_o,
    output reg[`RegBus] mem_wdata_o

);

always@(posedge clk) begin
    if(rst == `RstEnable) begin
        mem_waddr_reg_o <= `NOPRegAddr;
        mem_we_reg_o <= `WriteDisable;
        mem_wdata_o <= `ZeroWord;
    end
    else begin
        mem_waddr_reg_o <= ex_waddr_reg_i;
        mem_we_reg_o <= ex_we_reg_i;
        mem_wdata_o <= ex_wdata_i;
    end
end


endmodule