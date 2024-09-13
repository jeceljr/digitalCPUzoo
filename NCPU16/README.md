# NCPU16

One interesting feature of the Data General Nova was that the instructions were defined such that individual bits directly controlled part of the datapath. This was not the case for the 8 bit *NCPU* where the complexity of the control unit far exceeded that of the datapath.

With 16 bit instructions it is possible to simplify the design of the control unit.

The compute instructions have this format:

| 15 14 | 13 12 11 | 10 09 08 | 07 | 06 05 04 | 03 02 | 01 00 |
|-------|----------|----------|----|----------|-------|-------|
| 0 0   | dest     | source   | nsv| ALU      | shift | skip  |

The *dest* and *source* fields select one of eight registers to be the destination and source A of an operation and the second source of the operaion. The *nsv* bit stops the result of the operation being saved back into the *dest* register. Register 7 is used as the program counter.

The eight operations selected by *ALU* are: A+B, A-B, A+1, A-1, B, A&B, A|B and A^B. The mneomonics are: *ADD*, *SUB*, *INC*, *DEC*, *MOV*, *AND*. *OR* and *XOR*.

The four possiblities for the rotation circuit selected by *shift* are rotate right by: 0, 1, 4 and 8 (swap bytes).

The four conditions to skip the following instruction selected by *skip* are: don't skip, skip if carry clear, skip if zero, skip if not zero

The memory instructions have this format:

| 15 14 | 13 12 11 | 10 09 08 | 07 06 05 04 03 02 01 00 |
|-------|----------|----------|-------------------------|
| mem   | reg      | index    | offset                  |

The two bits of *mem* can't be 0 0 (that would be a compute instruction) and indicate: *LDA*, *STA* and *LEA*. The effective address is the value in the index register added to the signed extension of the 8 bit offset (so -128 to +127). *LDA* will read a 16 bit word from that address and load it into the accumulator indicated by *reg*, while *STA* will transfer a word in the other direction. *LEA*, meaning "load effective address" will save the calculated address into *reg*.

To do a subroutine call pushing the return address on a stack pointed to by r6 (always pointing to the first empty word) requires several instructions:

           LEA r0,r7,retAddr-.
           STA r0,r6,0
           DEC r6
           LDA r7,r7,1
           .word subAddr
       retAddr:

And to go back to the previous routine:

            INC r6
            LDA r7,r6,0

