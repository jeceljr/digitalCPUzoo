	.include "drv16.inc"
	
/******* this is the famous Mandelbrot fractal with an ASCII output
         adapted to Microsoft BASIC from the versions available on
         Rossetta by gmh in 2015 and translated here to drv16
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

        .equ terminal, 0xFFFE
	.equ counter, 0xFFFC
	.equ I3, x4
	.equ R3, x5
	.equ X, x6
	.equ Y, x7
	.equ Z1, x8
	.equ Z2, x9
	.equ A, x10
	.equ B, x11
	.equ N, x12

	li x1, 0x0C
	sh x1, zero, terminal
L10:	.equ X1, 48
	.equ Y1, 17  /* 50x18 terminal instead of 60x22 */
L20:	.equ I1, 0xFF00   /* -1 em fixed point 8.8 */
	.equ I2, 0x0100   /* +1 */
	.equ R1, 0xFE00   /* -2 */
	.equ R2, 0x0100   /* +1 */
L30:	.equ S1, 0x0010   /* (R2-R1)/X1 = (1--2)/49 = 3/49 */
	.equ S2, 0x001E   /* (I2-I1)/Y1 = (1--1)/17 = 2/17 */
	lh x1, zero, counter
L40:	li I3, I1
	subi I3, I3, S2   /* Y ==-1 here */
	li Y, 0
fsy:	li x1, Y1
	blt x1, Y, fey
L50:	addi I3, I3, S2  /* S2*Y */
L60:	li R3, R1
	subi R3, R3, S1   /* X == -1 here */
	li X, 0
fsx:	li x1, X1
	blt x1, X, fex
L70:	addi R3, R3, S1   /* S1*X */	
	mv Z1, R3
	mv Z2, I3
L80:	li N, 0
fsn:	li x1, 30
	blt x1, N, fen
L90:	mv x13, Z1
	mv x14, Z1
	jal ra, mult
	mv A, x13
	mv x13, Z2
	mv x14, Z2
	jal ra, mult
	mv B, x13
L100:	add x2, A, B
	subi x2, x2, 0x0400  /* +4.0 */
	andi x2, x2, 0x8000
	beq zero, x2, L130
L110:	mv x13, Z1
	mv x14, Z2
	jal ra, mult
	add Z2, x13, x13
	add Z2, Z2, I3
	sub Z1, A, B
	add Z1, Z1, R3
L120:	addi N, N, 1
	j fsn
fen:
L130:	li x1, 31
	beq x1, N, blank
	li x1, 62
	sub x1, x1, N
	sh x1, zero, terminal
	j L140
blank:	li x1, 0x20
	sh x1, zero, terminal	
L140:	addi X, X, 1
	j fsx
fex:
L150:	li x1, 0x0A
	sh x1, zero, terminal
L160:	addi Y, Y, 1
	j fsy
fey:
L170:	sh x1, zero, counter
halt:	j halt

	.macro mloop
	li x2, 16
	li x15, 0
0:	andi x3, x13, 1
	beq x3, zero, 1f
	add x15, x15, x14
1:	srli x13, x13, 1
	andi x3, x15, 1
	beq x3, zero, 2f
	addi x13, x13, 0x8000
2:	srli x15, x15, 1
	subi x2, x2, 1
	bne x2, zero, 0b
	srli x13, x13, 8
	slli x15, x15, 8
	or x13, x13, x15   /* 32 bit result --> 8.8 fixed point */
	.endm

mult:	/* x13, x14 are 8.8 fixed point inputs, the product is left in x13 */
	andi x15, x13, 0x8000
	beq x15, zero, Apos
	sub x13, zero, x13
	andi x15, x14, 0x8000
	beq x15, zero, nmult
	sub x14, zero, x14
	j pmult
Apos:	andi x15, x14, 0x8000
	beq x15, zero, pmult
	sub x14, zero, x14
nmult:	mloop
	sub x13, zero, x13
	ret
pmult:	mloop
	ret
	
	
/*********** borrowed from sieve.S to test multiplication **********/	
printDecimal:
	beq a0, zero, p0
	andi x13, a0, 0x8000
	beq x13, zero, pos
	sub a0, zero, a0
	li x13, 0x2D
	sh x13, zero, terminal
pos:
	mv x14, ra
	li x13, 1
	li a1, 25600
	jal ra, printDigit
	li a1, 2560
	jal ra, printDigit
	li a1, 256
	jal ra, printDigit
	li x15, 0x2E
	sh x15, zero, terminal
	li a1, 26
	jal ra, printDigit
	li a1, 2
	jal ra, printDigit
	mv ra, x14
	ret
p0:	li a0, 0x30
	sh a0, zero, terminal
	ret

printDigit:
	li x15, 0
cnt:	blt a0, a1, outDigit
	sub a0, a0, a1
	addi x15, x15, 1
	j cnt
outDigit:
	beq x15, zero, zDigit
	addi x15, x15, 0x30
	sh x15, zero, terminal
	li x13, 0
	ret
zDigit:
	bne x13, zero, eDigit
	li x15, 0x30
	sh x15, zero, terminal
eDigit:
	ret

