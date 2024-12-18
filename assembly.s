main:    lui $t0, 5
    lui $t1, 5
    beq $t0, $t1, equal_label
    j not_equal_label
equal_label:    ori $2, $0, 0x0005
    j exit
not_equal_label:    ori $3, $0, 0x0005
    j exit
exit:    ori $4, $0, 0x0005