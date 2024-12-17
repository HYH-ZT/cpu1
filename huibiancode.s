ori $4,$0,0x0001    //1
j label1            //2
ori $4,$0,0x0002
ori $4,$0,0x1111
ori $4,$0,0x1100
label1:ori $4,$0,0x0003 //3
jal label2          //4
ori $5, $0, 0x0101
ori $4, $0, 0x0005
ori $4, $0, 0x0006
j label3
nop
label2:jalr $2, $31 //5
or $4, $2, $0
ori $4, $0, 0x0009
label3:ori $4, $0, 0x0007
jr $2
ori $4, $0, 0x0008
ori $4, $0, 0x1111
ori $4, $0, 0x1100
labelnop:nop