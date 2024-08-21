.nolist
	.org 0
absStart:

    .equ r0, 0
    .equ r1, 1
    .equ r2, 2
    .equ pc, 3

	.macro format_branch op, addr
	.byte (\op | (0x0F & ((\addr-0f)-1)))
0:
	.endm

    .macro format_math op, dest, source
    .byte (\op | (\dest<<4) | (\source<<6))
    .endm

    .macro bcc addr
        format_branch 0xC0, \addr
    .endm

    .macro bcs addr
        format_branch 0xD0, \addr
    .endm

    .macro bzc addr
        format_branch 0xE0, \addr
    .endm

    .macro bzs addr
        format_branch 0xF0, \addr
    .endm

    .macro mov dest, source
        format_math 0x00, \dest, \source
    .endm

    .macro not dest, source
        format_math 0x01, \dest, \source
    .endm

    .macro add dest, source
        format_math 0x02, \dest, \source
    .endm

    .macro inc dest, source
        format_math 0x04, \dest, \source
    .endm

    .macro neg dest, source
        format_math 0x05, \dest, \source
    .endm

    .macro sub dest, source
        format_math 0x07, \dest, \source
    .endm

    .macro lda dest, source
        format_math 0x08, \dest, \source
    .endm

    .macro sta dest, source
        format_math 0x09, \dest, \source
    .endm

    .macro adc dest, source
        format_math 0x0A, \dest, \source
    .endm

    .macro sbb dest, source
        format_math 0x0B, \dest, \source
    .endm

    .macro ldi dest, source
        format_math 0x0C, \dest, 0
        .byte \source
    .endm

    .macro lea dest, addr
        ldi \dest, (\addr-absStart)
    .endm

    .macro and dest, source
        format_math 0x0D, \dest, \source
    .endm

    .macro or dest, source
        format_math 0x0E, \dest, \source
    .endm

    .macro xor dest, source
        format_math 0x0F, \dest, \source
    .endm

    .macro bne addr
        bzc \addr
    .endm
    
    .macro beq add
        bzs \addr
    .endm
    
    .macro jmp addr
        ldi pc, ((\addr-absStart)-1)
    .endm
    
    .macro nop
        mov r0, r0
    .endm
    
.list
