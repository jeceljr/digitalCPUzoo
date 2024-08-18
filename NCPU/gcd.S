.include "ncpu.inc"

start:
	lea r2, a
	lda r0, r2
	lea r2, b
	lda r1, r2

loop:
	mov r2, r0
	sub r2, r1   /* a-b */
	bcc invert

	mov r0, r2   /* a := a-b */
	bzs done
	jmp loop

invert:
	neg r1, r2 /* b := b-a */
	jmp loop

done:
	jmp done

a:	.byte 12
b:	.byte 18
