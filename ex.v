`include "defines.v"

module ex(
    input rst,
    
    //译码的输入
    input wire[`AluOpBus] aluop_i,                  //操作子类型
    input wire[`AluSelBus] alusel_i,                //操作类型
    input wire[`RegBus] rdata1_i,                   //操作数1
    input wire[`RegBus] rdata2_i,                   //操作数2
    input wire[`RegAddrBus] waddr_reg_i,            //写目标寄存器地址
    input wire we_reg_i,                            //写使能信号

    input wire now_in_delayslot_i,                  //当前指令是否是延迟槽指令
    input wire [`InstAddrBus] return_addr_i,         //返回地址

    // HILO模块给出HI,LO寄存器的值
    input wire[`RegBus] hi_i,
    input wire[`RegBus] lo_i,

    //把HILO数据相关可能数据传回来
    input wire[`RegBus] wb_hi_i,
    input wire[`RegBus] wb_lo_i,
    input wire wb_whilo_i,
    input wire[`RegBus] mem_hi_i,
    input wire[`RegBus] mem_lo_i,
    input wire mem_whilo_i,

    //执行后结果
    output reg[`RegAddrBus] waddr_reg_o,            //写目标寄存器地址
    output reg we_reg_o,                            //写使能信号
    output reg[`RegBus] wdata_o,                     //处理后的数据

    output reg stallreq_o,                           //暂停请求信号

    //HILO写相关的输出
    output reg[`RegBus] hi_o,
    output reg[`RegBus] lo_o,
    output reg whilo_o
);

//保存逻辑运算的结果
reg[`RegBus] logicout;
//移位运算结果
reg[`RegBus] shiftres;
//移动操作结果
reg[`RegBus] moveres;
//HI寄存器最新值
reg[`RegBus] HI;
//LO寄存器最新值
reg[`RegBus] LO;


//***************************************************************************************************//
//*******************************得到最新HILO的值，解决数据相关****************************************//
//***************************************************************************************************//

always@(*) begin
    if(rst == `RstEnable) begin
        {HI,LO} = {`ZeroWord,`ZeroWord};
    end
    else if(mem_whilo_i == `WriteEnable) begin
        {HI,LO} = {mem_hi_i,mem_lo_i};
    end
    else if(wb_whilo_i == `WriteEnable) begin
        {HI,LO} = {wb_hi_i,wb_lo_i};
    end
    else begin
        {HI,LO} = {hi_i,lo_i};
    end
end

//***************************************************************************************************//
//*******************************根据运算子类型aluop_i进行计算*****************************************//
//***************************************************************************************************//

always@(*) begin
    if(rst == `RstEnable) begin
        logicout = `ZeroWord;
    end
    else begin
        case(aluop_i) 
            `EXE_OR_OP: begin                                   //或运算
                logicout = rdata1_i | rdata2_i;
            end
            `EXE_AND_OP: begin                                  //与运算
                logicout = rdata1_i & rdata2_i;
            end
            `EXE_NOR_OP: begin
                logicout = ~(rdata1_i | rdata2_i);
            end
            `EXE_XOR_OP: begin                                  //异或运算
                logicout = rdata1_i ^ rdata2_i;
            end
            `EXE_SLL_OP: begin
                shiftres = (rdata2_i << rdata1_i[4:0]);
            end
            `EXE_SRL_OP: begin
                shiftres = (rdata2_i >> rdata1_i[4:0]);
            end
            `EXE_SRA_OP: begin
                shiftres = ({32{rdata2_i[31]}}<<(6'd32-{1'b0,rdata1_i[4:0]})) | rdata2_i >> rdata1_i[4:0]; 
            end
            default: begin
                logicout = `ZeroWord;
            end
        endcase
    end
end

always@(*) begin
    if(rst == `RstEnable) begin
        shiftres = `ZeroWord;
    end
    else begin
        case(aluop_i) 
            `EXE_SLL_OP: begin
                shiftres = (rdata2_i << rdata1_i[4:0]);
            end
            `EXE_SRL_OP: begin
                shiftres = (rdata2_i >> rdata1_i[4:0]);
            end
            `EXE_SRA_OP: begin
                shiftres = ({32{rdata2_i[31]}}<<(6'd32-{1'b0,rdata1_i[4:0]})) | rdata2_i >> rdata1_i[4:0]; 
            end
            default: begin
                shiftres = `ZeroWord;
            end
        endcase
    end
end

always@(*) begin
    if(rst == `RstEnable) begin
        moveres = `ZeroWord;
    end
    else begin
        moveres = `ZeroWord;
        case(aluop_i)
            `EXE_MFHI_OP: begin
                moveres = HI;
            end
            `EXE_MFLO_OP: begin
                moveres = LO;
            end
            `EXE_MOVZ_OP: begin
                moveres = rdata1_i;
            end
            `EXE_MOVN_OP: begin
                moveres = rdata1_i;
            end
            default: begin
            end
        endcase
    end
end

//***************************************************************************************************//
//*******************************根据运算类型alusel_i选择运算结果**************************************//
//***************************************************************************************************//

always@(*) begin
    waddr_reg_o = waddr_reg_i;
    we_reg_o = we_reg_i;                                //写目标地址与写使能信号直接通过
    case(alusel_i) 
        `EXE_RES_LOGIC: begin           //逻辑运算类型
            wdata_o = logicout;
        end
        `EXE_RES_SHIFT: begin           //移位运算类型
            wdata_o = shiftres;
        end
        `EXE_RES_MOVE: begin
            wdata_o = moveres;
        end
        `EXE_RES_JUMP_BRANCH: begin     //跳转结果类型，返回跳转前位置处的指令所在地址
            wdata_o = return_addr_i;
        end
        default: begin
            wdata_o = `ZeroWord;
        end
    endcase
end

//暂停请求信号
always @(*)begin
    if(rst == `RstEnable)begin
        stallreq_o = `NoStop;
    end
    else begin
        stallreq_o = `NoStop;
    end
end




//***************************************************************************************************//
//*******************************给出LO，HI相关结果***************************************************//
//***************************************************************************************************//

always@(*) begin
    if(rst == `RstEnable) begin
        whilo_o = `WriteDisable;
        hi_o = `ZeroWord;
        lo_o = `ZeroWord;
    end
    else if(aluop_i == `EXE_MTLO_OP) begin
        whilo_o = `WriteEnable;
        hi_o = HI;                  
        lo_o = rdata1_i;
    end
    else if(aluop_i == `EXE_MTHI_OP) begin
        whilo_o = `WriteEnable;
        hi_o = rdata1_i;
        lo_o = LO;
    end
    else begin
        whilo_o = `WriteDisable;
        hi_o = `ZeroWord;
        lo_o = `ZeroWord;
    end
end


endmodule

//这里的代码优点：利用logicout和shiftres两个变量，
//分别保存逻辑运算和移位运算的结果，然后根据不同的运算类型，选择不同的结果输出。
//这样的代码结构，将两层嵌套的case语句独立成两段，使得代码的可读性和可维护性都有很大的提高。
//但是不适用于id模块，因为那边输出变量太多了，而此处ex模块只有1个输出变量，所以可以这样写。