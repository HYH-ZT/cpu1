`timescale 1ns/1ns
`include "defines.v"

module pc_reg_tb;

    reg clk;
    reg rst;
    wire[`InstAddrBus] pc;
    wire ce;

pc_reg inst(
    clk,
    rst,
    pc,
    ce
);

always#5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    #100
    rst = 0;
end


endmodule