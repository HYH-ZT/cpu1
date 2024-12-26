`include "defines.v"

module id( //���ܣ��ڸ�ָ������ͬʱ��ȡ�����������͸���һ��ִ�н׶�
    input rst,
    input wire[`InstAddrBus] pc_i,                      //����ĳ��������ֵ   ?����
    input wire[`InstBus] inst_i,                        //�����ָ��

    //�����ļĴ���ֵ
    input wire[`RegBus] rdata1_i,                     //�ӼĴ����ж�ȡ��������
    input wire[`RegBus] rdata2_i,

    //ִ�н׶�������
    input wire ex_we_reg_i,                             //��ʱִ�н׶�дʹ��
    input wire[`RegBus] ex_wdata_i,                     //��ʱִ�н׶�д����
    input wire[`RegAddrBus] ex_waddr_reg_i,             //��ʱִ�н׶�д��ַ

    //�ô�׶ν��
    input wire mem_we_reg_i,                            //��ʱ�ô�׶�дʹ��
    input wire[`RegBus] mem_wdata_i,                    //��ʱ�ô�׶�д����
    input wire[`RegAddrBus] mem_waddr_reg_i,            //��ʱ�ô�׶�д��ַ  //ʲô�ã�

    //��ǰ�Ƿ�Ϊ�ӳٲ�ָ��
    input wire now_in_delayslot_i,                      //��ǰ�Ƿ�Ϊ�ӳٲ�ָ��

    //<-in out->

    //���Ĵ����ѵĿ����ź�
    output reg[`RegAddrBus] raddr1_o,                    //�Ĵ�����ַ�����ڸ��߼Ĵ�������ȡ���е�����
    output reg[`RegAddrBus] raddr2_o,
    output reg re1_o,                    //���Ĵ����Ķ�ʹ���ź�
    output reg re2_o,

    //---����һ��ִ�н׶ε��ź�---
    //�����ź�
    output reg[`AluOpBus] aluop_o,                      //���������ͣ�ѡ�����Ȳ�����
    output reg[`AluSelBus] alusel_o,                    //�������ͣ�ѡ���߼����㣬��������
    //������������ź�
    output reg[`RegBus] rdata1_o,                         //������ݸ�ִ�н׶�
    output reg[`RegBus] rdata2_o,
    //�Ƿ�д�롢��д��Ĵ����ĵ�ַ���ź�
    output reg[`RegAddrBus] waddr_reg_o,                        //д��Ĵ����ĵ�ַ
    output reg we_reg_o,                                    //дʹ���źţ���ʾ�Ƿ���Ҫд��ļĴ���

    //��ȡָ�׶Σ�����ʵ����ת
    output reg branch_flag_o,                             //��תʹ��
    output reg[`InstAddrBus] branch_target_addr_o,         //��תĿ���ַ

    //������һ�׶���һ��ָ���Լ���ǰָ���Ƿ�Ϊ�ӳٲ�
    output reg next_in_delayslot_o,                         //��һ��ָ���Ƿ�Ϊ�ӳٲ�
    output reg now_in_delayslot_o,                          //��ǰָ���Ƿ�Ϊ�ӳٲ�

    //��ת�ɹ�����ܻ᷵�ص�ǰ��һ�����ĵ�ַ
    output reg [`InstAddrBus] return_addr_o,                 //����32λ�ĵ�ַ����Ĵ�����

    //��ͣ�����ź�
    output reg stallreq_upstream_o,                         //������ͣ�����ź�
    output reg stallreq_downstream_o                        //������ͣ�����ź�
    
);


//���룺������ָ��ָ�ɲ�ͬ�Ĳ��֣���Ϊ��ǣ��������ʹ��
wire [5:0] op;
wire [`RegAddrBus] rs, rt, rd;          //Դ��ַ�Ĵ�����Ŀ�ĵ�ַ�Ĵ���
wire [5:0] op_fun;                      //������
wire [15:0] op_imm;                     //������
wire [5:0] sa;                          //��λ��

assign op = inst_i[31:26];               //ָ���룬���ڹ涨ָ�������
assign rs = inst_i[25:21];               //I��ָ���Դ�Ĵ���
assign rt = inst_i[20:16];               //I��ָ���Ŀ�ļĴ�����R��ָ���Դ�Ĵ���
assign op_imm = inst_i[15:0];            //I��ָ���������

assign rd = inst_i[15:11];               //R��ָ���Ŀ�ļĴ���
assign op_fun = inst_i[5:0];             //R��ָ��Ĺ�����
assign sa = inst_i[10:6];                //R��ָ����λ���ܵ���λ��

wire [`InstAddrBus] pc_plus_1;
wire [`InstAddrBus] pc_plus_2;
assign pc_plus_1 = pc_i + 1;
assign pc_plus_2 = pc_i + 2;

reg instvalid;                          //ָʾָ���Ƿ���Ч
reg [`RegBus] imm;



always@(*) begin
    if(rst == `RstEnable) begin
        aluop_o = `EXE_NOP_OP;
        alusel_o = `EXE_RES_NOP;
        waddr_reg_o = `NOPRegAddr;
        we_reg_o = `WriteDisable;
        instvalid = `InstInvalid;
        re1_o = `ReadDisable;
        re2_o = `ReadDisable;
        raddr1_o = `NOPRegAddr;
        raddr2_o = `NOPRegAddr;
        imm = `ZeroWord;
        branch_flag_o = `JumpDisable;
        branch_target_addr_o = `NOPRegAddr;
        next_in_delayslot_o = `IsNotDelaySlot;
        stallreq_upstream_o = `NoStop;
    end
    
    //�ⲿ�ָ�Ĭ��ֵ, �൱�ڷ��ں����default���Ϊ����SPECIAL_INST��R��ָ�������
    else begin
        aluop_o = `EXE_NOP_OP;
        alusel_o = `EXE_RES_NOP;
        waddr_reg_o = rd;               //Ĭ��R��ָ��
        we_reg_o = `WriteDisable;
        instvalid = `InstInvalid;
        re1_o = `ReadDisable;
        re2_o = `ReadDisable;
        raddr1_o = `NOPRegAddr;
        raddr2_o = `NOPRegAddr;
        raddr1_o = rs;                  //Ĭ��R��ָ��
        raddr2_o = rt;                  //Ĭ��R��ָ��
        imm = `ZeroWord;
        branch_flag_o = `JumpDisable;
        branch_target_addr_o = `NOPRegAddr;
        next_in_delayslot_o = `IsNotDelaySlot;
        stallreq_upstream_o = `NoStop;

        case(op)
            `EXE_SPECIAL_INST: begin        //R��ָ��
                if(sa == 5'b00000) begin    //��sa(op2)Ϊ00000ʱ����ʾ�߼�����λv���ܻ���תָ��
                    instvalid = `InstValid;

                    case(op_fun)            //op_fun(op3)Ϊ������
                        `EXE_FUN_AND: begin
                            aluop_o = `EXE_AND_OP;
                            alusel_o = `EXE_RES_LOGIC;
                            we_reg_o = `WriteEnable;
                            re1_o = `ReadEnable;
                            re2_o = `ReadEnable;
                            // waddr_reg_o = rd;       //����Ҳͬ����Ҫ�ٸ�ֵ
                            // raddr1_o = rs;
                            // raddr2_o = rt;
                        end
                        `EXE_FUN_OR: begin
                            aluop_o = `EXE_OR_OP;
                            alusel_o = `EXE_RES_LOGIC;
                            we_reg_o = `WriteEnable;
                            re1_o = `ReadEnable;    
                            re2_o = `ReadEnable;    
                        end
                        `EXE_FUN_XOR: begin
                            aluop_o = `EXE_XOR_OP;
                            alusel_o = `EXE_RES_LOGIC;
                            we_reg_o = `WriteEnable;
                            re1_o = `ReadEnable;    
                            re2_o = `ReadEnable;   
                        end
                        `EXE_FUN_NOR: begin
                            aluop_o = `EXE_NOR_OP;
                            alusel_o = `EXE_RES_LOGIC;
                            we_reg_o = `WriteEnable;
                            re1_o = `ReadEnable;    
                            re2_o = `ReadEnable;   
                        end
                        `EXE_FUN_SLLV: begin
                            aluop_o = `EXE_SLL_OP;
                            alusel_o = `EXE_RES_SHIFT;
                            we_reg_o = `WriteEnable;
                            re1_o = `ReadEnable;    
                            re2_o = `ReadEnable;   
                        end
                        `EXE_FUN_SRLV: begin
                            aluop_o = `EXE_SRL_OP;
                            alusel_o = `EXE_RES_SHIFT;
                            we_reg_o = `WriteEnable;
                            re1_o = `ReadEnable;    
                            re2_o = `ReadEnable;   
                        end
                        `EXE_FUN_SRAV: begin
                            aluop_o = `EXE_SRA_OP;
                            alusel_o = `EXE_RES_SHIFT;
                            we_reg_o = `WriteEnable;
                            re1_o = `ReadEnable;    
                            re2_o = `ReadEnable;   
                        end
                        `EXE_FUN_SYNC: begin
                            we_reg_o = `WriteDisable;
                            aluop_o = `EXE_NOP_OP;
                            alusel_o = `EXE_RES_NOP;
                            re1_o = `ReadDisable;
                            re2_o = `ReadEnable;//?
                            raddr1_o = `NOPRegAddr;
                            raddr2_o = `NOPRegAddr;
                        end
                        //��ת
                        `EXE_FUN_JR: begin
                            we_reg_o = `WriteDisable;   //����Ĵ���д���ݣ�ֻ����תָ����
                            aluop_o = `EXE_JR_OP;
                            alusel_o = `EXE_RES_JUMP_BRANCH;
                            re1_o = `ReadEnable;
                            re2_o = `ReadDisable;
                            raddr1_o = rs;
                            raddr2_o = `NOPRegAddr;

                            branch_flag_o = `JumpEnable;
                            branch_target_addr_o = rdata1_o;     //��תĿ���ַ��������rdata1_o������rdata1_i�����Խ������ָ�������ݳ�ͻ?
                            next_in_delayslot_o = `IsDelaySlot;
                            return_addr_o = `ZeroWord;
                            instvalid = `InstValid;
                            stallreq_upstream_o = `Stop;
                        end
                        `EXE_FUN_JALR: begin
                            we_reg_o = `WriteEnable;
                            aluop_o = `EXE_JALR_OP;
                            alusel_o = `EXE_RES_JUMP_BRANCH;
                            re1_o = `ReadEnable;
                            re2_o = `ReadDisable;
                            raddr1_o = rs;
                            raddr2_o = `NOPRegAddr;
                            waddr_reg_o = rd != 5'b00000 ? rd : 5'd31; //rdΪ0ʱ��д��31�żĴ���

                            branch_flag_o = `JumpEnable;
                            branch_target_addr_o = rdata1_o;
                            next_in_delayslot_o = `IsDelaySlot;
                            return_addr_o = pc_plus_1;
                            instvalid = `InstValid;
                            stallreq_upstream_o = `Stop;
                        end
                        //����
                        `EXE_FUN_SLT: begin
                        we_reg_o = `WriteEnable;
                        aluop_o = `EXE_SLT_OP;
                        alusel_o = `EXE_RES_ARITHMETIC;
                        re1_o = `ReadEnable;
                        re2_o = `ReadEnable;
                        instvalid = `InstValid;
                        end
                        `EXE_FUN_SLTU: begin
                            we_reg_o = `WriteEnable;
                            aluop_o = `EXE_SLTU_OP;
                            alusel_o = `EXE_RES_ARITHMETIC;
                            re1_o = `ReadEnable;
                            re2_o = `ReadEnable;
                            instvalid = `InstValid;
                        end
                        `EXE_FUN_ADD: begin
                            we_reg_o = `WriteEnable;
                            aluop_o = `EXE_ADD_OP;
                            alusel_o = `EXE_RES_ARITHMETIC;
                            re1_o = `ReadEnable;
                            re2_o = `ReadEnable;
                            instvalid = `InstValid;
                        end
                        `EXE_FUN_ADDU: begin
                            we_reg_o = `WriteEnable;
                            aluop_o = `EXE_ADDU_OP;
                            alusel_o = `EXE_RES_ARITHMETIC;
                            re1_o = `ReadEnable;
                            re2_o = `ReadEnable;
                            instvalid = `InstValid;
                        end
                        `EXE_FUN_SUB: begin
                            we_reg_o = `WriteEnable;
                            aluop_o = `EXE_SUB_OP;
                            alusel_o = `EXE_RES_ARITHMETIC;
                            re1_o = `ReadEnable;
                            re2_o = `ReadEnable;
                            instvalid = `InstValid;
                        end
                        `EXE_FUN_SUBU: begin
                            we_reg_o = `WriteEnable;
                            aluop_o = `EXE_SUBU_OP;
                            alusel_o = `EXE_RES_ARITHMETIC;
                            re1_o = `ReadEnable;
                            re2_o = `ReadEnable;
                            instvalid = `InstValid;
                        end
                        `EXE_FUN_MULT: begin
                            we_reg_o = `WriteDisable;
                            aluop_o = `EXE_MULT_OP;
                            re1_o = `ReadEnable;
                            re2_o = `ReadEnable;
                            instvalid = `InstValid;
                        end
                        `EXE_FUN_MULTU: begin
                            we_reg_o = `WriteDisable;
                            aluop_o = `EXE_MULTU_OP;
                            re1_o = `ReadEnable;
                            re2_o = `ReadEnable;
                            instvalid = `InstValid;
                        end

                        default: begin
                        end
                    endcase
                end
                else if(rs == 5'b00000)begin                   //��sa��Ϊ00000ʱ����ʾ��λ(��v)���� ������waddr_reg_o��Ҫ��
                    case(op_fun)
                        `EXE_FUN_SLL: begin
                            aluop_o = `EXE_SLL_OP;
                            alusel_o = `EXE_RES_SHIFT;
                            re1_o = `ReadEnable;
                            re2_o = `ReadDisable;
                            instvalid = `InstValid;
                        end
                        `EXE_FUN_SRL: begin
                            aluop_o = `EXE_SRL_OP;
                            alusel_o = `EXE_RES_SHIFT;
                            re1_o = `ReadEnable;
                            re2_o = `ReadDisable;
                            instvalid = `InstValid;
                        end
                        `EXE_FUN_SRA: begin
                            aluop_o = `EXE_SRA_OP;
                            alusel_o = `EXE_RES_SHIFT;
                            re1_o = `ReadEnable;
                            re2_o = `ReadDisable;
                            instvalid = `InstValid;
                        end
                        default: begin
                        end
                    endcase
                end
                else begin
                end
            end
            `EXE_ORI: begin
                we_reg_o = `WriteEnable;
                aluop_o = `EXE_OR_OP;               //ע�����������`EXE_OR_OP��`EXE_ORI��ָ�
                alusel_o = `EXE_RES_LOGIC;
                re1_o = `ReadEnable;
                re2_o = `ReadDisable;
                raddr1_o = rs;
                raddr2_o = `NOPRegAddr;
                imm = {16'h0000, op_imm};           //������,�޷�����չ
                waddr_reg_o = rt;
                instvalid = `InstValid;
            end
            `EXE_ANDI: begin                           //��������
                we_reg_o = `WriteEnable;
                aluop_o = `EXE_AND_OP;
                alusel_o = `EXE_RES_LOGIC;
                re1_o = `ReadEnable;
                re2_o = `ReadDisable;
                raddr1_o = rs;
                raddr2_o = `NOPRegAddr;
                imm = {16'h0000, op_imm};      //������,�޷�����չ
                waddr_reg_o = rt;
                instvalid = `InstValid;
            end
            `EXE_XORI: begin                           //���������
                we_reg_o = `WriteEnable;
                aluop_o = `EXE_XOR_OP;
                alusel_o = `EXE_RES_LOGIC;
                re1_o = `ReadEnable;
                re2_o = `ReadDisable;
                raddr1_o = rs;
                raddr2_o = `NOPRegAddr;
                imm = {16'h0000, op_imm};      //������,�޷�����չ
                waddr_reg_o = rt;
                instvalid = `InstValid;
            end
            `EXE_LUT: begin                    //����������
                we_reg_o = `WriteEnable;
                aluop_o = `EXE_OR_OP;
                alusel_o = `EXE_RES_LOGIC;
                re1_o = `ReadDisable;
                re2_o = `ReadDisable;
                raddr1_o = `NOPRegAddr;
                raddr2_o = `NOPRegAddr;
                imm = {op_imm, 16'h0000};      //������,�޷�����չ
                waddr_reg_o = rt;
                instvalid = `InstValid;
            end
            `EXE_PREF: begin                            //Ԥȡָ��,�ڱ���Ŀ���޻��棬��������
                we_reg_o = `WriteEnable;
                aluop_o = `EXE_NOP_OP;
                alusel_o = `EXE_RES_NOP;
                re1_o = `ReadDisable;
                re2_o = `ReadDisable;
                waddr_reg_o = `NOPRegAddr;
                instvalid = `InstValid;
            end

            `EXE_J: begin
                we_reg_o = `WriteDisable;
                aluop_o = `EXE_JR_OP;
                alusel_o = `EXE_RES_JUMP_BRANCH;
                re1_o = `ReadDisable;
                re2_o = `ReadDisable;
                // raddr1_o = `NOPRegAddr;  //���Բ�д
                // raddr2_o = `NOPRegAddr;
                // waddr_reg_o = `NOPRegAddr;
                
                branch_flag_o = `JumpEnable;
                branch_target_addr_o = {6'b000000, inst_i[25:0]}; //��תĿ���ַ
                // branch_target_addr_o = {pc_plus_1[31:28], inst_i[25:0], 2'b00}; //��תĿ���ַ
                next_in_delayslot_o = `IsDelaySlot;
                return_addr_o = `ZeroWord;
                instvalid = `InstValid;
                stallreq_upstream_o = `Stop;
            end
            `EXE_JAL: begin
                we_reg_o = `WriteEnable;
                aluop_o = `EXE_JALR_OP;
                alusel_o = `EXE_RES_JUMP_BRANCH;
                re1_o = `ReadDisable;
                re2_o = `ReadDisable;
                waddr_reg_o = 5'd31; //д��31�żĴ���
                
                branch_flag_o = `JumpEnable;
                branch_target_addr_o = {6'b000000, inst_i[25:0]}; //��תĿ���ַ
                next_in_delayslot_o = `IsDelaySlot;
                return_addr_o = pc_plus_1;
                instvalid = `InstValid;
                stallreq_upstream_o = `Stop;
            end
            `EXE_SLTI: begin
                we_reg_o = `WriteEnable;
                aluop_o = `EXE_SLT_OP;
                alusel_o = `EXE_RES_ARITHMETIC;
                re1_o = `ReadEnable;
                re2_o = `ReadDisable;
                imm = {{16{inst_i[15]}}, inst_i[15:0]};
                waddr_reg_o = inst_i[20:16];
                instvalid = `InstValid;
            end
            `EXE_SLTI: begin
                we_reg_o = `WriteEnable;
                aluop_o = `EXE_SLTU_OP;
                alusel_o = `EXE_RES_ARITHMETIC;
                re1_o = `ReadEnable;
                re2_o = `ReadDisable;
                imm = {{16{inst_i[15]}}, inst_i[15:0]};
                waddr_reg_o = inst_i[20:16];
                instvalid = `InstValid;
            end
            `EXE_ADDI: begin
                we_reg_o = `WriteEnable;
                aluop_o = `EXE_ADDI_OP;
                alusel_o = `EXE_RES_ARITHMETIC;
                re1_o = `ReadEnable;
                re2_o = `ReadDisable;
                imm = {{16{inst_i[15]}}, inst_i[15:0]};
                waddr_reg_o = inst_i[20:16];
                instvalid = `InstValid;
            end
            `EXE_ADDIU: begin
                we_reg_o = `WriteEnable;
                aluop_o = `EXE_ADDIU_OP;
                alusel_o = `EXE_RES_ARITHMETIC;
                re1_o = `ReadEnable;
                re2_o = `ReadDisable;
                imm = {{16{inst_i[15]}}, inst_i[15:0]};
                waddr_reg_o = inst_i[20:16];
                instvalid = `InstValid;
            end
            `EXE_SPECIAL2_INST: begin                   //special2ָ����
                case(op_fun)
                    `EXE_FUN_CLZ: begin
                        we_reg_o = `WriteEnable;
                        aluop_o = `EXE_CLZ_OP;
                        alusel_o = `EXE_RES_ARITHMETIC;
                        re1_o = `ReadEnable;
                        re2_o = `ReadDisable;
                        instvalid = `InstValid;
                    end
                    `EXE_FUN_CLO: begin
                        we_reg_o = `WriteEnable;
                        aluop_o = `EXE_CLO_OP;
                        alusel_o = `EXE_RES_ARITHMETIC;
                        re1_o = `ReadEnable;
                        re2_o = `ReadDisable;
                        instvalid = `InstValid;
                    end
                    `EXE_FUN_MUL: begin
                        we_reg_o = `WriteEnable;
                        aluop_o = `EXE_MUL_OP;
                        alusel_o = `EXE_RES_MUL;
                        re1_o = `ReadEnable;
                        re2_o = `ReadEnable;
                        instvalid = `InstValid;
                    end
                    default: begin 
                    end
                endcase 
            end
            default: begin end
        endcase
    end //end of else
end //end of always

//****************************************************************//
//**************************ȷ��������1****************************//
//****************************************************************//

always@(*) begin
    if(rst == `RstEnable) begin
        rdata1_o = `ZeroWord;
    end
    else if (re1_o == `ReadEnable && ex_we_reg_i == `WriteEnable && ex_waddr_reg_i == raddr1_o)begin
        rdata1_o = ex_wdata_i;
    end
    else if (re1_o == `ReadEnable && mem_we_reg_i == `WriteEnable && mem_waddr_reg_i == raddr1_o)begin
        rdata1_o = mem_wdata_i;
    end
    else if (re1_o == `ReadEnable) begin
        rdata1_o = rdata1_i;
    end
    else if (re1_o == `ReadDisable) begin
        rdata1_o = imm;
    end
    else begin                                      //��ʵ�����Ѿ���������������������else�Ƕ����
        rdata1_o = `ZeroWord;
    end
end

//****************************************************************//
//**************************ȷ��������2****************************//
//****************************************************************//

always@(*) begin
    if(rst == `RstEnable) begin
        rdata2_o = `ZeroWord;
    end
    else if (re2_o == `ReadEnable && ex_we_reg_i == `WriteEnable && ex_waddr_reg_i == raddr2_o)begin
        rdata2_o = ex_wdata_i;
    end
    else if (re2_o == `ReadEnable && mem_we_reg_i == `WriteEnable && mem_waddr_reg_i == raddr2_o)begin
        rdata2_o = mem_wdata_i;
    end
    else if (re2_o == `ReadEnable) begin
        rdata2_o = rdata2_i;
    end
    else if (re2_o == `ReadDisable) begin
        rdata2_o = imm;
    end
    else begin                                      //��ʵ�����Ѿ���������������������else�Ƕ����
        rdata2_o = `ZeroWord;
    end
end

//ȷ����ǰ����׶ε�ָ���Ƿ�Ϊ�ӳٲ�ָ��
always @(*)begin
    if(rst == `RstEnable)begin
        now_in_delayslot_o = `IsNotDelaySlot;
    end
    else begin
        now_in_delayslot_o = `IsDelaySlot;
    end
end

//��ͣ���ε������ź�
always @(*)begin
    if(rst == `RstEnable)begin
        stallreq_downstream_o = `NoStop;
    end
    else begin
        stallreq_downstream_o = `NoStop;
    end
end

endmodule