![[Pasted image 20241209203125.png]]![[Pasted image 20241209214919.png]]
第六章
![[Pasted image 20241209230516.png]]
![[Pasted image 20241209230429.png]]
![[Pasted image 20241209230402.png]]

修改：
![[Pasted image 20241209231220.png]]
之后：
![[Pasted image 20241209231205.png]]

还是对不上是因为未完成数据冲突的解决

避开数据冲突仿真试试看：
![[Pasted image 20241209232508.png]]
![[Pasted image 20241209232528.png]]
这里[2]还是有问题，应该是01011100
这里[5]也有问题，95ns后应该是01010101

（另外注意运算的指令与汇编语言中rs和rt的顺序是反过来的）


数据冲突解决：
利用数据前推：推至id译码阶段
![[Pasted image 20241211110135.png]]

# 12.16 上午 数据前推仿真：
衔接上次的仿真
![[Pasted image 20241209232508.png]]

![[Pasted image 20241216091159.png]]
可见加上数据冲突解决之后[2]正常了，但是【5】还有问题，95ns后应为01010101可能运算时是落了几位？？==（下面数据冲突解决后这个问题也解决了可见是l1和l3的指令冲突导致）==

按照书上115页仿真测试数据冲突处理效果：
![[Pasted image 20241216093139.png]]

![[Pasted image 20241216093133.png]]
可见还是只能处理相隔2个指令时的两个指令才没有冲突（上图中第一条和第四条不冲突，1,2冲突，1,3冲突）

因为只是id模块改了，但顶层模块没有改（未添加新的输入变量）！！这里注意，因为书上仿真是仿真检验一个小模块，而我自己仿真是检验整体，所以顶层模块要记得修改！

==下面统一规定vivado仿真总时间设置为140ns，指令不能超过6条（20ns一条指令）==

修改顶层模块后成功，结果如下：
![[Pasted image 20241216094113.png]]

冲突解决后再回来仿真
![[Pasted image 20241209232508.png]]
![[Pasted image 20241216094546.png]]
问题解决！开心

进一步按书上测试了第五章的逻辑运算功能
![[Pasted image 20241216100743.png]]
![[Pasted image 20241216100708.png]]
移位功能和空指令还没检验


# 把pc指令+1无需改为+4的说明：
改之前，blkip核参数设置为
![[Pasted image 20241216164148.png]]

没有问题。

需要将width从32改成8，有问题，而代码中一系列的inst[31:0]都需要改，不如直接用32位的储存单元（4字节）。

数据宽度width：addr[31:0]表示32位宽。
ram的每一个存储单元都有32位

深度depth：表示ram中有1023个存储单元

就像挖井，挖好后的空间被分层很多层用来填垃圾。width就是每一层（一个存储单元）多宽，depth就是存储单元的个数，井越深存储单元越多。

# 跳转指令仿真
```assembly language
ori $4,$0,0x0001
j label1
ori $4,$0,0x0002
ori $4,$0,0x1111
ori $4,$0,0x1100

label1:
ori $4,$0,0x0003
jal label2
div $zero, $31, $4

ori $4, $0, 0x0005
ori $4, $0, 0x0006
j label3
nop

label2:
jalr $2, $31
or $4, $2, $0
ori $4, $0, 0x0009
ori $4, $0, 0x000a
j labelnop
nop

label3:
ori $4, $0, 0x0007
jr $2
ori $4, $0, 0x0008
ori $4, $0, 0x1111
ori $4, $0, 0x1100

labelnop:
nop
```
太复杂，简化后：（除法还没实现，换成ori $5, $0, 0x0101)

```
ori $4,$0,0x0001    //1
j label1
ori $4,$0,0x0002    //2(delayslot)
ori $4,$0,0x1111
ori $4,$0,0x1100

label1:
ori $4,$0,0x0003    //3
jal label2
ori $5, $0, 0x0101  //4

ori $4, $0, 0x0005  //6
ori $4, $0, 0x0006  //7
j label3
nop

label2:
jalr $2, $31        
or $4, $2, $0       //5

ori $4, $0, 0x0009  //10

label3:
ori $4, $0, 0x0007  //8
jr $2
ori $4, $0, 0x0008  //9
ori $4, $0, 0x1111
ori $4, $0, 0x1100

labelnop:
nop
```
结果
![[Pasted image 20241216185400.png]]

这里pc前面28位是高阻，最后四位成功传递，是因为传递过程中topmodule中用于传递值的变量错误设成了4位，所以前面28位没传过去
调试方法：列出过程中涉及到的所有变量，如果是变量位数设置错误不用仿真直接从名字后带的位数就可以看出来

再改简单点
```
ori $4,$0,0x0001    //1
j label1
ori $4,$0,0x0002    //2(delayslot)
ori $4,$0,0x1111
ori $4,$0,0x1100

label1:
ori $4,$0,0x0003    //3
```

第二行机器码翻译成08000006
则结果：
![[Pasted image 20241216212101.png]]
设成10进制
![[Pasted image 20241216212207.png]]
好奇怪，为什么j语句要设置这么一个奇怪的算法
branch_target_addr_o = {pc_plus_1[31:28], inst_i[25:0], 2'b00}
有什么意义？

下面先去仿真jr，然后做分支
# jr和jalr仿真
```
1 ori $4,$0,0x0006 //1
2 jr  $4 //2
3 ori $4,$0,0x0002 //3
4 ori $4,$0,0x1111
5 ori $4,$0,0x1100

6 ori $4,$0,0x0003 //4
```

![[Pasted image 20241216213458.png]]
黄线处pc应为6，但为0错误
![[Pasted image 20241216214726.jpg]]
问题1 delay槽后面又多走了两步--仔细分析发现pc值的跳转没有问题，是后面ex给reg赋值出问题
问题2 相邻指令的数据冲突？--这里没有这个问题，只是因为0表示第1条指令，所以差一个1

![[Pasted image 20241216220458.png]]

这里让pc赋值为$1中的值，即为0，这样运行到jr程序就又会从头开始
![[Pasted image 20241216222045.png]]

下面仿真：
```
ori $4,$0,0x0001
ori $4,$0,0x0009
jr  $4
ori $4,$0,0x0002
ori $4,$0,0x1111
ori $4,$0,0x1100
ori $4,$0,0x0003
ori $4,$0,0x0004
ori $4,$0,0x0005
ori $4,$0,0x0006
```
![[Pasted image 20241216225313.png]]
![[Pasted image 20241216225253.png]]
得出结论：
delay槽后面又多走了两步--仔细分析发现pc值的跳转没有问题，是后面ex给reg赋值出问题

下面改成jalr，能够引入更多中间量，再配合now_is_delayslip?更清楚
# 转阵jalr仿真，更多细节

![[Pasted image 20241216233612.png]]
```
34040001
34040009
00801009
34040002
34041111
34041100
34040003
34040004
34040005
34040006
```
注意这里jalr用QtSpim在rs和rd位置上有问题，需要自己汇编转机器码
经过一番调试后终于在reg2中得到pc+2的结果 pc=4时跳转，reg2 = 6

![[Pasted image 20241216233737.png]]

用reg作为仿真结果不够实时性，在分析和CLK以及pc的延时时比较麻烦，之后改为用id输出的操作数和regs共同作为输出结果

# 延迟槽技术的劣势
![[Pasted image 20241217113219.png]]

# 下面不要采用延迟槽
之前参考书太多了，下面主要跟自己的思路和理解做。

若取指暂停，译码不暂停，输出空指令?
会==什么都不做==（目标）还是输出第一条指令？

# 加暂停的jalr调试

当rom_addr_i = 1，下一时钟周期rom_data_o就会输出第一条指令，经过一个周期的if_id模块取指过程，再下一个时钟周期id_inst会是第一条指令

修改1：在if/id模块加pc_temp，将pc延迟（缓冲）一个时钟周期
![[Pasted image 20241217151126.png]]![[Pasted image 20241217151133.png]]
![[Pasted image 20241217151038.png]]这样if/id输出的第一条指令id_inst=34040001和其地址id_pc=1就对上了，不会错开一个时钟周期到达id模块

但是if/id被暂停时这个pc的一个延时也会被暂停，下面改到外面防止它被暂停

破案了：（这时候还是假的恍然大悟）
rom的问题：
延迟的两个周期中
![[Pasted image 20241217161734.png]]
输出的信号中其中![[Pasted image 20241217161913.png]]

（下面可能是真的恍然大悟）
rom初始化时rst时间太短，导致有rom模块有2T的延迟（实际上这2T中只包含一个时钟沿）


单独对rom模块仿真：
![[Pasted image 20241217163935.png]]
对tb稍作改动：
![[Pasted image 20241217164145.png]]

可见==我们写的第一条语句对应的pc地址是0==。

rst拉长后再次仿真
![[Pasted image 20241217164526.png]]
可见上面还是假的黄蓉大物
是因为在rom中加载的。。。

是给rom的使能信号ce的问题？

==（后面要想在停的时候读空指令也可以关掉ce）==
果然！！（后面说明这个解释好像也是错的）
![[Pasted image 20241217170443.png]]

解决：先将ce改成随着rst异步变化，而非同步跟随clk变化（失败）

解决另：像这个图一样
![[Pasted image 20241217164145.png]]
设置ena（rom_ce）先拉高，比addr变成1要早很多
补充代码：
```
reg ce_delay;                       //给pc用的使能信号（相对rom_program模块的使能信号有一个周期的延迟）

//指令存储器ce
always @(posedge clk) begin
    if(rst == `RstEnable) begin
        ce <= `ChipDisable;                     //复位的时候指令存储器禁用
    end
    else begin
        ce <= `ChipEnable;                      //复位结束使能
    end
end

always @(posedge clk) begin
        ce_delay <= ce;
end

//pc程序计数器
always@(posedge clk) begin
    if(ce_delay == `ChipDisable) begin
        pc <= `ZeroWord;                        //复位时，pc归零
    end
    else if(branch_flag_i == `JumpEnable)begin
        pc <= branch_target_addr_i;             //跳转时，pc赋值为跳转目标地址
    end
    else if(stall[0] == `Stop)begin
        if(stall[1] == `NoStop)begin
            pc <= pc;
        end
        else begin
            pc <= pc;
        end
    end
    else begin
        pc <= pc + 1;                           //正常工作时，时钟有效沿到来pc+4
    end
end
```
![[Pasted image 20241217172146.png]]

综上所述：应该就是rom有两个延迟的原因。

![[Pasted image 20241217173519.png]]

更改pc_reg:
```
//pc程序计数器
always@(posedge clk) begin
    if(ce == `ChipDisable) begin
        pc <= `ZeroWord;                        //复位时，pc归零
    end
    else if(branch_flag_i == `JumpEnable)begin
        pc <= branch_target_addr_i;             //跳转时，pc赋值为跳转目标地址
    end
    else if(stall[0] == `Stop || stall_delay[0] ==`Stop)begin            //这里如果想要像ex_mem模块一样，输出空指令，不是将pc改为`ZeroWord（这样会输出第一条指令），而是需要对ce赋值，让rom_program模块输出空指令[[[[这里改动增加了|| stall_delay[0] ==`Stop]]]]
        pc <= pc;
    end
    else begin
        pc <= pc + 1;                           //正常工作时，时钟有效沿到来pc+4
    end
end

```
结果：
![[Pasted image 20241217202045.png]]
说明不对，利用git的阅读历史记录去吸取之前的想法：模仿之前清除紧随其后第一条指令取指的操作，来清除jump后面第二条指令的取指
发现不是改pc_reg.v，而是改if/id模块
改后：
![[Pasted image 20241217203015.png]]
成功啦！！（虽然延时了2个周期，比预想的长了一个周期）

# 补充jalr, jr, j, jal后仿真
再对下面仿真：（对原始代码做修改，由于汇编器把label对应错误，就将计就计）
```asm
ori $4,$0,0x0001    //1
j label1            //2
ori $4,$0,0x0002
ori $4,$0,0x1111
ori $4,$0,0x1100
label1:ori $4,$0,0x0003 //3
jal label2          //4
ori $5, $0, 0x0101  //6 
ori $4, $0, 0x0005  //7
ori $4, $0, 0x0006  //8
j label3            //9
nop
label2:jalr $2, $31 //5？
or $4, $2, $0
ori $4, $0, 0x0009
label3:ori $4, $0, 0x0007//10
jr $2
ori $4, $0, 0x0008
ori $4, $0, 0x1111
ori $4, $0, 0x1100
labelnop:nop
```
```
34040001
08000005
34040002
34041111
34041100
34040003
0c00000c
34050101
34040005
34040006
0800000f
00000000
03e01009
00402025
34040009
34040007
00400008
34040008
34041111
34041100
00000000
```
结果：
![[Pasted image 20241218153932.png]]
![[Pasted image 20241218154001.png]]
再后面都是重复循环的
jalr用QtSpim在rs和rd位置上有问题，需要自己汇编转机器码

注意这里分析代码的行为时, 第17条和第13条语句译码时产生的rdata1_o是赋给target_addr给pc而不会向后传递给ex和回写到寄存器里，因为写使能关闭

成功！
# 仿真检验branch
豆包：
$t0:$8
$t1:$9
```
.text
.globl main
main:
    li $t0, 5       # 将5加载到$t0寄存器
    li $t1, 5       # 将5加载到$t1寄存器
    beq $t0, $t1, equal_label   # 如果$t0等于$t1，跳转到equal_label
    j not_equal_label        # 如果不相等，跳转到not_equal_label

equal_label:
    li $v0, 1       # 准备打印整数
    li $a0, 1       # 要打印的值为1，表示相等
    syscall         # 调用系统调用进行打印
    j exit          # 跳转到退出程序

not_equal_label:
    li $v0, 1       # 准备打印整数
    li $a0, 0       # 要打印的值为0，表示不相等
    syscall         # 调用系统调用进行打印
    j exit          # 跳转到退出程序

exit:
    li $v0, 10      # 退出程序的系统调用
    syscall
```
化简后：
```
.text
.globl main
main:
    lui $t0, 5
    lui $t1, 5
    beq $t0, $t1, equal_label
    j not_equal_label

equal_label:
    ori $2, $0, 0x0005
    j exit

not_equal_label:
    ori $3, $0, 0x0005
    j exit

exit:
    ori $4, $0, 0x0005
```
```
3c080005
3c090005
11090002
08000006
34020005
08000008
34030005
08000008
34040005
```

其中
```
beq $t0, $t1, equal_label
j not_equal_label
```
两句实现了if，else的功能

结果：
![[Pasted image 20241218162200.png]]
有问题：beq处跳转的pc不要plus1！

将cpu停下？如何判断？
更改后：成功
![[Pasted image 20241218163042.png]]

### 收获与心得：
总结很重要，像这样写日志，个人感觉是一个很好的做法，能够清除分析出来问题出在哪里，尽管可能无法第一时间马上就修复bug，但是这个修复bug的过程才是最重要的，让自己的工程能力有所提升。在积累问题的过程中会越来越熟练，累积经验，从而对各种问题敏感，也知道自己容易出错在哪里（比如我就是定义变量时位数不注意），以后更注意不易犯错，增加效率。

### 仿真心得：
- debug时候尽量把更多可能的嫌疑人都加入仿真，这样不用自己脑子想，增加自己的记忆负担，转成体力活。特别是时间差一个时钟周期的D触发器两端的信号，很有可能就数时钟输错，还降低效率。
- 重要的量标颜色，花花绿绿真好看
- 观察结果的选取：不一定最终的结果如reg，可以是中间变量如data1_o。（当然最终结果最好也要有）

### 下面的都可以问AI：
- 看不懂的，不理解的代码
- 各种体力劳动，重复性的工作，比cv要更快。
- 不懂的新概念
- 写检验程序：自己想真的很耗时间

# RAM加载

