.nolist
	.org 0
absStart:
	.macro NOR a
	.word (0x3FFF & ((\a-absStart)/2))
	.endm

	.macro ADD a
	.word (0x3FFF & ((\a-absStart)/2)) | 0x4000
	.endm

	.macro STA a
	.word (0x3FFF & ((\a-absStart)/2)) | 0x8000
	.endm

	.macro JCC a
	.word (0x3FFF & ((\a-absStart)/2)) | 0xC000
	.endm

	.macro CLR
	NOR minusOne
	.endm

	.macro LDA a
	NOR minusOne
	ADD \a
	.endm
	
	.macro LDP a
	LDA 0f
	JMP 1f
0:	.word (\a-absStart)/2
1: 
	.endm

	.macro NOT
	NOR zero
	.endm

	.macro JMP a
	JCC \a
	JCC \a
	.endm

	.macro JCS a
	JCC .+4
	JCC \a
	.endm

	.macro SUB a
	NOR zero
	ADD \a
	ADD one
	.endm

	.macro CALL a
	LDA 0f
	STA \a
	JMP \a+2
0:	JCC .+2
	.endm

	.macro OUT
	.word 0xBFFF
	.endm

	.macro IN
	NOR minusOne
	.word 0x7FFF
	.endm

	JMP start

zero:	.word 0
one:	.word 1
minusOne: .word 0xFFFF

start:
.list
