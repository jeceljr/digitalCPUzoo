.nolist
.org 0
absStart:

/*** T2H indirect instructions ****/

    .macro rev
    .byte 0xF0
    .endm

    .macro shl
    .byte 0xF1
    .endm

    .macro shr
    .byte 0xF2
    .endm

    .macro xor
    .byte 0xF3
    .endm

    .macro add
    .byte 0xF5
    .endm

    .macro gcall
    .byte 0xF6
    .endm

    .macro and
    .byte 0xF7
    .endm

    .macro gt
    .byte 0xF9
    .endm

    .macro dup
    .byte 0xFA
    .endm

    .macro or
    .byte 0xFB
    .endm

    .macro sub
    .byte 0xFC
    .endm

    .macro swb
    .byte 0xFD
    .endm

    .macro gajw
    .byte 0xFE
    .endm

    .macro ret
    .byte 0xFF
    .endm

/**** T2H direct instrucitons ****/

    .macro fprfx num, pre
    .if \pre>>32  /* negative */
    fprfx (~(\num>>4)), (-1-\pre)
    .byte 0x60 | (\num&0x0f)
    .elseif \pre
    fprfx (\num>>4), (\pre-1)
    .byte 0x20 | (\num&0x0f)
    .endif
    .endm

    .macro prfx num
    .if \num>>32  /* negative */
    prfx (~(\num>>4)&0x0000FFFFFFFF)
    .byte 0x60 | (\num&0x0f)
    .elseif \num  /* not zero */
    prfx (\num>>4)
    .byte 0x20 | (\num&0x0f)
    .endif
    .endm

    .macro format_const op, value
    prfx (\value>>4)
    .byte \op | (\value & 0x0F)
    .endm

    .macro format_word op, offset
    prfx (\offset>>4)
    .byte \op | (\offset & 0x0F)
    .endm

    .macro format_byte op, dest, pre
    .set rel_dest_byte, \dest-0f
    fprfx ((rel_dest_byte)>>4), (\pre)
    .byte \op | ((rel_dest_byte) & 0x0F)
0:
    .endm

    .macro j x, pre=3
    format_byte 0x00, \x, \pre
    .endm

    .macro ldlp x
    format_word 0x10, \x
    .endm

    .macro ldnl x
    format_word 0x30, \x
    .endm

    .macro ldc x
    format_const 0x40, \x
    .endm

    .macro ldnlp x
    format_word 0x50, \x
    .endm

    .macro ldl x
    format_word 0x70, \x
    .endm

    .macro adc x
    format_const 0x80, \x
    .endm

    .macro call x, pre=3
    format_byte 0x90, \x, \pre
    .endm

    .macro cj x, pre=3
    format_byte 0xA0, \x, \pre
    .endm

    .macro ajw x
    format_const 0xB0, \x
    .endm

    .macro eqc x
    format_const 0xC0, \x
    .endm

    .macro stl x
    format_word 0xD0, \x
    .endm

    .macro stnl x
    format_word 0xE0, \x
    .endm

.list
