//PC模块完成取指操作

`include "defines.v"

module pc_reg (
    input clk,
    input rst,

    output reg[`InstAddrBus] pc, //指令的地址
    output reg ce //给指令寄存器rom_program模块的使能信号
);
    always@(posedge clk) begin
        if(rst == `RstEnable) begin //异步复位
            pc <= 0;
            ce <= 1;
        end
        else begin //正常情况，简单的累加1
            pc <= pc + 1;
            ce <= 1;
        end
    end
    
endmodule
//注意是时序电路，有clk控制，含D触发器，所以写代码时注意1. posedge clk, 2. <=赋值