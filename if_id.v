
`include "defines.v"

module if_id(   //取指令阶段 instruction fetch to instruction decode
    input clk,
    input rst,
    input wire[`InstAddrBus] if_pc, //指令地址
    input wire[`InstBus] if_inst,   //指令，来自指令存储器
    input wire[`StallBus] stall,    //暂停信号

    output reg[`InstAddrBus] id_pc, 
    output reg[`InstBus] id_inst
);

    reg [`InstAddrBus] pc_temp;         //临时存储pc，为了抵消指令在rom_program处发生的一个时钟的延迟，也给pc加一个延迟
    always@(posedge clk) begin
        if(rst == `RstEnable) begin
            pc_temp <= `ZeroWord;
        end
        else begin
            pc_temp <= if_pc;
        end
    end
    
    reg [`StallBus] stall_delay;         //暂停信号的延迟一个周期的信号
    always@(posedge clk) begin
        if(rst == `RstEnable) begin
            stall_delay <= `NoStop;
        end
        else begin
            stall_delay <= stall;
        end
    end

    always@(posedge clk) begin 
        if(rst == `RstEnable) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end   
        else if(stall[1] == `Stop || stall_delay[1] == `Stop) begin    //若取指暂停
            if(stall[2] == `NoStop) begin   //译码不暂停，输出空指令 ?会什么都不做还是输出第一条指令？:输出第一条指令
                id_pc <= `ZeroWord;
                id_inst <= `ZeroWord;
            end
            else begin                      //译码暂停，输出指令维持不变
                id_pc <= id_pc;
                id_inst <= id_inst;
            end
        end
        else begin  //正常取指
            id_pc <= pc_temp;
            id_inst <= if_inst;
        end
    end

endmodule