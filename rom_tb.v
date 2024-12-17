`timescale 1ns/1ns

module rom_tb;

reg clka;
reg ena;
reg [9:0] addra;
wire[31:0] douta;

rom_program rom_inst(
    .clk(clka),
    .rom_addr_i(addra),
    .rom_ce_i(ena),
    .rom_data_o(douta)
);


always#5 clka = ~clka;

initial begin
    clka = 0;
    ena = 0;
    addra = 0;
    #10
    ena = 1;
    #5
    addra = 0;
    #10
    addra = 1;
    #10
    addra = 2;
    #10
    addra = 3;
    #10
    addra = 4;
end


endmodule