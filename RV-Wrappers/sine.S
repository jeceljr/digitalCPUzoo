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
	sub x6, x4, x6
	srai x9, x6, 7
	sub x6, x6, x9
	srai x5, x4, 3
	add x5, x3, x5
	srai x9, x5, 7
	sub x5, x5, x9
	mv x4, x6
	mv x3, x5
	addi x8, x8, -1
	beq x8, zero, loop
	j printSine

