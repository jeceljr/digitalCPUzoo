.nolist
	.org 0
absStart:
	.macro NOR a
	.byte (0x3F & (\a-absStart))
	.endm

	.macro ADD a
	.byte (0x3F & (\a-absStart)) | 0x40
	.endm

	.macro STA a
	.byte (0x3F & (\a-absStart)) | 0x80
	.endm

	.macro JCC a
	.byte (0x3F & (\a-absStart)) | 0xC0
	.endm

	.macro CLR
	NOR allone
	.endm

	.macro LDA a
	NOR allone
	ADD \a
	.endm

	.macro NOT
	NOR zero
	.endm

	.macro JMP a
	JCC \a
	JCC \a
	.endm

	.macro JCS a
	JCC .+2
	JCC \a
	.endm

	.macro SUB a
	NOR zero
	ADD \a
	ADD one
	.endm

.list
