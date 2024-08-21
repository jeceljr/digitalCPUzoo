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
	mov r0, r1  /* result was b */
	jsr printDecimal
	lea r0, txt1
	jsr printString
	lea r2, a
	lda r0, r2
	jsr printDecimal
	lea r0, txt2
	jsr printString
	lea r2, b
	lda r0, r2
	jsr printDecimal
stop:
	jmp stop

printString:
	.byte 0
	ldi r2, 0xFF /* terminal */
nextChar:
	lda r1, r0
	bzs endString
	sta r1, r2
	inc r0, r0
	jmp nextChar
endString:
	ret printString

	.macro printDigit num
	xor r1, r1  /* clear count */
	ldi r2, \num 
2:
	sub r0, r2
	bcc 1f
	inc r1, r1
	jmp 2b
1:
	add r0, r2  /* restore */
	ldi r2, 0x30
	add r1, r2  /* convert digit to ascii */
	ldi r2, 0xFF /* terminal */
	sta r1, r2
	.endm

printDecimal:
	.byte 0
	printDigit 100
	printDigit 10
	printDigit 1
	ret printDecimal

a:	.byte 12
b:	.byte 18
txt1:	.asciz " is the greatest common denominator of "	
txt2:	.asciz " and "
