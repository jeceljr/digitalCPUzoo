	.include "mcpu16.inc"
	
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

	.macro srai dest, v, N
	LDA zero
	STA sHigh
	LDA \v
	STA sLow
	NOR signMask
	ADD minusOne
	JCS 0f
	LDA minusOne
	STA sHigh
0:	dslli (16-\N)
	LDA sHigh
	STA \dest
	.endm
	
	.macro dslli N
	.if \N
	LDA sHigh
	ADD sHigh
	STA sHigh
	LDA sLow
	NOR signMask
	ADD minusOne
	JCS 0f
	LDA sHigh
	ADD one
	STA sHigh  /* shift in top bit of sLow */
0:	LDA sLow
	ADD sLow
	STA sLow
	dslli "(\N-1)"
	.endif
	.endm
	
loop:	COUNT
	STARTCOUNT
	LDA k1f
	STA SIN  /* 1.0 */
	LDA zero
	STA COS
	LDA k50
	STA steps
printSine:
	/* SIN+1.0 -> 0 to 2 */
	LDA SIN
	ADD k1f
	STA count
	srai t0, count, 10  /*(13-3)  x8 asInt */
	srai t1, count, 9   /*(13-4) x16 asInt */
	/* x24  -> 0 to 48 */
	LDA t1
	ADD t0
	STA count
blnks:	LDA count
	ADD minusOne
	JCC printStar
	LDA ascSpace
	OUT
	LDA count
	ADD minusOne
	STA count
	JMP blnks
printStar:
	LDA ascStar
	OUT
	LDA ascCR
	OUT
	/* advance 7.125 degrees */
	srai C2, SIN, 3
	LDA C2
	SUB COS
	STA C2
	srai t0, C2, 7
	LDA t0
	SUB C2
	STA C2
	srai S2, COS, 3
	LDA S2
	ADD SIN
	STA S2
	srai t0, S2, 7
	LDA t0
	SUB S2
	STA S2
	LDA C2
	STA COS
	LDA S2
	STA SIN
	LDA steps
	ADD minusOne
	STA steps
	ADD minusOne
	JCC loop
	JMP printSine
	
SIN:	.word 0
COS:	.word 0
S2:	.word 0
C2:	.word 0
count:	.word 0
steps:	.word 0
t0:	.word 0
t1:	.word 0
sLow:	.word 0
sHigh:	.word 0
k1f:	.word 0x2000
k50:	.word 50
ascSpace:.word 0x20
ascStar:.word 0x2A
ascCR:	.word 0x0D
signMask:.word 0x7FFF
