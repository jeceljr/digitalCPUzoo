.include "mcpu.inc"

start:
	NOR allone  # Akku = 0
	NOR b
	ADD one     # Akku = -b

	ADD a       # Akku = a-b
                    # carry set when akku >=0
	JCC neg

	STA a

	ADD allone
	JCC loop     # A=0 ? -> end, result in b

	JCC start
neg:
	NOR zero
	ADD one     # Akku = -Akku

	STA b
	JCC start  # carry was not altered
loop:
	JCC loop
	JCC loop

allone: .byte 0xFF
one:	.byte 1
zero:	.byte 0
a:	.byte 12
b:	.byte 18
