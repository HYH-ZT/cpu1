
`include "defines.v"

module regfile(
    input clk,
    input rst,

    //写端口
    input we,                                       //写使能信号
    input wire[`RegAddrBus] waddr,                  //写目标寄存器地址
    input wire[`RegBus] wdata,                      //写入的数据

    //两个读端口
    input re1,                                      //端口1读使能信号
    input re2,                                      //端口2读使能信号
    input wire[`RegAddrBus] raddr1,                 //端口1读目标寄存器地址
    input wire[`RegAddrBus] raddr2,                 //端口2读目标寄存器地址
    output reg[`RegBus] rdata1,                     //端口1读到的寄存器数据
    output reg[`RegBus] rdata2                      //端口2读到的寄存器数据
);

//定义32个32位寄存器
reg[`RegBus] regs[0:`RegNum-1]; 
//变量名前面的一个变量线组中含32根线，即一个寄存器有32位，
//变量名后面的数字表示线组的个数，有32个寄存器

//写操作
integer i = 0;
always@(posedge clk) begin
    if(rst == `RstEnable) begin
        for(i=0 ; i<`RegNum ; i = i+1) begin        //对数组操作用for循环方便
            regs[i] <= `ZeroWord;                   //复位时把32个寄存器全部清零
        end
    end
    else begin
        if((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin                 //写使能，但是第一个寄存器必须一直是零，排除写地址为0的情况，因为地址为0的寄存器表示始终储存0的寄存器。有什么用？
            regs[waddr] <= wdata;
        end
        else begin
            regs[waddr] <= regs[waddr];                                             //其他情况下保持不变
        end
    end
end


//读端口1的读操作
always@(*) begin
    if(rst == `RstEnable) begin
        rdata1 = `ZeroWord;
    end
    else if((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) begin    //当读取的端口正在被写时，直接读取写入的值
        rdata1 = wdata;  //这一条语句解决了相隔两条指令间的数据冲突
    end
    else if(re1 == `ReadEnable) begin
        rdata1 = regs[raddr1];
    end
    else begin
        rdata1 = `ZeroWord;                         //若读使能关闭，默认输出0
    end
end


//读端口2的读操作
always@(*) begin
    if(rst == `RstEnable) begin
        rdata2 = `ZeroWord;
    end
    else if((raddr2 == waddr) && (we == `WriteEnable) && (re2 == `ReadEnable)) begin    //当读取的端口正在被写时，直接读取写入的值
        rdata2 = wdata;
    end
    else if(re2 == `ReadEnable) begin
        rdata2 = regs[raddr2];
    end
    else begin
        rdata2 = `ZeroWord;
    end
end


endmodule
/*
这里可以体会到阻塞性赋值和非阻塞性赋值的区别，
阻塞性赋值是在时序电路中使用的，设计出来的电路含有D触发器，
非阻塞性赋值是在组合电路中使用的

注意时序电路设计时，有clk控制，含D触发器，写代码时注意1. posedge clk, 2. <=赋值
注意纯组合电路设计时，写代码时注意1. always@(*), 2. =阻塞性赋值
*/