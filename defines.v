//本文件内为MISP_CPU项目的宏定义

//****************************  全局宏定义  **************************//
`define RstEnable           1'b1            //复位信号有效
`define RstDisable          1'b0            //复位信号无效
`define ZeroWord            32'h00000000    //32位数值0
`define WriteEnable         1'b1            //写使能
`define WriteDisable        1'b0            //写禁止
`define ReadEnable          1'b1            //读使能
`define ReadDisable         1'b0            //读禁止

`define AluOpBus            7:0             //译码阶段的输出aluop_o的数据宽度
`define AluSelBus           2:0             //译码阶段的输出alusel_o的数据宽度

`define InstValid           1'b0            //指令有效
`define InstInvalid         1'b1            //指令无效

`define True_df             1'b1            //逻辑真  ?
`define False_df            1'b0            //逻辑假
`define ChipEnable          1'b1            //芯片使能
`define ChipDisable         1'b0            //芯片禁止

`define Stop                1'b1            //暂停
`define NoStop              1'b0            //继续

//**************************    与跳转有关的宏定义    **********************//
`define JumpEnable          1'b1            //跳转使能
`define JumpDisable         1'b0            //跳转禁止

`define IsDelaySlot         1'b1            //是延迟槽
`define IsNotDelaySlot      1'b0            //不是延迟槽

//**************************    具体指令有关宏定义  **********************//
//指令码部分的宏定义(最前面6位)
`define EXE_SPECIAL_INST    6'b000000       //特殊指令码(包含基本逻辑运算)
`define EXE_SPECIAL2_INST   6'b011100       //特殊指令码2
`define EXE_NOP             6'b000000       //空操作nop指令码
`define EXE_PREF            6'b110011       //预取pref指令指令码            ?
`define EXE_REGIMM_INST     6'b000001

`define EXE_ANDI            6'b001100       //立即数与andi指令码
`define EXE_ORI             6'b001101       //立即数或ori指令码
`define EXE_XORI            6'b001110       //立即数异或xori指令码
`define EXE_LUT             6'b001111       //立即数保存lut指令码
//算术指令码
`define EXE_SLTI            6'b001010       //立即数有符号比较slti指令码
`define EXE_SLTIU           6'b001011       //立即数无符号比较sltiu指令码
`define EXE_ADDI            6'b001000       //立即数加法addi指令码
`define EXE_ADDIU           6'b001001       //立即数无溢出检查加法addiu指令码
//跳转指令码
`define EXE_J               6'b000010       //跳转指令码
`define EXE_JAL             6'b000011       //跳转并链接jal指令码

//功能码部分的宏定义(最后6位)
`define EXE_FUN_AND         6'b100100       //and指令功能码
`define EXE_FUN_OR          6'b100101       //or指令功能码
`define EXE_FUN_XOR         6'b100110       //xor指令功能码
`define EXE_FUN_NOR         6'b100111       //nor指令功能码

`define EXE_FUN_SLL         6'b000000       //逻辑左移sll指令功能码
`define EXE_FUN_SLLV        6'b000100       //逻辑左移sllv指令功能码
`define EXE_FUN_SRL         6'b000010       //逻辑右移srl指令功能码
`define EXE_FUN_SRLV        6'b000110       //逻辑右移srlv指令功能码
`define EXE_FUN_SRA         6'b000011       //算术右移sra指令功能码
`define EXE_FUN_SRAV        6'b000111       //算术右移srav指令功能码
`define EXE_FUN_SYNC        6'b001111       //同步sync指令功能码            ?
//算术功能码
`define EXE_FUN_SLT         6'b101010       //有符号比较运算slt指令功能码
`define EXE_FUN_SLTU        6'b101011       //无符号比较运算sltu指令功能码       
`define EXE_FUN_ADD         6'b100000       //加法运算add指令功能码
`define EXE_FUN_ADDU        6'b100001       //无溢出检查加法addu指令功能码
`define EXE_FUN_SUB         6'b100010       //减法运算sub指令功能码
`define EXE_FUN_SUBU        6'b100011       //无溢出检查减法subu指令功能码

`define EXE_FUN_CLZ         6'b100000       //0计数运算clz指令功能码
`define EXE_FUN_CLO         6'b100001       //1计数运算clo指令功能码

`define EXE_FUN_MULT        6'b011000       //乘法运算mult指令功能码
`define EXE_FUN_MULTU       6'b011001       //无符号乘法multu指令功能码
`define EXE_FUN_MUL         6'b000010       //乘法运算mul指令功能码
//跳转功能码
`define EXE_FUN_JR           6'b001000       //跳转指令功能码
`define EXE_FUN_JALR         6'b001001       //跳转并链接jal指令功能码

//**************************    与ALU有关的宏定义    **********************//
//ALUOP部分的宏定义
`define EXE_NOP_OP          8'b00000000     //?和SLL重复？
`define EXE_OR_OP           8'b00100101     //都是根据功能吗前加两个0构成
`define EXE_AND_OP          8'b00100100
`define EXE_XOR_OP          8'b00100110
`define EXE_NOR_OP          8'b00100111
`define EXE_SLL_OP          8'b00000000
`define EXE_SRL_OP          8'b00000010
`define EXE_SRA_OP          8'b00000011
`define EXE_JR_OP           8'b00001000
`define EXE_JALR_OP         8'b00001001

`define EXE_SLT_OP          8'b00101010       
`define EXE_SLTU_OP         8'b00101011             
`define EXE_ADD_OP          8'b00100000       
`define EXE_ADDU_OP         8'b00100001       
`define EXE_SUB_OP          8'b00100010       
`define EXE_SUBU_OP         8'b00100011       
`define EXE_ADDI_OP         8'b00001000       
`define EXE_ADDIU_OP        8'b00001001       

`define EXE_CLZ_OP          8'b00100000       
`define EXE_CLO_OP          8'b00100001       

`define EXE_MULT_OP         8'b00011000       
`define EXE_MULTU_OP        8'b00011001       
`define EXE_MUL_OP          8'b00000010
//ALUSEL部分的宏定义
`define EXE_RES_NOP         3'b000
`define EXE_RES_LOGIC       3'b001
`define EXE_RES_SHIFT       3'b010
`define EXE_RES_JUMP_BRANCH 3'b011          //可能和其他功能重复，需要改
`define EXE_RES_ARITHMETIC  3'b101
`define EXE_RES_MUL         3'b110



//**************************    与指令存储器ROM有关的宏定义     *****************//
`define InstAddrBus         31:0            //ROM的地址总线宽度
`define InstBus             31:0            //ROM的数据总线宽度(字长32 width)
`define InstMenNum          1023            //ROM的字数1023 (depth)
`define InstMemNumLog2      10              //ROM实际使用的地址线宽度

//*************************     与通用寄存器regs有关的宏定义    *******************//
`define RegAddrBus          4:0             //Regs模块的地址线宽度
`define RegBus              31:0            //regs模块的数据线宽度
`define RegWidth            32              //通用寄存器宽度
`define DoubleRegWidth      64              //两倍的通用寄存器的宽度
`define DoubleRegBus        63:0            //两倍的通用寄存器数据线宽度
`define RegNum              32              //通用寄存器数量
`define RegNumLog2          5               //通用寄存器使用的地址位数
`define NOPRegAddr          5'b00000        //

//*************************     与暂停流水线ctrl模块有关的宏定义    *******************//
`define StallBus            5:0             //暂停流水线的控制信号宽度
