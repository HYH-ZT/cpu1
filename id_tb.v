`timescale 1ns/1ns
`include "defines.v"

module id_tb;

reg clk;
reg rst;

reg [`InstAddrBus] pc_i;                      //输入的程序计数器值
reg [`InstBus] inst_i;                        //输入的指令

//读到的寄存器值
reg [`RegBus] rdata1_i;                       //从寄存器读到的值1
reg [`RegBus] rdata2_i;                       //从寄存器读到的值2

//给寄存器堆的控制信号
wire re1_o;                                   //读端口1的读使能信号
wire re2_o;                                   //读端口2的读使能信号
wire[`RegAddrBus] raddr1_o;                   //读端口1的目标寄存器地址
wire[`RegAddrBus] raddr2_o;                   //读端口2的目标寄存器地址

//送给执行阶段的数据
wire[`AluOpBus] aluop_o;                      //给alu的子操作码
wire[`AluSelBus] alusel_o;                    //给alu的操作类型
wire[`RegBus] rdata1_o;                       //读到的操作数1的数据
wire[`RegBus] rdata2_o;                       //读到的操作数2的数据
wire[`RegAddrBus] waddr_reg_o;                //要写的寄存器的地址
wire we_reg_o;   


//-----------实例化被测模块-----------

id inst_id(
    rst,
    pc_i,                 
    inst_i,               

    //读到的寄存器值
    rdata1_i,             
    rdata2_i,             

    //给寄存器堆的控制信
    re1_o,                
    re2_o,                
    raddr1_o,             
    raddr2_o,             

    //送给执行阶段的数据
    aluop_o,              
    alusel_o,             
    rdata1_o,             
    rdata2_o,             
    waddr_reg_o,          
    we_reg_o              
);

//-----------给输入信号赋值-----------

always#5 clk = ~clk;

initial begin
    rst = 1;
    clk = 0;
    #50
    rst = 0;
end

always@(posedge clk) begin
end


endmodule