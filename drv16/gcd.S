.include "drv16.inc"

start:
	la t0, a
	lh x1, t0, 0
	la t0, b
	lh x2, t0, 0
loop:
	beq x1, zero, done
	blt x1, x2, reduceB
	sub x1, x1, x2  /* a = a-b */
	j loop
reduceB:
	sub x2, x2, x1  /* b = b-a */
	j loop

done:
	mv a0, x2    /* result in b */
        jal ra, printDecimal
	addi a0, zero, (txt1-absStart)
	jal ra, printString
	la t0, a
	lh a0, t0, 0
	jal ra, printDecimal
	addi a0, zero, (txt2-absStart)
	jal ra, printString
	la t0, b
	lh a0, t0, 0
	jal ra, printDecimal
stop:   j stop

	.equ terminal, 0xFFFE

printString:
chars:
	lb t0, a0, 0
	bne t0, zero, moreChars
	ret
moreChars:
	sh t0, zero, terminal
	addi a0, a0, 1
	j chars

	.macro printDigit num
	li t0, \num
	xor a1, a1, a1   /* clear counter */
1:
	blt a0, t0, 2f
	sub a0, a0, t0
	addi a1, a1, 1
	j 1b
2:
	addi a1, a1, 0x30  /* convert digit to ascii */
	sh a1, zero, terminal	
	.endm

printDecimal:
	printDigit 100
	printDigit 10
	printDigit 1
	ret

a:	.word 12
b:	.word 18
txt1:	.asciz " is the greatest common denominator of "	
txt2:	.asciz " and "
