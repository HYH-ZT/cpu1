`include "defines.v"

module ex_mem(
    input clk,
    input rst,

    //È¡Ö´ÐÐ½×¶Î½á¹û
    input wire[`RegAddrBus] ex_waddr_reg_i,
    input wire ex_we_reg_i,
    input wire[`RegBus] ex_wdata_i,
    input wire[`StallBus] stall,

    //¸ø·Ã´æ½×¶Î
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
    else if(stall[3] == `Stop) begin        //·Ã´æ½×¶ÎÔÝÍ£
        if(stall[4] == `NoStop)begin        //ÈôÖ´ÐÐ½×¶Î²»ÔÝÍ£
            mem_waddr_reg_o <= `NOPRegAddr;
            mem_we_reg_o <= `WriteDisable;
            mem_wdata_o <= `ZeroWord;
        end
        else begin                          //ÈôÖ´ÐÐ½×¶ÎÔÝÍ£
            mem_waddr_reg_o <= mem_waddr_reg_o;
            mem_we_reg_o <= mem_we_reg_o;
            mem_wdata_o <= mem_wdata_o;
        end
    end
    else begin
        mem_waddr_reg_o <= ex_waddr_reg_i;
        mem_we_reg_o <= ex_we_reg_i;
        mem_wdata_o <= ex_wdata_i;
    end
end

endmodule