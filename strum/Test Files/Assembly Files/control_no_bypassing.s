nop # Basic Control Test with no Data Hazards
nop # Values initialized using addi (positive only) and sub
nop # Registers 10,11 track correct and 20,21 track incorrect
nop # Values and comments in the test of JR must be updated if code modified.
nop # Author: Nathaniel Brooke
nop
nop
nop # Initialize Values
addi $r1, $r0, 4		# r1 = 4
addi $r2, $r0, 5		# r2 = 5
sub $r3, $r0, $r1		# r3 = -4
sub $r4, $r0, $r2		# r4 = -5
nop
nop 				# Basic Test of BNE
bne $r1, $r2, b1		# r1 != r2 --> taken
nop				# flushed instruction
nop				# flushed instruction
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
b1: addi $r10, $r10, 1		# r10 += 1 (Correct)
bne $r2, $r2, b2		# r2 == r2 --> not taken
nop				# nop in case of flush
nop				# nop in case of flush
nop				# Spacer
addi $r10, $r10, 1		# r10 += 1 (Correct)
b2: nop				# Landing pad for branch
nop				# Avoid add RAW hazard
add $r11, $r10, $r11		# Accumulate r10 score
add $r21, $r20, $r21		# Accumulate r20 score
and $r10, $r0, $r10		# r10 should be 2
and $r20, $r0, $r20		# r20 should be 0
nop
nop # Basic Test of BLT
blt $r1, $r2, b3		# r1 < r2 --> taken
nop				# flushed instruction
nop				# flushed instruction
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
b3: addi $r10, $r10, 1		# r10 += 1 (Correct)
blt $r2, $r2, b4		# r2 == r2 --> not taken
nop				# nop in case of flush
nop				# nop in case of flush
nop				# Spacer
addi $r10, $r10, 1			# r10 += 1 (Correct)
b4: nop				# Landing pad for branch
blt $r4, $r1, b5			# r4 < r1 --> taken
nop				# flushed instruction
nop				# flushed instruction
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
b5: addi $r10, $r10, 1		# r10 += 1 (Correct)
blt $r2, $r1, b6		# r2 > r1 --> not taken
nop				# nop in case of flush
nop				# nop in case of flush
nop				# Spacer
addi $r10, $r10, 1		# r10 += 1 (Correct)
b6: nop				# Landing pad for branch
blt $r4, $r3, b7		# r4 < r3 --> taken
nop				# flushed instruction
nop				# flushed instruction
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
b7: addi $r10, $r10, 1		# r10 += 1 (Correct)
blt $r3, $r4, b8		# r3 > r4 --> not taken
nop				# nop in case of flush
nop				# nop in case of flush
nop				# Spacer
addi $r10, $r10, 1		# r10 += 1 (Correct)
b8: nop				# Landing pad for branch
nop				# Avoid add RAW hazard
add $r11, $r10, $r11		# Accumulate r10 score
add $r21, $r20, $r21		# Accumulate r20 score
and $r10, $r0, $r10		# r10 should be 6
and $r20, $r0, $r20		# r20 should be 0
nop
nop 				# Basic Test of J
j j1				# Jump to j1
nop				# flushed instruction
nop				# flushed instruction
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
j1: addi $r10, $r10, 1		# r10 += 1 (Correct)
nop				# Avoid add RAW hazard
nop				# Avoid add RAW hazard
add $r11, $r10, $r11		# Accumulate r10 score
add $r21, $r20, $r21		# Accumulate r20 score
and $r10, $r0, $r10		# r10 should be 1
and $r20, $r0, $r20		# r20 should be 0
nop
nop 				# Basic test of JAL, JR
addi $r31, $r0, 100		# r31 = 100
jal j2				# Jump to j2, r31 = PC + 1 = 97
nop				# flushed instruction
nop				# flushed instruction
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
j2: addi $r10, $r10, 1		# r10 += 1 (Correct)
nop				# nop to avoid JAL hazard
addi $r31, $r31, 16		# r31 = r31 + 16 = 113
nop				# Avoid add RAW hazard
nop				# Avoid add RAW hazard
jr $r31				# PC = r31 = 113
nop				# flushed instruction
nop				# flushed instruction
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r10, $r10, 1		# r10 += 1 (Correct)
nop				# Avoid add RAW hazard
nop				# Avoid add RAW hazard
add $r11, $r10, $r11		# Accumulate r10 score
add $r21, $r20, $r21		# Accumulate r20 score
and $r10, $r0, $r10		# r10 should be 2
and $r20, $r0, $r20		# r20 should be 0
nop
nop 				# Basic Text of BEX, SETX
setx 0				# r30 = 0
nop				# Avoid setx RAW hazard
nop				# Avoid setx RAW hazard
bex e1				# r30 == 0 --> not taken
nop				# nop in case of flush
nop				# nop in case of flush
nop				# Spacer
addi $r10, $r10, 1		# r10 += 1 (Correct)
e1: nop				# Landing pad for branch
setx 10				# r30 = 10
nop				# Avoid setx RAW hazard
nop				# Avoid setx RAW hazard
bex e2				# r30 != 0 --> taken
nop				# flushed instruction
nop				# flushed instruction
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
e2: addi $r10, $r10, 1		# r10 += 1 (Correct)
nop				# Avoid add RAW hazard
nop				# Avoid add RAW hazard
add $r11, $r10, $r11		# Accumulate r10 score
add $r21, $r20, $r21		# Accumulate r20 score
and $r10, $r0, $r10		# r10 should be 2
and $r20, $r0, $r20		# r20 should be 0
nop
nop # Test of Flushing
bne $r0, $r1, f1		# r0 != r1 --> taken
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
nop				# Spacer
nop				# Spacer
nop				# Spacer
f1: nop				# Landing pad for branch
bne $r0, $r0, f2		# r0 == r0 --> not taken
addi $r10, $r10, 1		# r10 += 1 (Correct)
nop				# Spacer
nop				# Spacer
nop				# Spacer
nop				# Spacer
f2: nop				# Landing pad for branch
blt $r0, $r1, f3		# r0 < r1 --> taken
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
nop				# Spacer
nop				# Spacer
nop				# Spacer
f3: nop				# Landing pad for branch
blt $r0, $r0, f4		# r0 == r0 --> not taken
nop				# Spacer
addi $r10, $r10, 1		# r10 += 1 (Correct)
nop				# Spacer
nop				# Spacer
nop				# Spacer
f4: nop				# Landing pad for branch
j f5				# Jump to f3
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
nop				# Spacer
nop				# Spacer
nop				# Spacer
f5: nop				# Landing pad for jump
jal f6				# Jump to f4
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
nop				# Spacer
nop				# Spacer
nop				# Spacer
f6: nop				# Landing pad for jump
bex f7				# r30 != 0 --> taken
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
addi $r20, $r20, 1		# r20 += 1 (Incorrect)
nop				# Spacer
nop				# Spacer
nop				# Spacer
f7: nop				# Landing pad for branch
nop				# Avoid add RAW hazard
add $r11, $r10, $r11		# Accumulate r10 score
add $r21, $r20, $r21		# Accumulate r20 score
and $r10, $r0, $r10		# r10 should be 2
and $r20, $r0, $r20		# r20 should be 0
nop
nop # Final Check (All Correct)
and $r0, $r11, $r11		# r11 should be 15
and $r0, $r21, $r21		# r21 should be 0