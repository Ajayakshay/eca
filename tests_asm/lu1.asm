    addi t0, x0, 692
    addi t1, x0, 21
    sw   t1, 0(x0)
    addi t2, x0, 7
    sw   t2, 4(x0)
    lw   t3, 0(x0)
    add  t4, t3, t3
    sw   t4, 0(t0)
    lw   t3, 0(x0)
    add  t4, t2, t3
    sw   t4, 4(t0)
    lw   t3, 0(x0)
    addi t5, x0, 1
    add  t4, t3, t5
    sw   t4, 8(t0)
    lw   t3, 0(x0)
    nop
    nop
    add  t4, t3, t3
    sw   t4, 12(t0)
    lw   t3, 0(x0)
    sw   t3, 16(t0)
    addi t1, x0, 4
    sw   t1, 8(x0)
    lw   t3, 8(x0)
    lw   t4, 0(t3)
    sw   t4, 20(t0)
    addi t5, x0, 7
    lw   t3, 4(x0)
    bne  t3, t5, BAD
    addi t6, x0, 1
    j    DONE7
BAD:
    addi t6, x0, 99
DONE7:
    sw   t6, 24(t0)
    addi t1, x0, 1
    add  t1, t1, t1
    add  t1, t1, t1
    add  t1, t1, t1
    sw   t1, 28(t0)
    ret
