`include "defines.v"

module my_mips_cpu(
    input rst,
    input clk,
    input wire[`RegBus] rom_data_i,
    output wire[`RegBus] rom_addr_o,
    output rom_ce_o
);


//连接if/id模块与id模块
wire [`InstAddrBus] pc;
wire [`InstAddrBus] if_id2id__pc;
wire [`InstBus] if_id2id__inst;


//连接id模块与id/ex模块
wire [`AluOpBus] id2id_ex__aluop;
wire [`AluSelBus] id2id_ex__alusel;
wire [`RegBus] id2id_ex__rdata1;
wire [`RegBus] id2id_ex__rdata2;
wire id2id_ex__we_reg;
wire [`RegAddrBus] id2id_ex__waddr_reg;


//连接ex模块与id模块
wire ex2id__we_reg;
wire [`RegBus] ex2id__wdata;
wire [`RegAddrBus] ex2id__waddr_reg;


//连接mem模块与id模块
wire mem2id__we_reg;
wire [`RegBus] mem2id__wdata;
wire [`RegAddrBus] mem2id__waddr_reg;


//连接id模块与regfile模块
wire id2regfile__re1;
wire id2regfile__re2;
wire [`RegBus] regfile2id__rdata1;
wire [`RegBus] regfile2id__rdata2;
wire [`RegAddrBus] id2regfile__raddr1;
wire [`RegAddrBus] id2regfile__raddr2;


//连接id/ex模块与ex模块
wire [`AluOpBus] id_ex2ex__aluop;
wire [`AluSelBus] id_ex2ex__alusel;
wire [`RegBus] id_ex2ex__rdata1;
wire [`RegBus] id_ex2ex__rdata2;
wire [`RegAddrBus] id_ex2ex__waddr_reg;
wire id_ex2ex__we_reg;


//连接ex模块ex/mem模块
wire ex2ex_mem__we_reg;
wire [`RegAddrBus] ex2ex_mem__waddr_reg;
wire [`RegBus] ex2ex_mem__wdata;


//连接ex/mem与mem模块
wire ex_mem2mem__we_reg;
wire [`RegAddrBus] ex_mem2mem__waddr_reg;
wire [`RegBus] ex_mem2mem__wdata;


//连接mem模块与mem/wb模块
wire mem2mem_wb__we_reg;
wire [`RegAddrBus] mem2mem_wb__waddr_reg;
wire [`RegBus] mem2mem_wb__wdata;


//连接mem/wb与regfile模块
wire mem_wb2regfile__we;
wire [`RegAddrBus] mem_wb2regfile__waddr;
wire [`RegBus] mem_wb2regfile__wdata;


//pc_reg实例化
(*DONT_TOUCH = "yes"*)pc_reg pc_reg_inst0(
    .clk(clk),
    .rst(rst),
    .pc(pc),
    .ce(rom_ce_o)
);


//指令存储器输入地址rom_addr_o就是pc
assign rom_addr_o = pc;


//if/id实例化
(*DONT_TOUCH = "yes"*)if_id if_id_inst0(
    .clk(clk),
    .rst(rst),
    .if_pc(pc),
    .if_inst(rom_data_i),
    .id_pc(if_id2id__pc),
    .id_inst(if_id2id__inst)
);


// id实例化
(*DONT_TOUCH = "yes"*) id id_inst0(
    .rst(rst),
    .pc_i(if_id2id__pc),
    .inst_i(if_id2id__inst),

    // 读到的寄存器值
    .rdata1_i(regfile2id__rdata1),
    .rdata2_i(regfile2id__rdata2),

    // 给寄存器堆的控制信号
    .re1_o(id2regfile__re1),
    .re2_o(id2regfile__re2),
    .raddr1_o(id2regfile__raddr1),
    .raddr2_o(id2regfile__raddr2),

    // 送给执行阶段的数据
    .aluop_o(id2id_ex__aluop),
    .alusel_o(id2id_ex__alusel),
    .rdata1_o(id2id_ex__rdata1),
    .rdata2_o(id2id_ex__rdata2),
    .waddr_reg_o(id2id_ex__waddr_reg),
    .we_reg_o(id2id_ex__we_reg)
);


//regfile实例化
(*DONT_TOUCH = "yes"*)regfile regfile_inst0(
    .clk(clk),
    .rst(rst),

    .we(mem_wb2regfile__we),
    .waddr(mem_wb2regfile__waddr),
    .wdata(mem_wb2regfile__wdata),
    .re1(id2regfile__re1),
    .re2(id2regfile__re2),
    .raddr1(id2regfile__raddr1),
    .raddr2(id2regfile__raddr2),

    .rdata1(regfile2id__rdata1),
    .rdata2(regfile2id__rdata2)
);


//id/ex实例化
(*DONT_TOUCH = "yes"*)id_ex id_ex_inst0(
    .clk(clk),
    .rst(rst),

    .id_aluop_i(id2id_ex__aluop),
    .id_alusel_i(id2id_ex__alusel),
    .id_rdata1_i(id2id_ex__rdata1),
    .id_rdata2_i(id2id_ex__rdata2),
    .id_waddr_reg_i(id2id_ex__waddr_reg),
    .id_we_reg_i(id2id_ex__we_reg),

    .ex_aluop_o(id_ex2ex__aluop),
    .ex_alusel_o(id_ex2ex__alusel),
    .ex_rdata1_o(id_ex2ex__rdata1),
    .ex_rdata2_o(id_ex2ex__rdata2),
    .ex_waddr_reg_o(id_ex2ex__waddr_reg),
    .ex_we_reg_o(id_ex2ex__we_reg)
);


//ex实例化
(*DONT_TOUCH = "yes"*) ex ex_inst0(
    .rst(rst),

    .aluop_i(id_ex2ex__aluop),
    .alusel_i(id_ex2ex__alusel),
    .rdata1_i(id_ex2ex__rdata1),
    .rdata2_i(id_ex2ex__rdata2),
    .waddr_reg_i(id_ex2ex__waddr_reg),
    .we_reg_i(id_ex2ex__we_reg),
    
    .waddr_reg_o(ex2ex_mem__waddr_reg),
    .we_reg_o(ex2ex_mem__we_reg),
    .wdata_o(ex2ex_mem__wdata)
);


// ex/mem实例化
(*DONT_TOUCH = "yes"*)ex_mem ex_mem_inst0(
    .clk(clk),
    .rst(rst),
    .ex_waddr_reg_i(ex2ex_mem__waddr_reg),
    .ex_we_reg_i(ex2ex_mem__we_reg),
    .ex_wdata_i(ex2ex_mem__wdata),
    .mem_waddr_reg_o(ex_mem2mem__waddr_reg),
    .mem_we_reg_o(ex_mem2mem__we_reg),
    .mem_wdata_o(ex_mem2mem__wdata)
);


// mem实例化
(*DONT_TOUCH = "yes"*) mem mem_inst0(
    .rst(rst),
    .waddr_reg_i(ex_mem2mem__waddr_reg),
    .we_reg_i(ex_mem2mem__we_reg),
    .wdata_i(ex_mem2mem__wdata),
    .waddr_reg_o(mem2mem_wb__waddr_reg),
    .we_reg_o(mem2mem_wb__we_reg),
    .wdata_o(mem2mem_wb__wdata)
);


// mem/wb实例化
(*DONT_TOUCH = "yes"*)mem_wb mem_wb_inst0(
    .clk(clk),
    .rst(rst),
    .mem_waddr_reg_i(mem2mem_wb__waddr_reg),
    .mem_we_reg_i(mem2mem_wb__we_reg),
    .mem_wdata_i(mem2mem_wb__wdata),
    
    .wb_waddr_reg_o(mem_wb2regfile__waddr),
    .wb_we_reg_o(mem_wb2regfile__we),
    .wb_wdata_o(mem_wb2regfile__wdata)
);


endmodule