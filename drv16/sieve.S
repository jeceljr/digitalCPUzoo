	.include "drv16.inc"
	
/******* this is the famous Sieve of Eratosthenes benchmark originally
         published in Basic in Byte magazine translated here to drv16
         assembly language by Jecel Assumpcao Jr in November 2024

         for reference, the original Basic program:
         1 SIZE = 8190
         2 DIM FLAGS(8191)
         3 PRINT "Only 1 iteration"
         5 COUNT = 0
         6 FOR I = 0 TO SIZE
         7 FLAGS (I) = 1
         8 NEXT I
         9 FOR I = 0 TO SIZE
         10 IF FLAGS (I) = 0 THEN 18
         11 PRIME = I+I + 3
         12 K = I + PRIME
         13 IF K > SIZE THEN 17
         14 FLAGS (K) = 0
         15 K = K + PRIME
         16 GOTO 13
         17 COUNT = COUNT + 1
         18 NEXT I
         19 PRINT COUNT," PRIMES"
***********************************************************************/

        .equ terminal, 0xFFFE
	.equ counter, 0xFFFC
	.equ I, t0
	.equ K, t1
	.equ PRIME, s0
	.equ COUNT, s1

L1:	.equ SIZE, 8190
L3:     li a0, 0x0C
	sh a0, zero, terminal
	la a0, txt1
        jal ra, printString
        li a0, 0x0D
        sh a0, zero, terminal
	lh t0,zero, counter    /* clear counter */
L5:	li COUNT, 0
	li x3, (SIZE+1)
	li x4, 1
L6:	li I, 0
fs1:	blt x3, I, fe1
L7:	sb x4, I, (FLAGS-absStart)
L8:	addi I, I, 1
	j fs1
fe1:
L9:	li I, 0
fs2:	blt x3, I, fe2
L10:	lb t2, I, (FLAGS-absStart)
	beq t2, zero, L18
L11:	add PRIME, I, I
	addi PRIME, PRIME, 3
L12:	add K, I, PRIME
L13:	blt x3, K, L17
L14:	li a0, 0
	sb a0, K, (FLAGS-absStart)
L15:	add K, K, PRIME
L16:	j L13
L17:	addi COUNT, COUNT, 1
L18:	addi I, I, 1
	j fs2
fe2:
L19:	mv a0, COUNT
	jal ra, printDecimal
	la a0, txtp
        jal ra, printString
        sh t0, zero, counter  /* show clocks */
halt:	j halt


printString:
chars:
        lb t0, a0, 0
        bne t0, zero, moreChars
        ret
moreChars:
        sh t0, zero, terminal
        addi a0, a0, 1
        j chars

printDecimal:
	beq a0, zero, p0
	mv t2, ra
	li t1, 1
	li a1, 10000
	jal ra, printDigit
	li a1, 1000
	jal ra, printDigit
	li a1, 100
	jal ra, printDigit
	li a1, 10
	jal ra, printDigit
	li a1, 1
	jal ra, printDigit
	mv ra, t2
	ret
p0:	li a0, 0x30
	sh a0, zero, terminal
	ret

printDigit:
	li t0, 0
cnt:	blt a0, a1, outDigit
	sub a0, a0, a1
	addi t0, t0, 1
	j cnt
outDigit:
	beq t0, zero, zDigit
	addi t0, t0, 0x30
	sh t0, zero, terminal
	li t1, 0
	ret
zDigit:
	bne t1, zero, eDigit
	li t0, 0x30
	sh t0, zero, terminal
eDigit:
	ret
		        
txt1:	.asciz "Only 1 iteration"
txtp:	.asciz " PRIMES"
FLAGS:	.fill SIZE+1, 1, 0
	.balign 2, 0
last:	.word 0x55AA

