# Efficiency Test 4: Bypassing into BEX 
nop
nop 	
nop
nop	
nop
setx 0				# r30 = 0
nop				# Avoid RAW hazard from first setx
setx 10				# r30 = 10 (with RAW hazard)
bex e1				# r30 != 0 --> taken
addi $20, $20, 1		# r20 += 1 (Incorrect)
addi $20, $20, 1		# r20 += 1 (Incorrect)
addi $20, $20, 1		# r20 += 1 (Incorrect)
addi $20, $20, 1		# r20 += 1 (Incorrect)
addi $20, $20, 1		# r20 += 1 (Incorrect)
e1: addi $10, $10, 1		# r10 += 1 (Correct)
nop
nop
nop
nop
# Final: $r10 should be 1, $r20 should be 0, $r30 should be 10
