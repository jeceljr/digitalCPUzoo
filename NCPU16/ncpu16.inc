.nolist
	.org 0
absStart:

	.equ r0, 0
	.equ r1, 1
	.equ r2, 2
	.equ r3, 3
	.equ r4, 4
	.equ r5, 5
	.equ r6, 6
	.equ r7, 7
	.equ sp, 6
	.equ pc, 7

	.equ scc, 2
	.equ scs, 3
	.equ snc, 4
	.equ sns, 5
	.equ szc, 6
	.equ szs, 7

	.macro format_math alu, rA, rB, nsv=0, skip=0
		.word (\rA<<11) | (\rB<<8) | (\nsv<<6) | (\alu<<3) | \skip
	.endm

	.macro add rA, rB, nsv=0, skip=0
		format_math 0, \rA, \rB, \nsv, \skip
	.endm
	.macro sub rA, rB, nsv=0, skip=0
		format_math 1, \rA, \rB, \nsv, \skip
	.endm
	.macro asr rA, rB, nsv=0, skip=0
		format_math 2, \rA, \rB, \nsv, \skip
	.endm
	.macro swb rA, rB, nsv=0, skip=0
		format_math 3, \rA, \rB, \nsv, \skip
	.endm
	.macro mov rA, rB, nsv=0, skip=0
		format_math 4, \rA, \rB, \nsv, \skip
	.endm
	.macro and rA, rB, nsv=0, skip=0
		format_math 5, \rA, \rB, \nsv, \skip
	.endm
	.macro or rA, rB, nsv=0, skip=0
		format_math 6, \rA, \rB, \nsv, \skip
	.endm
	.macro xor rA, rB, nsv=0, skip=0
		format_math 7, \rA, \rB, \nsv, \skip
	.endm

	.macro format_mem mode, rA, rB, read, offset
		.word (\mode<<14) | (\rA<<11) | (\rB<<8) | (\read<<7) | (\offset&0x7F)
	.endm

	.macro lea rA, rB, offset
		format_mem 0, \rA, \rB, 1, \offset
	.endm
	.macro sta rA, rB, offset
		format_mem 1, \rA, \rB, 0, \offset
	.endm
	.macro lda rA, rB, offset
		format_mem 1, \rA, \rB, 1, \offset
	.endm
	.macro _sta rA, rB, offset
		format_mem 2, \rA, \rB, 0, \offset
	.endm
	.macro _lda rA, rB, offset
		format_mem 2, \rA, \rB, 1, \offset
	.endm
	.macro sta_ rA, rB, offset
		format_mem 3, \rA, \rB, 0, \offset
	.endm
	.macro lda_ rA, rB, offset
		format_mem 3, \rA, \rB, 1, \offset
	.endm

.list
