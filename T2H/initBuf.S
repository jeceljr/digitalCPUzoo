.include "t2h.inc"

    ldc 0xDF00
    gajw
    ldLabel buf
    stl 0
    ldc 4096
    ldc 0xE000
    stl 1
loop:
    dup
    cj halt
    adc -1
    ldl 0
    ldnl 0
    ldl 1
    stnl 0
    ldl 0
    adc 2
    stl 0
    ldl 1
    adc 2
    stl 1
    j loop

halt:
    j halt
    .align 2
buf:
.include "niver/buf.S"
