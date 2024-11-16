/**************
	(C) 2024 Jecel Assumpção Jr
	
	Generates a sine wave based on the CORDIC algorithm
	for angle 0, we have COS = 0, SIN = 1
	turn by angle X: COS = cos(x) * (COS - tan(X)*SIN)
	                 SIN = cos(X) * (tan(X)*COS + SIN)
	X=7.125 degrees -> tan(X) = 1/8, cos(X) = 0.992277877
	                                        = 1-(1/129.498)
	360/7.125 = 50.526 steps, so we
	reset COS and SIN after 50 steps
	
	the terminal is 50 characters wide
	numbers are fixed point 19.13 two's complement to match
	the results of the 16 bit processors
**************/

        .equ terminal, 0xFFFFFFFC
	.equ counter, 0xFFFFFFF8
	
/* registers: SIN (x3), COS (x4), S2 (x5), C2 (x6), count (x7), steps (x8) */
	li a0, 0x12345678
	jal ra, printBinary
	li a0, 0xFEA5FEC8
	jal ra, printBinary
	li a0, 0x12345678
	jal ra, printBinary
loop:	sh x8, counter(zero)
	lh x8, counter(zero)
	li x3, 0x2000   /* 1.0 */
	li x4, 0
	li x8, 50
printSine:
	li x7, 0x2000
	add x7, x3, x7   /* SIN+1.0 -> 0 to 2 */
	srai x9, x7, (13-3)  /* x8 asInt */
	srai x10, x7, (13-4) /* x16 asInt */
	add x7, x9, x10      /* x24  -> 0 to 48 */
	mv a0, x3
	jal ra, printBinary
	mv a0, x4
	jal ra, printBinary
	mv a0, x7
	jal ra, printBinary
blnks:	beq x7, zero, printStar
	li x9, 0x20
	sh x9, terminal(zero)
	addi x7, x7, -1
	j blnks
printStar:
	li x9, 0x2A
	sh x9, terminal(zero)
	li x9, 0x0D
	sh x9, terminal(zero)
	/* advance 7.125 degrees */
	srai x6, x3, 3
	mv a0, x6
	jal ra, printBinary
	sub x6, x4, x6
	mv a0, x6
	jal ra, printBinary
	srai x9, x6, 7
	mv a0, x9
	jal ra, printBinary
	sub x6, x6, x9
	mv a0, x6
	jal ra, printBinary
	srai x5, x4, 3
	mv a0, x5
	jal ra, printBinary
	add x5, x3, x5
	mv a0, x5
	jal ra, printBinary
	srai x9, x5, 7
	mv a0, x9
	jal ra, printBinary
	sub x5, x5, x9
	mv a0, x5
	jal ra, printBinary
	li x15, 0x0D
	sh x15, terminal(zero)
	mv x4, x6
	mv x3, x5
	addi x8, x8, -1
	beq x8, zero, loop
	j printSine
	
printBinary:
	li x15, 0x0D
	sh x15, terminal(zero)
	li x14, 0x80000000
pBits:	li x15, 0x30
	and x13, a0, x14
	beq x13, zero, pBit
	li x15, 0x31
pBit:	sh x15, terminal(zero)
	srli x14, x14, 1
	bne x14, zero, pBits
	ret
