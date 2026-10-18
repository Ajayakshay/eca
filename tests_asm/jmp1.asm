    addi t0, x0, 692
    addi t4, x0, 0
    j    L1
    addi t4, x0, 99
    addi t4, x0, 98
L1: sw   t4, 0(t0)
    addi t5, x0, 0
    jal  ra, F
    addi t5, t5, 100
    sw   t5, 4(t0)
    sw   x0, 8(t0)
    addi ra, x0, 0
    j    END
    addi t4, x0, 55
END:
    ret
F:  addi t5, t5, 7
    ret
