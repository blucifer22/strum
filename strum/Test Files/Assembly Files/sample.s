###
##
#       ECE350 Spring 2021: Sample MIPS file
#       Note: the code doesn't test any kind of functionality; it serves to
#             illustrate the syntax of instructions supported
##
###


add     $0, $1, $2
addi    $2, $3, 100
sub     $4, $5, $6
and     $7, $8, $9
or      $10, $11, $12
sll     $11, $12, 5
sra     $10, $11, 6
mul     $1, $2, $3
div     $4, $5, $6
sw      $7, 10($8)
lw      $9, 5($10)
j       100
bne     $0, $1, here
j       there

here:
    jal     overthere

there:
    bex     overthere
    setx    15
    jr      $31

overthere:
    blt     $0, $1, -1
