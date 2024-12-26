
`include "defines.v"

module mem_wb(
    input clk,
    input rst,

    //È¡·Ã´æ½á¹û
    input wire[`RegAddrBus] mem_waddr_reg_i,
    input wire mem_we_reg_i,
    input wire[`RegBus] mem_wdata_i,
    input wire[`StallBus] stall,
    input wire[`RegBus] mem_hi_i,
    input wire[`RegBus] mem_lo_i,
    input wire mem_whilo_i,

    //¸ø»ØÐ´½×¶Î
    output reg[`RegAddrBus] wb_waddr_reg_o,
    output reg wb_we_reg_o,
    output reg[`RegBus] wb_wdata_o,
    output reg[`RegBus] wb_hi_o,
    output reg[`RegBus] wb_lo_o,
    output reg wb_whilo_o

);

always@(posedge clk) begin
    if(rst == `RstEnable) begin
        wb_waddr_reg_o <= `NOPRegAddr;
        wb_we_reg_o <= `WriteDisable;
        wb_wdata_o <= `ZeroWord;
        wb_hi_o <= `ZeroWord;
        wb_lo_o <= `ZeroWord;
        wb_whilo_o <= `WriteDisable;
    end
    else if(stall[4] == `Stop) begin        //»ØÐ´½×¶ÎÔÝÍ£
        if(stall[5] == `NoStop)begin        //Èô·Ã´æ½×¶Î²»ÔÝÍ£
            wb_waddr_reg_o <= `NOPRegAddr;
            wb_we_reg_o <= `WriteDisable;
            wb_wdata_o <= `ZeroWord;
            wb_hi_o <= `ZeroWord;
            wb_lo_o <= `ZeroWord;
            wb_whilo_o <= `WriteDisable;
        end
        else begin                          //Èô·Ã´æ½×¶ÎÔÝÍ£
            wb_waddr_reg_o <= wb_waddr_reg_o;
            wb_we_reg_o <= wb_we_reg_o;
            wb_wdata_o <= wb_wdata_o;
            wb_hi_o <= wb_hi_o;
            wb_lo_o <= wb_lo_o;
            wb_whilo_o <= wb_whilo_o;
        end
    end
    else begin
        wb_waddr_reg_o <= mem_waddr_reg_i;
        wb_we_reg_o <= mem_we_reg_i;
        wb_wdata_o <= mem_wdata_i;
        wb_hi_o <= mem_hi_i;
        wb_lo_o <= mem_lo_i;
        wb_whilo_o <= mem_whilo_i;
    end
end

endmodule