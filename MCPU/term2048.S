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

	.macro newLine
	LDA ascLF
	OUT
	/*LDA ascCR
	OUT*/
	.endm

	.macro showCell x, y
	CLR
	.word 0x4000 | (((tiles-absStart)/2)+4*\y+\x)
	STA num
	CALL printCell
	.endm

	.macro ldCell x, y
	CLR
	.word 0x4000 | (((tiles-absStart)/2)+4*\y+\x)
	.endm

	.macro stCell x, y
	.word 0x8000 | (((tiles-absStart)/2)+4*\y+\x)
	.endm
	
	.macro zCell x, y
	ldCell \x, \y
	ADD minusOne
	JCS 0f
	LDA one
	STA num
0:
	.endm
		
new_game:
	CLR
	STA score
	STA delta
	stCell 0, 0
	stCell 1, 0
	stCell 2, 0
	stCell 3, 0
	stCell 0, 1
	stCell 1, 1
	stCell 2, 1
	stCell 3, 1
	stCell 0, 2
	stCell 1, 2
	stCell 2, 2
	stCell 3, 2
	stCell 0, 3
	stCell 1, 3
	stCell 2, 3
	stCell 3, 3
	CALL fillRNDcell
showScreen:
	STARTCOUNT
	CLR
	STA num
	zCell 0, 0
	zCell 1, 0
	zCell 2, 0
	zCell 3, 0
	zCell 0, 1
	zCell 1, 1
	zCell 2, 1
	zCell 3, 1
	zCell 0, 2
	zCell 1, 2
	zCell 2, 2
	zCell 3, 2
	zCell 0, 3
	zCell 1, 3
	zCell 2, 3
	zCell 3, 3
	LDA num
	ADD minusOne
	JCC skipFill
	CALL fillRNDcell
skipFill:
	LDA clrScreen
	OUT
	LDP scText
	STA cp
	CALL printString
	LDA score
	ADD delta
	STA score
	STA num
	CALL printDecimal
	LDA delta
	ADD minusOne
	JCC noDelta
	LDP delText
	STA cp
	CALL printString
	LDA delta
	STA num
	CALL printDecimal
	LDA ascRPar
	OUT
noDelta:newLine
	newLine
	CLR
	STA delta
	LDP lineText
	STA cp
	CALL printString
	newLine
	LDA ascVert
	OUT
	showCell 0, 0
	showCell 1, 0
	showCell 2, 0
	showCell 3, 0
	newLine
	LDP lineText
	STA cp
	CALL printString
	newLine
	LDA ascVert
	OUT
	showCell 0, 1
	showCell 1, 1
	showCell 2, 1
	showCell 3, 1
	newLine
	LDP lineText
	STA cp
	CALL printString
	newLine
	LDA ascVert
	OUT
	showCell 0, 2
	showCell 1, 2
	showCell 2, 2
	showCell 3, 2
	newLine
	LDP lineText
	STA cp
	CALL printString
	newLine
	LDA ascVert
	OUT
	showCell 0, 3
	showCell 1, 3
	showCell 2, 3
	showCell 3, 3
	newLine
	LDP lineText
	STA cp
	CALL printString
	newLine
	newLine
	LDP keysText
	STA cp
	CALL printString
	COUNT
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

doCells:.word 0
cell0:	.word 0
cell1:	.word 0
cell2:	.word 0
cell3:	.word 0

	.macro cmpCells from, to
	LDA doCells
	ADD minusOne
	JCC 0f
	LDA \from
	ADD minusOne
	JCC 1f
	LDA \from   /* not empty */
	SUB \to
	ADD minusOne
	JCS 0f      /* from != to */
	LDA \from
	ADD \from   /* could be to since from == to */
	STA \from
	CLR
	STA \to
	STA doCells  /* ignore further cells */
	LDA \from
	ADD delta
	STA delta
1:	LDA \to
	ADD minusOne
	JCC 0f      /* both empty */
	LDA \to
	STA \from   /* to ==> from */
	CLR
	STA \to     /* 0 ==> to */
0:
	.endm

cellBlock:
	.word 0
	LDA one
	STA doCells
	cmpCells cell0, cell1
	cmpCells cell0, cell2
	cmpCells cell0, cell3
	LDA one
	STA doCells
	cmpCells cell1, cell2
	cmpCells cell1, cell3
	LDA one
	STA doCells
	cmpCells cell2, cell3
	JMP cellBlock

	.macro colUp n
	ldCell \n, 0
	STA cell0
	ldCell \n, 1
	STA cell1
	ldCell \n, 2
	STA cell2
	ldCell \n, 3
	STA cell3
	CALL cellBlock
	LDA cell0
	stCell \n, 0
	LDA cell1
	stCell \n, 1
	LDA cell2
	stCell \n, 2
	LDA cell3
	stCell \n, 3
	.endm

moveUp:	colUp 0
	colUp 1
	colUp 2
	colUp 3
	JMP showScreen

	.macro colDown n
	ldCell \n, 3
	STA cell0
	ldCell \n, 2
	STA cell1
	ldCell \n, 1
	STA cell2
	ldCell \n, 0
	STA cell3
	CALL cellBlock
	LDA cell0
	stCell \n, 3
	LDA cell1
	stCell \n, 2
	LDA cell2
	stCell \n, 1
	LDA cell3
	stCell \n, 0
	.endm

moveDown:colDown 0
	colDown 1
	colDown 2
	colDown 3
	JMP showScreen

	.macro rowLeft n
	ldCell 0, \n
	STA cell0
	ldCell 1, \n
	STA cell1
	ldCell 2, \n
	STA cell2
	ldCell 3, \n
	STA cell3
	CALL cellBlock
	LDA cell0
	stCell 0, \n
	LDA cell1
	stCell 1, \n
	LDA cell2
	stCell 2, \n
	LDA cell3
	stCell 3, \n
	.endm

moveLeft:rowLeft 0
	rowLeft 1
	rowLeft 2
	rowLeft 3
	JMP showScreen

	.macro rowRight n
	ldCell 3, \n
	STA cell0
	ldCell 2, \n
	STA cell1
	ldCell 1, \n
	STA cell2
	ldCell 0, \n
	STA cell3
	CALL cellBlock
	LDA cell0
	stCell 3, \n
	LDA cell1
	stCell 2, \n
	LDA cell2
	stCell 1, \n
	LDA cell3
	stCell 0, \n
	.endm

moveRight:rowRight 0
	rowRight 1
	rowRight 2
	rowRight 3
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
	JMP 6f
2:	.word 0-\n
3:	LDA trim
	ADD minusOne
	JCC 6f
	LDA ascSpace
	OUT
6:
	.endm

printDecimal:
	.word 0
	LDA num
	ADD minusOne
	JCC printZero
	LDA one
	STA leadZ
	CLR
	STA trim
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

printCell:
	.word 0
	LDA one
	STA leadZ
	STA trim
	printDigit 10000
	printDigit  1000
	printDigit   100
	printDigit    10
	printDigit     1
	LDP cellText
	STA cp
	CALL printString
	JMP printCell
	
nextRND:.word 0
	CLR
	STA rndXor
	LDA rnd
	NOR rndM10
	ADD minusOne
	JCC test12
	LDA one
	STA rndXor
test12:	LDA rnd
	NOR rndM12
	ADD minusOne
	JCC test13
	LDA rndXor
	ADD one
	STA rndXor
test13:	LDA rnd
	NOR rndM13
	ADD minusOne
	JCC shift
	LDA rndXor
	ADD one
	STA rndXor
shift:	LDA minusOne
	ADD minusOne  /* 0xFFFE */
	NOR rndXor   /* just bit 0 */
	ADD rnd
	ADD rnd      /* rnd<<1 + rndXor&0x0001 */
	STA rnd
	JMP nextRND

fillRNDcell:
	.word 0
searchEmpty:
	CALL nextRND
	CALL nextRND /* pair of bits */
	LDA rnd
	NOR dbitMask
	STA x
	CALL nextRND
	CALL nextRND
	LDA rnd
	NOR dbitMask
	STA y
	CALL cell2num
	LDA num
	ADD minusOne
	JCS searchEmpty
	CALL nextRND
	LDA dbitMask
	ADD dbitMask  /* 0xFFF8 */
	NOR rnd     /* 0 to 7 */
	ADD minusOne
	JCC loadFour
	LDA two
	JMP fill
loadFour:LDA two
	ADD two
fill:	STA num
	CALL num2cell
	JMP fillRNDcell
two:	.word 2

cell2num:
	.word 0
	LDA y
	ADD y
	ADD y
	ADD y
	ADD x  /* 4*y + x */
	ADD 0f
	STA 1f
	CLR
1:	.word 0
	STA num
	JMP cell2num
0:	ADD tiles  /* template for tiles[0,0] */

num2cell:
	.word 0
	LDA y
	ADD y
	ADD y
	ADD y
	ADD x  /* 4*y + x */
	ADD 0f
	STA 1f
	LDA num
1:	.word 0
	JMP num2cell
0:	STA tiles  /* template for tiles[0,0] */
	
x:	.word 0
y:	.word 0	
char:	.word 0
cp:	.word 0
num:	.word 1
count:	.word 0
leadZ:	.word 0
trim:	.word 1
scText: .string16 "Score: "
delText:.string16 " (+"
keysText:.string16 "q=new game, wasd or ijkl=move"
rnd:	.word 0xA539
rndXor: .word 0
rndM10: .word 0xFBFF
rndM12:	.word 0xEFFF
rndM13:	.word 0xDFFF
dbitMask:.word 0xFFFC
nibbleMask: .word 0xFFF0
signMask: .word 0x8000
ascCR:	.word 0x0D
ascLF:	.word 0x0A
clrScreen:.word 0x0C
ascSpace:.word 0x20
ascRPar:.word 0x29
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
ascVert:.word 0x7C
score:	.word 0
delta:	.word 0
tiles:  .word 0,1024,0,4, 0,0,2,0, 16,0,0,0, 0,0,8,0
lineText:.string16 "-----------------------------"
cellText:.string16 " |"
