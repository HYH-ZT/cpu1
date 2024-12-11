`include "defines.v"

module id( //功能：在给指令解码的同时，取两个操作数送给下一级执行阶段
    input rst,
    input wire[`InstAddrBus] pc_i,                      //输入的程序计数器值   ?何用
    input wire[`InstBus] inst_i,                        //输入的指令

    //---和寄存器互动，读取寄存器中的两个数据---
    output reg[`RegAddrBus] raddr1_o,                    //寄存器地址，用于告诉寄存器，读取其中的数据
    output reg[`RegAddrBus] raddr2_o,
    output reg re1_o,                    //给寄存器的读使能信号
    output reg re2_o,
    input wire[`RegBus] rdata1_i,                     //从寄存器中读取到的数据
    input wire[`RegBus] rdata2_i,

    //---给下一个执行阶段的信号---
    //控制信号
    output reg[`AluOpBus] aluop_o,                      //运算子类型，选择或，与等操作数
    output reg[`AluSelBus] alusel_o,                    //运算类型，选择逻辑运算，算术运算
    //待处理的数据信号
    output reg[`RegBus] rdata1_o,                         //输出从寄存器读到的数据 
    output reg[`RegBus] rdata2_o,
    //是否写入、待写入寄存器的地址的信号
    output reg[`RegAddrBus] waddr_reg_o,                        //写入寄存器的地址
    output reg we_reg_o                                    //写使能信号，表示是否有要写入的寄存器
);


//译码：将整条指令分割成不同的部分，做为标记，方便后续使用
wire [5:0] op;
wire [`RegAddrBus] rs, rt, rd;          //源地址寄存器，目的地址寄存器
wire [5:0] op_fun;                      //功能码
wire [15:0] op_imm;                     //立即数
wire [5:0] sa;                          //移位量

assign op = inst_i[31:26];               //指令码，用于规定指令的类型
assign rs = inst_i[25:21];               //I型指令的源寄存器
assign rt = inst_i[20:16];               //I型指令的目的寄存器，R型指令的源寄存器
assign op_imm = inst_i[15:0];            //I型指令的立即数

assign rd = inst_i[15:11];               //R型指令的目的寄存器
assign op_fun = inst_i[5:0];             //R型指令的功能码
assign sa = inst_i[10:6];                //R型指令移位功能的移位量

reg instvalid;                          //指示指令是否有效
reg [`RegBus] imm;


always@(*) begin
    if(rst == `RstEnable) begin
        aluop_o = `EXE_NOP_OP;
        alusel_o = `EXE_RES_NOP;
        waddr_reg_o = `NOPRegAddr;
        we_reg_o = `WriteDisable;
        instvalid = `InstValid;
        re1_o = `ReadDisable;
        re2_o = `ReadDisable;
        raddr1_o = `NOPRegAddr;
        raddr2_o = `NOPRegAddr;
        imm = `ZeroWord;
    end
    
    //这部分赋默认值, 相当于放在后面的default里，是为了让SPECIAL_INST（R型指令）更方便
    else begin
        aluop_o = `EXE_NOP_OP;
        alusel_o = `EXE_RES_NOP;
        waddr_reg_o = rd;               //默认R型指令
        we_reg_o = `WriteDisable;
        instvalid = `InstInvalid;
        re1_o = `ReadDisable;
        re2_o = `ReadDisable;
        raddr1_o = `NOPRegAddr;
        raddr2_o = `NOPRegAddr;
        raddr1_o = rs;                  //默认R型指令
        raddr2_o = rt;                  //默认R型指令
        imm = `ZeroWord;

        case(op)
            `EXE_SPECIAL_INST: begin        //R型指令
                if(sa == 5'b00000) begin    //当sa为00000时，表示逻辑或移位v功能   
                    we_reg_o = `WriteEnable;        //R型指令的公共特点    
                    re1_o = `ReadEnable;    
                    re2_o = `ReadEnable;    
                    instvalid = `InstValid;

                    case(op_fun)
                        `EXE_FUN_AND: begin
                            aluop_o = `EXE_AND_OP;
                            alusel_o = `EXE_RES_LOGIC;
                            // re1_o = `ReadEnable;     //这里不需要再赋值，因为case前已赋值过默认值就是
                            // re2_o = `ReadEnable;
                            // instvalid = `InstValid;
                            // we_reg_o = `WriteEnable;
                            // waddr_reg_o = rd;       //这里也同理不需要再赋值
                            // raddr1_o = rs;
                            // raddr2_o = rt;
                        end
                        `EXE_FUN_OR: begin
                            aluop_o = `EXE_OR_OP;
                            alusel_o = `EXE_RES_LOGIC;
                        end
                        `EXE_FUN_XOR: begin
                            aluop_o = `EXE_XOR_OP;
                            alusel_o = `EXE_RES_LOGIC;
                        end
                        `EXE_FUN_NOR: begin
                            aluop_o = `EXE_NOR_OP;
                            alusel_o = `EXE_RES_LOGIC;
                        end
                        `EXE_FUN_SLLV: begin
                            aluop_o = `EXE_SLL_OP;
                            alusel_o = `EXE_RES_SHIFT;
                        end
                        `EXE_FUN_SRLV: begin
                            aluop_o = `EXE_SRL_OP;
                            alusel_o = `EXE_RES_SHIFT;
                        end
                        `EXE_FUN_SRAV: begin
                            aluop_o = `EXE_SRA_OP;
                            alusel_o = `EXE_RES_SHIFT;
                        end
                        `EXE_FUN_SYNC: begin
                            we_reg_o = `WriteDisable;
                            aluop_o = `EXE_NOP_OP;
                            alusel_o = `EXE_RES_NOP;
                            re1_o = `ReadDisable;
                            re2_o = `ReadEnable;//?
                            raddr1_o = `NOPRegAddr;
                            raddr2_o = `NOPRegAddr;
                            instvalid = `InstValid;
                        end
                        default: begin
                        end
                    endcase
                end
                // else if(rs == 5'b00000)begin                   //当sa不为00000时，表示移位(无v)功能 、这里waddr_reg_o都要改
                //     case(op_fun)
                //         `EXE_FUN_SLL: begin
                //             aluop_o = `EXE_SLL_OP;
                //             alusel_o = `EXE_RES_SHIFT;
                //             re1_o = `ReadEnable;
                //             re2_o = `ReadDisable;
                //             instvalid = `InstValid;
                //         end
                //         `EXE_FUN_SRL: begin
                //             aluop_o = `EXE_SRL_OP;
                //             alusel_o = `EXE_RES_SHIFT;
                //             re1_o = `ReadEnable;
                //             re2_o = `ReadDisable;
                //             instvalid = `InstValid;
                //         end
                //         `EXE_FUN_SRA: begin
                //             aluop_o = `EXE_SRA_OP;
                //             alusel_o = `EXE_RES_SHIFT;
                //             re1_o = `ReadEnable;
                //             re2_o = `ReadDisable;
                //             instvalid = `InstValid;
                //         end
                //         default: begin
                //         end
                //     endcase
                // end
                else begin
                end
            end
            `EXE_ORI: begin
                we_reg_o = `WriteEnable;
                aluop_o = `EXE_OR_OP;               //注意区分这里的`EXE_OR_OP和`EXE_ORI（指令）
                alusel_o = `EXE_RES_LOGIC;
                re1_o = `ReadEnable;
                re2_o = `ReadDisable;
                raddr1_o = rs;
                raddr2_o = `NOPRegAddr;
                imm = {16'h0000, op_imm};           //立即数,无符号扩展
                waddr_reg_o = rt;
                instvalid = `InstValid;
            end
            `EXE_ANDI: begin                           //立即数与
                we_reg_o = `WriteEnable;
                aluop_o = `EXE_AND_OP;
                alusel_o = `EXE_RES_LOGIC;
                re1_o = `ReadEnable;
                re2_o = `ReadDisable;
                raddr1_o = rs;
                raddr2_o = `NOPRegAddr;
                imm = {16'h0000, op_imm};      //立即数,无符号扩展
                waddr_reg_o = rt;
                instvalid = `InstValid;
            end
            `EXE_XORI: begin                           //立即数异或
                we_reg_o = `WriteEnable;
                aluop_o = `EXE_XOR_OP;
                alusel_o = `EXE_RES_LOGIC;
                re1_o = `ReadEnable;
                re2_o = `ReadDisable;
                raddr1_o = rs;
                raddr2_o = `NOPRegAddr;
                imm = {16'h0000, op_imm};      //立即数,无符号扩展
                waddr_reg_o = rt;
                instvalid = `InstValid;
            end
            `EXE_LUT: begin                            //立即数保存 //先不管
                we_reg_o = `WriteEnable;
                aluop_o = `EXE_OR_OP;
                alusel_o = `EXE_RES_LOGIC;
                re1_o = `ReadDisable;
                re2_o = `ReadDisable;
                raddr1_o = `NOPRegAddr;
                raddr2_o = `NOPRegAddr;
                imm = {op_imm, 16'h0000};      //立即数,无符号扩展
                waddr_reg_o = rt;
                instvalid = `InstValid;
            end
            //还差pref指令

            default : begin //这里赋的默认值具体语句在case语句前
            end
            
        endcase
    end //end of else
end //end of always

//****************************************************************//
//**************************确定操作数1****************************//
//****************************************************************//

always@(*) begin
    if(rst == `RstEnable) begin
        rdata1_o = `ZeroWord;
    end
    else if (re1_o == `ReadEnable) begin
        rdata1_o = rdata1_i;
    end
    else if (re1_o == `ReadDisable) begin
        rdata1_o = imm;
    end
    else begin                                      //其实上面已经包含了所有情况，这里的else是多余的
        rdata1_o = `ZeroWord;
    end
end

//****************************************************************//
//**************************确定操作数2****************************//
//****************************************************************//

always@(*) begin
    if(rst == `RstEnable) begin
        rdata2_o = `ZeroWord;
    end
    else if (re2_o == `ReadEnable) begin
        rdata2_o = rdata2_i;
    end
    else begin                                      //其实上面已经包含了所有情况，这里的else是多余的
        rdata2_o = `ZeroWord;
    end
end


endmodule
//下面是自己写的原始代码，这种习惯不符合按功能分类的要求。按功能分类，而不是按赋值的种类分类会对于cpu的设计更清晰
// //指示指令是否有效
// reg instvalid;

// always@(*) begin
//     if(rst == `RstEnable) begin
//         instvalid = 0;
//     end
//     else begin
//         instvalid = 1;
//     end
// end


// //---和寄存器互动，读取寄存器中的两个数据---

// //给reg1_read_o和reg2_read_o赋值
// always@(*) begin
//     if(rst == `RstEnable) begin
//         reg1_read_o = 0;
//         reg2_read_o = 0;
//     end
//     else begin
//         reg1_read_o = 1;
//         reg2_read_o = 1;
//     end
// end

// //给reg1_addr_o和reg2_addr_o赋值
// always@(*) begin
//     if(rst == `RstEnable) begin
//         reg1_addr_o = 0;
//         reg2_addr_o = 0;
//     end
//     else begin
//         reg1_addr_o = rs;
//         reg2_addr_o = rt;
//     end
// end


// //---给下一个执行阶段的信号---

// //控制信号：给aluop_o和alusel_o赋值,还不知道ori具体对应什么aluop_o和alusel_o
// always@(*) begin
//     if (rst == `RstEnable) begin
//         aluop_o = `EXE_NOP_OP;
//         alusel_o = `EXE_RES_NOP;
//     end
//     else begin
//         case(op)
//             `EXE_ORI: begin
//                 aluop_o = `EXE_OR_OP;
//                 alusel_o = `EXE_RES_LOGIC;
//             end
//             default: begin
//                 aluop_o = `EXE_NOP_OP;
//                 alusel_o = `EXE_RES_NOP;
//             end
//         endcase
//     end
// end
// //待处理的数据信号: 给reg1_o和reg2_o赋值
// always@(*) begin
//     if(rst == `RstEnable) begin
//         reg1_o = 0;
//         reg2_o = 0;
//     end
//     else begin
//         reg1_o = reg1_data_i;
//         reg2_o = reg2_data_i;
//     end
// end


// //是否写入、待写入寄存器的地址的信号: 给wd_o和wreg_o赋值
// always@(*) begin
//     if(rst == `RstEnable) begin
//         wd_o = 0;
//         wreg_o = 0;
//     end
//     else begin
//         wd_o = rt;
//         wreg_o = 1;
//     end
// end

