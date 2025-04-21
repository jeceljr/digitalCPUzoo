/******* this is the famous Mandelbrot fractal with an ASCII output
         adapted to Microsoft BASIC from the versions available on
         Rossetta by gmh in 2015 and translated here to RISC-V
         assembly language by Jecel Assumpcao Jr in November 2024

         for reference, the original Basic program:
         
10 X1=59:Y1=21
20 I1=-1:I2=1:R1=-2:R2=1
30 S1=(R2-R1)/X1:S2=(I2-I1)/Y1
40 FOR Y=0 TO Y1
50 I3=I1+S2*Y
60 FOR X=0 TO X1
70 R3=R1+S1*X:Z1=R3:Z2=I3
80 FOR N=0 TO 30
90 A=Z1*Z1:B=Z2*Z2
100 IF A+B>4 THEN GOTO 130
110 Z2=2*Z1*Z2+I3:Z1=A-B+R3
120 NEXT N
130 IF N=31 THEN PRINT " "; ELSE PRINT CHR$(62-N);
140 NEXT X
150 PRINT
160 NEXT Y
170 END
***********************************************************************/

        .equ terminal, 0xFFFFFFFC
	.equ counter, 0xFFFFFFF8

/* registers: I3 (x4), R3 (x5), X (x6), Y (x7), Z1 (x8), Z2 (x9), A (x20), B (x11), N (x12)  */

	li x22, 0x0C
	sh x22, terminal(zero)
	li x31, 0xFFFF8000   /* sign 8.8 */
L10:	.equ X1, 48
	.equ Y1, 17  /* 50x18 terminal instead of 60x22 */
L20:	.equ I1, 0xFFFFFF00   /* -1 em fixed point 8.8 */
	.equ I2, 0x00000100   /* +1 */
	.equ R1, 0xFFFFFE00   /* -2 */
	.equ R2, 0x00000100   /* +1 */
L30:	.equ S1, 0x00000010   /* (R2-R1)/X1 = (1--2)/49 = 3/49 */
	.equ S2, 0x0000001E   /* (I2-I1)/Y1 = (1--1)/17 = 2/17 */
	lh x22, counter(zero)
L40:	li x4, I1
	addi x4, x4, -S2   /* Y ==-1 here */
	li x7, 0
fsy:	li x22, Y1
	blt x22, x7, fey
L50:	addi x4, x4, S2  /* S2*Y */
L60:	li x5, R1
	addi x5, x5, -S1   /* X == -1 here */
	li x6, 0
fsx:	li x22, X1
	blt x22, x6, fex
L70:	addi x5, x5, S1   /* S1*X */	
	mv x8, x5
	mv x9, x4
L80:	li x12, 0
fsn:	li x22, 30
	blt x22, x12, fen
L90:	mv x13, x8
	mv x14, x8
	jal ra, mult
	mv x20, x13
	mv x13, x9
	mv x14, x9
	jal ra, mult
	mv x11, x13
L100:	add x21, x20, x11
	addi x21, x21, -0x0400  /* +4.0 */
	and x21, x21, x31
	beq zero, x21, L130
L110:	mv x13, x8
	mv x14, x9
	jal ra, mult
	add x9, x13, x13
	add x9, x9, x4
	sub x8, x20, x11
	add x8, x8, x5
L120:	addi x12, x12, 1
	j fsn
fen:
L130:	li x22, 31
	beq x22, x12, blank
	li x22, 62
	sub x22, x22, x12
	sh x22, terminal(zero)
	j L140
blank:	li x22, 0x20
	sh x22, terminal(zero)	
L140:	addi x6, x6, 1
	j fsx
fex:
L150:	li x22, 0x0A
	sh x22, terminal(zero)
L160:	addi x7, x7, 1
	j fsy
fey:
L170:	sh x22, counter(zero)
halt:	j halt

	.macro mloop
	li x2, 16
	li x15, 0
0:	andi x3, x13, 1
	beq x3, zero, 1f
	add x15, x15, x14
1:	srli x13, x13, 1
	slli x14, x14, 1
	addi x2, x2, -1
	bne x2, zero, 0b
	srli x13, x15, 8
	.endm

mult:	/* x13, x14 are 8.8 fixed point inputs, the product is left in x13 */
	and x15, x13, x31
	beq x15, zero, Apos
	sub x13, zero, x13
	and x15, x14, x31
	beq x15, zero, nmult
	sub x14, zero, x14
	j pmult
Apos:	and x15, x14, x31
	beq x15, zero, pmult
	sub x14, zero, x14
nmult:	mloop
	sub x13, zero, x13
	ret
pmult:	mloop
	ret
