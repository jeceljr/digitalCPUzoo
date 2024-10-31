.include "mcpu16.inc"

new_game:
	LDA clrScreen
	OUT
	LDP scText
	STA cp
	CALL printString
	LDA rnd
	NOR nibbleMask
	ADD ascZero
	OUT
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
	JMP new_game

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
	
clrScreen: .word 0xC
char:	.word 0x44
cp:	.word 0
scText: .string16 "Score: "
keysText: .word 0x0A, 0x0D, 0x0A, 0x0D
	.string16 "q=new game, wasd or ijkl=move"
rnd:	.word 0xA539
nibbleMask: .word 0xFFF0
ascZero:.word 0x30
score:	.word 0
delta:	.word 0
tiles:  .word 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
