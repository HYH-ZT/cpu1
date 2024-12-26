//���ļ���ΪMISP_CPU��Ŀ�ĺ궨��

//****************************  ȫ�ֺ궨��  **************************//
`define RstEnable           1'b1            //��λ�ź���Ч
`define RstDisable          1'b0            //��λ�ź���Ч
`define ZeroWord            32'h00000000    //32λ��ֵ0
`define WriteEnable         1'b1            //дʹ��
`define WriteDisable        1'b0            //д��ֹ
`define ReadEnable          1'b1            //��ʹ��
`define ReadDisable         1'b0            //����ֹ

`define AluOpBus            7:0             //����׶ε����aluop_o�����ݿ��
`define AluSelBus           2:0             //����׶ε����alusel_o�����ݿ��

`define InstValid           1'b0            //ָ����Ч
`define InstInvalid         1'b1            //ָ����Ч

`define True_df             1'b1            //�߼���  ?
`define False_df            1'b0            //�߼���
`define ChipEnable          1'b1            //оƬʹ��
`define ChipDisable         1'b0            //оƬ��ֹ

`define Stop                1'b1            //��ͣ
`define NoStop              1'b0            //����

//**************************    ����ת�йصĺ궨��    **********************//
`define JumpEnable          1'b1            //��תʹ��
`define JumpDisable         1'b0            //��ת��ֹ

`define IsDelaySlot         1'b1            //���ӳٲ�
`define IsNotDelaySlot      1'b0            //�����ӳٲ�

//**************************    ����ָ���йغ궨��  **********************//
//ָ���벿�ֵĺ궨��(��ǰ��6λ)
`define EXE_SPECIAL_INST    6'b000000       //����ָ����(���������߼�����)
`define EXE_SPECIAL2_INST   6'b011100       //����ָ����2
`define EXE_NOP             6'b000000       //�ղ���nopָ����
`define EXE_PREF            6'b110011       //Ԥȡprefָ��ָ����            ?
`define EXE_REGIMM_INST     6'b000001

`define EXE_ANDI            6'b001100       //��������andiָ����
`define EXE_ORI             6'b001101       //��������oriָ����
`define EXE_XORI            6'b001110       //���������xoriָ����
`define EXE_LUT             6'b001111       //����������lutָ����
//����ָ����
`define EXE_SLTI            6'b001010       //�������з��űȽ�sltiָ����
`define EXE_SLTIU           6'b001011       //�������޷��űȽ�sltiuָ����
`define EXE_ADDI            6'b001000       //�������ӷ�addiָ����
`define EXE_ADDIU           6'b001001       //��������������ӷ�addiuָ����
//��תָ����
`define EXE_J               6'b000010       //��תָ����
`define EXE_JAL             6'b000011       //��ת������jalָ����

//�����벿�ֵĺ궨��(���6λ)
`define EXE_FUN_AND         6'b100100       //andָ�����
`define EXE_FUN_OR          6'b100101       //orָ�����
`define EXE_FUN_XOR         6'b100110       //xorָ�����
`define EXE_FUN_NOR         6'b100111       //norָ�����

`define EXE_FUN_SLL         6'b000000       //�߼�����sllָ�����
`define EXE_FUN_SLLV        6'b000100       //�߼�����sllvָ�����
`define EXE_FUN_SRL         6'b000010       //�߼�����srlָ�����
`define EXE_FUN_SRLV        6'b000110       //�߼�����srlvָ�����
`define EXE_FUN_SRA         6'b000011       //��������sraָ�����
`define EXE_FUN_SRAV        6'b000111       //��������sravָ�����
`define EXE_FUN_SYNC        6'b001111       //ͬ��syncָ�����            ?
//����������
`define EXE_FUN_SLT         6'b101010       //�з��űȽ�����sltָ�����
`define EXE_FUN_SLTU        6'b101011       //�޷��űȽ�����sltuָ�����       
`define EXE_FUN_ADD         6'b100000       //�ӷ�����addָ�����
`define EXE_FUN_ADDU        6'b100001       //��������ӷ�adduָ�����
`define EXE_FUN_SUB         6'b100010       //��������subָ�����
`define EXE_FUN_SUBU        6'b100011       //�����������subuָ�����

`define EXE_FUN_CLZ         6'b100000       //0��������clzָ�����
`define EXE_FUN_CLO         6'b100001       //1��������cloָ�����

`define EXE_FUN_MULT        6'b011000       //�˷�����multָ�����
`define EXE_FUN_MULTU       6'b011001       //�޷��ų˷�multuָ�����
`define EXE_FUN_MUL         6'b000010       //�˷�����mulָ�����
//��ת������
`define EXE_FUN_JR           6'b001000       //��תָ�����
`define EXE_FUN_JALR         6'b001001       //��ת������jalָ�����

//**************************    ��ALU�йصĺ궨��    **********************//
//ALUOP���ֵĺ궨��
`define EXE_NOP_OP          8'b00000000     //?��SLL�ظ���
`define EXE_OR_OP           8'b00100101     //���Ǹ��ݹ�����ǰ������0����
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
//ALUSEL���ֵĺ궨��
`define EXE_RES_NOP         3'b000
`define EXE_RES_LOGIC       3'b001
`define EXE_RES_SHIFT       3'b010
`define EXE_RES_JUMP_BRANCH 3'b011          //���ܺ����������ظ�����Ҫ��
`define EXE_RES_ARITHMETIC  3'b101
`define EXE_RES_MUL         3'b110



//**************************    ��ָ��洢��ROM�йصĺ궨��     *****************//
`define InstAddrBus         31:0            //ROM�ĵ�ַ���߿��
`define InstBus             31:0            //ROM���������߿��(�ֳ�32 width)
`define InstMenNum          1023            //ROM������1023 (depth)
`define InstMemNumLog2      10              //ROMʵ��ʹ�õĵ�ַ�߿��

//*************************     ��ͨ�üĴ���regs�йصĺ궨��    *******************//
`define RegAddrBus          4:0             //Regsģ��ĵ�ַ�߿��
`define RegBus              31:0            //regsģ��������߿��
`define RegWidth            32              //ͨ�üĴ������
`define DoubleRegWidth      64              //������ͨ�üĴ����Ŀ��
`define DoubleRegBus        63:0            //������ͨ�üĴ��������߿��
`define RegNum              32              //ͨ�üĴ�������
`define RegNumLog2          5               //ͨ�üĴ���ʹ�õĵ�ַλ��
`define NOPRegAddr          5'b00000        //

//*************************     ����ͣ��ˮ��ctrlģ���йصĺ궨��    *******************//
`define StallBus            5:0             //��ͣ��ˮ�ߵĿ����źſ��
