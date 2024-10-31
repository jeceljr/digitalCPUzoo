.include "mcpu16.inc"

/********************************
* 2048 is a puzzle game created by
* Gabriele Cirulli in 2014 in
* Javascript.
*
* This version by Jecel Assumpcao Jr
* does not have animations since it
* uses a simple terminal output
********************************/

	.macro compChar c, dest
	LDA char
	SUB \c
	ADD minusOne
	JCC \dest
	.endm

new_game:
	CLR
	STA score
showScreen:
	LDA clrScreen
	OUT
	LDP scText
	STA cp
	CALL printString
	LDA score
	STA num
	CALL printDecimal
	LDP keysText
	STA cp
	CALL printString
getChar:LDA rnd
	ADD one
	STA rnd
	IN
	STA char
	ADD minusOne
	JCC getChar
	compChar ascQ, new_game
	compChar ascW, moveUp
	compChar ascI, moveUp
	compChar ascA, moveLeft
	compChar ascJ, moveLeft
	compChar ascS, moveDown
	compChar ascK, moveDown
	compChar ascD, moveRight
	compChar ascL, moveRight
	JMP showScreen

moveUp:	LDA score
	ADD one
	STA score
	JMP showScreen

moveDown:LDA score
	ADD minusOne
	STA score
	JMP showScreen

moveLeft:LDA score
	ADD one
	STA score
	JMP showScreen

moveRight:LDA score
	ADD minusOne
	STA score
	JMP showScreen


printString:
	.word 0
ploop:
        LDInd cp
        STA char
        ADD minusOne
        JCC printString    /* return - zero terminated string */
        LDA char
        OUT
        LDA cp
        ADD one
        STA cp
        JMP ploop

	.macro printDigit n
	CLR
	STA count
1:	LDA num
	ADD 2f
	STA num
	ADD signMask
	JCS 4f
	LDA count
	ADD one
	STA count
	JMP 1b
4:	LDA 2f
	SUB num
	STA num  /* went too far, go back one */
	LDA leadZ
	ADD minusOne
	JCC 5f
	LDA count
	ADD minusOne
	JCC 3f     /* skip leading zeros */
5:	CLR
	STA leadZ
	LDA count  /* should be between 0 and 9 */
	ADD ascZero
	OUT
	JMP 3f
2:	.word 0-\n
3:
	.endm

printDecimal:
	.word 0
	LDA num
	ADD minusOne
	JCC printZero
	LDA one
	STA leadZ
	printDigit 10000
	printDigit  1000
	printDigit   100
	printDigit    10
	printDigit     1
	JMP printDecimal
printZero:
	LDA ascZero
	OUT
	JMP printDecimal
	
char:	.word 0
cp:	.word 0
num:	.word 1
count:	.word 0
leadZ:	.word 0
scText: .string16 "Score: "
keysText: .word 0x0A, 0x0D, 0x0A, 0x0D
	.string16 "q=new game, wasd or ijkl=move"
rnd:	.word 0xA539
nibbleMask: .word 0xFFF0
signMask: .word 0x8000
clrScreen: .word 0xC
ascZero:.word 0x30
ascQ:	.word 0x71
ascW:	.word 0x77
ascI:	.word 0x69
ascA:	.word 0x61
ascJ:	.word 0x6A
ascS:	.word 0x73
ascK:	.word 0x6B
ascD:	.word 0x64
ascL:	.word 0x6C
score:	.word 0
delta:	.word 0
tiles:  .word 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
