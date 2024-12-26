`include "defines.v"

module my_mips_cpu(
    input rst,
    input clk,
    input wire[`RegBus] rom_data_i,
    output wire[`RegBus] rom_addr_o,
    output rom_ce_o
);

//****************************************************************//
//**************************端口定义*******************************//
//****************************************************************//

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
wire id2id_ex__now_in_delayslot;
wire id2id_ex__next_in_delayslot;
wire [`InstAddrBus] id2id_ex__return_addr;
wire id_ex2id__now_in_delayslot;


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

wire id_ex2ex__now_in_delayslot;
wire [`InstAddrBus] id_ex2ex__return_addr;


//连接ex模块ex/mem模块
wire ex2ex_mem__we_reg;
wire [`RegAddrBus] ex2ex_mem__waddr_reg;
wire [`RegBus] ex2ex_mem__wdata;
wire [`RegBus] ex2ex_mem__hi;
wire [`RegBus] ex2ex_mem__lo;
wire ex2ex_mem__whilo;


//连接mem模块与ex模块（防止数据冲突）
wire mem2ex__whilo;
wire [`RegBus] mem2ex__hi;
wire [`RegBus] mem2ex__lo;


//连接mem/wb模块与ex模块（防止数据冲突）
wire mem_wb2ex__whilo;
wire [`RegBus] mem_wb2ex__hi;
wire [`RegBus] mem_wb2ex__lo;


//连接ex/mem与mem模块
wire ex_mem2mem__we_reg;
wire [`RegAddrBus] ex_mem2mem__waddr_reg;
wire [`RegBus] ex_mem2mem__wdata;
wire [`RegBus] ex_mem2mem__hi;
wire [`RegBus] ex_mem2mem__lo;
wire ex_mem2mem__whilo;


//连接mem模块与mem/wb模块
wire mem2mem_wb__we_reg;
wire [`RegAddrBus] mem2mem_wb__waddr_reg;
wire [`RegBus] mem2mem_wb__wdata;
wire [`RegBus] mem2mem_wb__hi;
wire [`RegBus] mem2mem_wb__lo;
wire mem2mem_wb__whilo;


//连接mem/wb与regfile模块
wire mem_wb2regfile__we;
wire [`RegAddrBus] mem_wb2regfile__waddr;
wire [`RegBus] mem_wb2regfile__wdata;

//连接mem/wb模块与hilo_reg模块
wire [`RegBus] wb2hilo__hi;
wire [`RegBus] wb2hilo__lo;
wire wb2hilo__we;


//连接hilo_reg模块与ex模块
wire [`RegBus] hilo2ex__hi;
wire [`RegBus] hilo2ex__lo;


//连接id与pc模块
wire [`InstAddrBus] id2pc__branch_target_addr;
wire id2pc__branch_flag;


//连接ctrl模块与其他模块
wire stallreq_upstream_from_id;
wire stallreq_downstream_from_id;
wire stallreq_from_ex;
wire [`StallBus] stall;

//****************************************************************//
//**************************实例化模块*****************************//
//****************************************************************//

//pc_reg实例化
(*DONT_TOUCH = "yes"*)pc_reg pc_reg_inst0(
    .clk(clk),
    .rst(rst),
    .branch_target_addr_i(id2pc__branch_target_addr),
    .branch_flag_i(id2pc__branch_flag),
    .stall(stall),
    // <-in out->
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
    .stall(stall),
    //<-in out->
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

    // 执行阶段运算结果
    .ex_we_reg_i(ex2id__we_reg),
    .ex_wdata_i(ex2id__wdata),
    .ex_waddr_reg_i(ex2id__waddr_reg),

    // 访存阶段结果
    .mem_we_reg_i(mem2id__we_reg),
    .mem_wdata_i(mem2id__wdata),
    .mem_waddr_reg_i(mem2id__waddr_reg),

    //当前是否为延迟槽指令
    .now_in_delayslot_i(id_ex2id__now_in_delayslot),

    //<-in out->                      

    // 给寄存器堆的控制信号
    .raddr1_o(id2regfile__raddr1),
    .raddr2_o(id2regfile__raddr2),
    .re1_o(id2regfile__re1),
    .re2_o(id2regfile__re2),

    // 送给执行阶段的数据
    .aluop_o(id2id_ex__aluop),
    .alusel_o(id2id_ex__alusel),
    .rdata1_o(id2id_ex__rdata1),
    .rdata2_o(id2id_ex__rdata2),
    .waddr_reg_o(id2id_ex__waddr_reg),
    .we_reg_o(id2id_ex__we_reg),

    ////给取指阶段，用于实现跳转
    .branch_flag_o(id2pc__branch_flag),
    .branch_target_addr_o(id2pc__branch_target_addr),

    //告诉下一阶段下一条指令以及当前指令是否为延迟槽
    .next_in_delayslot_o(id2id_ex__next_in_delayslot),
    .now_in_delayslot_o(id2id_ex__now_in_delayslot),
    //跳转成功后可能会返回当前下一条语句的地址
    .return_addr_o(id2id_ex__return_addr),
    //暂停请求
    .stallreq_downstream_o(stallreq_downstream_from_id),
    .stallreq_upstream_o(stallreq_upstream_from_id)
);


//将ex模块输出以及mem模块输出连接到id模块
assign ex2id__we_reg = ex2ex_mem__we_reg;
assign ex2id__wdata = ex2ex_mem__wdata;
assign ex2id__waddr_reg = ex2ex_mem__waddr_reg;
assign mem2id__we_reg = ex_mem2mem__we_reg;
assign mem2id__wdata = ex_mem2mem__wdata;
assign mem2id__waddr_reg = ex_mem2mem__waddr_reg;


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
    
    .id_now_in_delayslot_i(id2id_ex__now_in_delayslot),
    .id_next_in_delayslot_i(id2id_ex__next_in_delayslot),
    .id_return_addr_i(id2id_ex__return_addr),
    .stall(stall),

    //<-in out->

    .ex_aluop_o(id_ex2ex__aluop),
    .ex_alusel_o(id_ex2ex__alusel),
    .ex_rdata1_o(id_ex2ex__rdata1),
    .ex_rdata2_o(id_ex2ex__rdata2),
    .ex_waddr_reg_o(id_ex2ex__waddr_reg),
    .ex_we_reg_o(id_ex2ex__we_reg),

    .now_in_delayslot_o(id_ex2id__now_in_delayslot),
    .ex_return_addr_o(id_ex2ex__return_addr)
);


//ex实例化
(*DONT_TOUCH = "yes"*) ex ex0(
    .rst(rst),
    .aluop_i(id_ex2ex__aluop),
    .alusel_i(id_ex2ex__alusel),
    .rdata1_i(id_ex2ex__rdata1),
    .rdata2_i(id_ex2ex__rdata2),
    .waddr_reg_i(id_ex2ex__waddr_reg),
    .we_reg_i(id_ex2ex__we_reg),
    .now_in_delayslot_i(id_ex2ex__now_in_delayslot),
    .return_addr_i(id_ex2ex__return_addr),
    .hi_i(hilo2ex__hi),
    .lo_i(hilo2ex__lo),
    .wb_hi_i(mem_wb2ex__hi),
    .wb_lo_i(mem_wb2ex__lo),
    .wb_whilo_i(mem_wb2ex__whilo),
    .mem_hi_i(mem2ex__hi),
    .mem_lo_i(mem2ex__lo),
    .mem_whilo_i(mem2ex__whilo),
    .waddr_reg_o(ex2ex_mem__waddr_reg),
    .we_reg_o(ex2ex_mem__we_reg),
    .wdata_o(ex2ex_mem__wdata),
    .hi_o(ex2ex_mem__hi),
    .lo_o(ex2ex_mem__lo),
    .whilo_o(ex2ex_mem__whilo),
    .stallreq_o(stallreq_from_ex)
);

//把回连线对应起来
assign mem_wb2ex__hi = wb2hilo__hi;
assign mem_wb2ex__lo = wb2hilo__lo;
assign mem_wb2ex__whilo = wb2hilo__we;
assign mem2ex__hi = mem2mem_wb__hi;
assign mem2ex__lo = mem2mem_wb__lo;
assign mem2ex__whilo = mem2mem_wb__whilo;


// ex/mem实例化
(*DONT_TOUCH = "yes"*)ex_mem ex_mem0(
    .clk(clk),
    .rst(rst),
    .ex_waddr_reg_i(ex2ex_mem__waddr_reg),
    .ex_we_reg_i(ex2ex_mem__we_reg),
    .ex_wdata_i(ex2ex_mem__wdata),
    .stall(stall),
    .ex_hi_i(ex2ex_mem__hi),
    .ex_lo_i(ex2ex_mem__lo),
    .ex_whilo_i(ex2ex_mem__whilo),
    .mem_waddr_reg_o(ex_mem2mem__waddr_reg),
    .mem_we_reg_o(ex_mem2mem__we_reg),
    .mem_wdata_o(ex_mem2mem__wdata),
    .mem_hi_o(ex_mem2mem__hi),
    .mem_lo_o(ex_mem2mem__lo),
    .mem_whilo_o(ex_mem2mem__whilo)
);


// mem实例化
(*DONT_TOUCH = "yes"*) mem mem0(
    .rst(rst),
    .waddr_reg_i(ex_mem2mem__waddr_reg),
    .we_reg_i(ex_mem2mem__we_reg),
    .wdata_i(ex_mem2mem__wdata),
    .hi_i(ex_mem2mem__hi),
    .lo_i(ex_mem2mem__lo),
    .whilo_i(ex_mem2mem__whilo),
    .waddr_reg_o(mem2mem_wb__waddr_reg),
    .we_reg_o(mem2mem_wb__we_reg),
    .wdata_o(mem2mem_wb__wdata),
    .hi_o(mem2mem_wb__hi),
    .lo_o(mem2mem_wb__lo),
    .whilo_o(mem2mem_wb__whilo)
);


// mem/wb实例化
(*DONT_TOUCH = "yes"*)mem_wb mem_wb0(
    .clk(clk),
    .rst(rst),
    .mem_waddr_reg_i(mem2mem_wb__waddr_reg),
    .mem_we_reg_i(mem2mem_wb__we_reg),
    .mem_wdata_i(mem2mem_wb__wdata),
    .stall(stall),
    .mem_hi_i(mem2mem_wb__hi),
    .mem_lo_i(mem2mem_wb__lo),
    .mem_whilo_i(mem2mem_wb__whilo),
    .wb_waddr_reg_o(mem_wb2regfile__waddr),
    .wb_we_reg_o(mem_wb2regfile__we),
    .wb_wdata_o(mem_wb2regfile__wdata),
    .wb_hi_o(wb2hilo__hi),
    .wb_lo_o(wb2hilo__lo),
    .wb_whilo_o(wb2hilo__we)
);


//实例化hilo_reg模块
(*DONT_TOUCH = "yes"*)hilo_reg hilo_reg0(
    .clk(clk),
    .rst(rst),
    .we(wb2hilo__we),
    .hi_i(wb2hilo__hi),
    .lo_i(wb2hilo__lo),
    .hi_o(hilo2ex__hi),
    .lo_o(hilo2ex__lo)
);


// ctrl模块实例化
(*DONT_TOUCH = "yes"*) ctrl ctrl_inst0(
    .rst(rst),
    .stallreq_upstream_from_id(stallreq_upstream_from_id),
    .stallreq_downstream_from_id(stallreq_downstream_from_id),
    .stallreq_from_ex(stallreq_from_ex),
    // <-in out->
    .stall(stall)
);

endmodule