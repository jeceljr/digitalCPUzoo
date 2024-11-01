.include "mcpu16.inc"

loop:
	LDA cp
	ADD adInst
	STA 0f
	CLR
0:	.word 0  /* will be replaced */
	STA char
	ADD minusOne
	JCC halt    /* zero terminated string */
	LDA char
	OUT
	LDA cp
	ADD one
	STA cp
	JMP loop

halt:	JMP halt

text:	.string16 "Hello world!"
cp:	.word (text-absStart)/2
char:	.word 0
