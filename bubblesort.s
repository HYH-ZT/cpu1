.data
    prompt:.asciiz "Enter the number of elements: "
    prompt_num:.asciiz "Enter number: "
    space:.asciiz " "
    newline:.asciiz "\n"
    array:.space 400  # 假设最多输入100个整数，每个整数4字节

.text
.globl main
main:
    # 提示用户输入元素个数
    li $v0, 4           # 4表示输出字符串？？？，这个就是lut？
    la $a0, prompt
    syscall

    # 读取元素个数
    li $v0, 5           # 5表示读取整数？？
    syscall
    move $s0, $v0  # $s0存储元素个数

    # 读取数字到数组
    la $t0, array
    read_loop:
        beq $s0, $zero, sort  # 如果个数为0，跳转到排序
        li $v0, 4
        la $a0, prompt_num
        syscall

        li $v0, 5
        syscall
        sw $v0, ($t0)
        addi $t0, $t0, 4
        addi $s0, $s0, -1
        j read_loop

    sort:
        la $t0, array
        add $s0, $s0, -1  # 外层循环次数为n - 1
        outer_loop:
            beq $s0, $zero, print_result
            add $t1, $t0, 0
            add $s1, $s0, 0
            inner_loop:
                beq $s1, $zero, update_outer
                lw $t2, ($t1)
                lw $t3, 4($t1)
                ble $t2, $t3, no_swap
                # 交换
                sw $t3, ($t1)
                sw $t2, 4($t1)
                no_swap:
                addi $t1, $t1, 4
                addi $s1, $s1, -1
                j inner_loop
            update_outer:
            addi $t0, $t0, 4
            addi $s0, $s0, -1
            j outer_loop

    print_result:
        la $t0, array
        li $s0, 0
        print_loop:
            lw $a0, ($t0)
            li $v0, 1
            syscall
            li $v0, 4
            la $a0, space
            syscall
            addi $t0, $t0, 4
            addi $s0, $s0, 1
            lw $t1, ($t0)
            beqz $t1, end_print
            j print_loop
        end_print:
        li $v0, 4
        la $a0, newline
        syscall
        # 程序结束
        li $v0, 10
        syscall