.include "t2h.inc"

    ldc 0xFFE0
    gajw
    ldLabel mess, 1
    stl 0
loop:
    ldl 0
    ldnl 0
    dup
    cj halt
    dup
    ldc 0xFF
    and
    stl 0xF
    swb
    ldc 0xFF
    and
    stl 0xF
    ldl 0
    adc 2
    stl 0
    j loop

halt:
    j halt
    .align 2
mess:
    .ascii "Hello World!"
    .word 0, 0
