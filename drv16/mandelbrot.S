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
	.equ R2, x5
	.equ X, x6
	.equ Y, x7
	.equ Z1, x8
	.equ Z2, x9
	.equ A, x10
	.equ B, x11
	.equ N, x12
	
L10:	.equ X1, 49
	.equ Y1, 17  /* 50x18 terminal instead of 60x22 */
L20:	.equ I1, 0xFF00   /* -1 em fixed point 8.8 */
	.equ I2, 0x0100   /* +1 */
	.equ R1, 0xFE00   /* -2 */
	.equ R2, 0x0100   /* +1 */
L30:	.equ S1, 0x0010   /* (R2-R1)/X1 = (1--2)/49 = 3/49 */
	.equ S2, 0x001E   /* (I2-I1)/Y1 = (1--1)/17 = 2/17 */
	lh x1, zero, counter
L40:	li I3, I1
	li Y, 0
fsy:	li x1, Y1
	blt x1, Y, fey
L50:	addi I3, I3, S2  /* S2*Y */
L60:	li R3, R1
	li X, 0
fsx:	li x1, X1
	blt x1, X, fex
L70:	addi R3, R3, S1   /* S1*X */	
	mv Z1, R3
	mv Z2, I3
L80:	li N, 0
fsn:	li x1, 30
	blt x1, N, fen
L90:
L100:
L110:	
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
L150:	li x1, 0x0D
	sh x1, zero, terminal
L160:	addi Y, Y, 1
	j fsy
fey:
L170:	sh x1, zero, counter
halt:	j halt

mult:	/* x13, x14 are 8.8 fixed point inputs, the product is left in x13, x15 is return address */
	jr x15
