nop             # Values initialized using addi (positive only)
nop             # Author: Oliver Rodas
nop
nop
nop             # Bypassing to and from Multdiv
addi $1, $0, 12        # r1 = 12
nop            # Avoid RAW hazard to test bypassing 1 value
addi $2, $0, 13        # r2 = 13
mul $3, $1, $2        # r3 = r1 * r2 = 156    (X->D)
sub $4, $3, $1        # r4 = r3 - r1 = 144    (X->D)
addi $5, $0, 4        # r5 = 4
div $6, $1, $5        # r6 = r1 / r5 = 3        (X->D)
addi $7, $0, 8        # r7 = 8
addi $8, $0, 3        # r8 = 3
mul $9, $8, $7        # r9 = r8 * r7 = 24        (X->D and M->D)
div $10, $9, $1        # r10 = r9 / r1 = 2        (X->D)
div $11, $9, $10        # r11 = r9 / r10 = 12    (X->D and M->D)