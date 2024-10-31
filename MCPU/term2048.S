.include "mcpu16.inc"

new_game:
	LDA clrScreen
	OUT
	LDP scText
	STA cp
	CALL printString
	JMP new_game

printString:
	.word 0
ploop:
        LDA cp
        ADD adInst
        STA 0f
        CLR
0:      .word 0  /* will be replaced */
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
adInst:	.word 0x4000
