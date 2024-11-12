	.include "drv16.inc"
	
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
	numbers are fixed point 3.13 two's complement (-4.9999 to 3.99999)
**************/

        .equ terminal, 0xFFFE
	.equ counter, 0xFFFC

	.equ SIN, x3
	.equ COS, x4
	.equ S2, x5
	.equ C2, x6
	.equ count, x7
	.equ steps, x8
	
loop:	sh steps, zero, counter
	lh steps, zero, counter
	li SIN, 0x2000   /* 1.0 */
	li COS, 0
	li steps, 50
printSine:
	addi count, SIN, 0x2000   /* SIN+1.0 -> 0 to 2 */
	srai x9, count, (13-3)  /* x8 asInt */
	srai x10, count, (13-4) /* x16 asInt */
	add count, x9, x10      /* x24  -> 0 to 48 */
blnks:	beq count, zero, printStar
	li x9, 0x20
	sh x9, zero, terminal
	subi count, count, 1
	j blnks
printStar:
	li x9, 0x2A
	sh x9, zero, terminal
	li x9, 0x0D
	sh x9, zero, terminal
	/* advance 7.125 degrees */
	srai C2, SIN, 3
	sub C2, COS, C2
	srai x9, C2, 7
	sub C2, C2, x9
	srai S2, COS, 3
	add S2, SIN, S2
	srai x9, S2, 7
	sub S2, S2, x9
	mv COS, C2
	mv SIN, S2
	subi steps, steps, 1
	beq steps, zero, loop
	j printSine
