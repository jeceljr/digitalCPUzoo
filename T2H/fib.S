.include "t2h.inc"

    ldc -9371
    stl 1 # a in w+1
    ldc 1
    stl 2 # b in w+2
    ldc 0
    stl 3 # n in w+3
loop:
    ldlp 0
    call iterfib, 1
    ldl 3
    adc 1
    stl 3 # increment n
    ldl 3
    eqc 20
    cj loop # break if n = 20
break: j break, -2

iterfib:
    ajw -1 # Leave one space for temp store
    ldl 2
    ldnl 1 # Load a
    ldl 2
    ldnl 2 # Load b
    stl 0
    ldl 0 # Save temp = b
    add # b' = a + b
    ldl 2
    stnl 2 # Store b'
    ldl 0
    ldl 2
    stnl 1 # Store a' = temp in new position
    ajw 1
    ret
