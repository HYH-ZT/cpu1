//PC模块完成取指操作

`include "defines.v"

module pc_reg (
    input wire clk,
    input wire rst,
    input wire [`RegBus]branch_target_addr_i, //跳转的目标地址
    input wire branch_flag_i,       //跳转使能
    input wire [`StallBus] stall,         //暂停信号

    output reg[`InstAddrBus] pc,    //指令的地址
    output reg ce                   //给指令寄存器rom_program模块的使能信号
);
//指令存储器ce
always @(posedge clk) begin
    if(rst == `RstEnable) begin
        ce <= `ChipDisable;                     //复位的时候指令存储器禁用
    end
    else begin
        ce <= `ChipEnable;                      //复位结束使能
    end
end

//pc程序计数器
always@(posedge clk) begin
    if(ce == `ChipDisable) begin
        pc <= `ZeroWord;                        //复位时，pc归零
    end
    else if(branch_flag_i == `JumpEnable)begin
        pc <= branch_target_addr_i;             //跳转时，pc赋值为跳转目标地址
    end
    else if(stall[0] == `Stop)begin
        if(stall[1] == `NoStop)begin            //这里如果想要像ex_mem模块一样，输出空指令，不是将pc改为`ZeroWord（这样会输出第一条指令），而是需要对ce赋值，让rom_program模块输出空指令
            pc <= pc;
        end
        else begin
            pc <= pc;
        end
    end
    else begin
        pc <= pc + 1;                           //正常工作时，时钟有效沿到来pc+4
    end
end

    
endmodule
//注意是时序电路，有clk控制，含D触发器，所以写代码时注意1. posedge clk, 2. <=赋值