# 2D convolution: 13x13 input (signed 32-bit) with 2x2 kernel -> 11x11 output
#
# Memory layout (word-addressed RAM, each word = 4 bytes):
#   [0..168]   input matrix  (row-major, 13 cols)
#   [169..172] kernel        (row-major: k[0][0] k[0][1] k[1][0] k[1][1])
#   [173..293] output        (row-major, 11 cols)

convolution:
    addi    a0,     x0,     0       # input  base byte address = 0
    addi    a1,     x0,     676     # kernel base byte address = 169*4
    addi    a2,     x0,     692     # output base byte address = 173*4
    addi    s1,     x0,     0       # i = 0

for_i_loop:
    addi    s2,     x0,     0       # j = 0

for_j_loop:
    addi    s3,     x0,     0       # acc = 0
    addi    s4,     x0,     0       # ki = 0

for_ki_loop:
    addi    s5,     x0,     0       # kj = 0

for_kj_loop:
    # input element: row = i+ki, col = j+kj
    add     t0,     s1,     s4
    add     t1,     s2,     s5

    # byte offset = (row*13 + col) * 4
    addi    t3,     x0,     13
    mul     t2,     t0,     t3
    add     t2,     t2,     t1
    slli    t2,     t2,     2

    # load input element
    add     t3,     a0,     t2
    lw      s6,     0(t3)

    # kernel byte offset = (ki*2 + kj) * 4
    slli    t0,     s4,     1
    add     t0,     t0,     s5
    slli    t0,     t0,     2

    # load kernel element
    add     t1,     a1,     t0
    lw      s7,     0(t1)

    # acc += input * kernel
    mul     t0,     s6,     s7
    add     s3,     s3,     t0

    # kj++; if kj < 2 goto for_kj_loop
    addi    s5,     s5,     1
    addi    t0,     x0,     2
    blt     s5,     t0,     for_kj_loop

    # ki++; if ki < 2 goto for_ki_loop
    addi    s4,     s4,     1
    addi    t0,     x0,     2
    blt     s4,     t0,     for_ki_loop

    # output byte offset = (i*11 + j) * 4
    addi    t0,     x0,     11
    mul     t1,     s1,     t0
    add     t1,     t1,     s2
    slli    t1,     t1,     2

    # store output element
    add     t2,     a2,     t1
    sw      s3,     0(t2)

    # j++; if j < 11 goto for_j_loop
    addi    s2,     s2,     1
    addi    t0,     x0,     11
    blt     s2,     t0,     for_j_loop

    # i++; if i < 11 goto for_i_loop
    addi    s1,     s1,     1
    addi    t0,     x0,     11
    blt     s1,     t0,     for_i_loop

# ret with ra=0 jumps to address 0, triggering core_finish
ret
