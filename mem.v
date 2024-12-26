
`include "defines.v"

module mem(
    input rst,
    
    //执行阶段信息
    input wire[`RegAddrBus] waddr_reg_i,
    input wire we_reg_i,
    input wire[`RegBus] wdata_i,
    input wire[`RegBus] hi_i,
    input wire[`RegBus] lo_i,
    input wire whilo_i,

    //访存后结果
    output reg[`RegAddrBus] waddr_reg_o,
    output reg we_reg_o,
    output reg[`RegBus] wdata_o,
    output reg[`RegBus] hi_o,
    output reg[`RegBus] lo_o,
    output reg whilo_o

);

always@(*) begin
    if(rst == `RstEnable) begin
        waddr_reg_o = `NOPRegAddr;
        we_reg_o = `WriteDisable;
        wdata_o = `ZeroWord;
        hi_o = `ZeroWord;
        lo_o = `ZeroWord;
        whilo_o = `WriteDisable;
    end
    else begin
        waddr_reg_o = waddr_reg_i;
        we_reg_o = we_reg_i;
        wdata_o = wdata_i;
        hi_o = hi_i;
        lo_o = lo_i;
        whilo_o = whilo_i;
    end
end


endmodule

