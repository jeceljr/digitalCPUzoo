# T2H

This 16 bit processor has instructions based on the Inmos T2xx Transputer.

It uses a three element stack with registers *A*, *B* and *C*. *W* is the
workspace pointer and local variables are stored in memory relative to it.
*IP* indicates the current instruction. 

None of the fancy Transputer features such as the communication links or
the operating system in hardware are included in T2H, The *H* in the name
indicates that unlike the Transputer which uses a von Neumann architecture,
the T2H uses a Harvard architecture with a byte wide instruction memory that
is separate from the 16 bit data memory. The Transputer uses byte addressing
and so a T2xx can have 64KB, but the T2H can have up to 64KB of instruction
memory in addition to 128KB (64K words) of data memory.

## Direct Instructions

The first instruction format is for the direct instructions where the top
4 bits of the instruction select the operation while the bottom 4 bits are
the data to be operated on. This is known as "one address" instructions.

Three of the 16 instructions are not independent but are used to modify the
following instructions. One is "operate" and uses the data as the opcode for
an indirect instruction (shown further down). The prefix and negative prefix
codes will combine its four bit data with the data of the following instruction
allowing a compact encoding of any sized data.


| op code | assembler | operation |
|---------|-----------|-----------|
| 0x      | j x       | IP <- IP+x, O <- 0 |
| 1x      | ldlp x    | A <- W+x, B <- A, C <- B, O <- 0 |
| 2x      |           | O <- O<<4 + x    |
| 3x      | ldnl x    | A <- mem[A+x], O <- 0 |
| 4x      | ldc x     | A <- x, B <- A, C <- B, O <- 0 |
| 5x      | ldnlp x   | A <- A+x, O <- 0 |
| 6x      |           | O <- 0xFFF0 + x |
| 7x      | ldl x     | A <- m[W+x], B <- A, C <- B, O <- 0 |
| 8x      | adc x     | A <- A+x, O <- 0 |
| 9x      | call x    | mem[W] <- IP, IP <- IP+x, O <- 0 |
| Ax      | cj x      | O <- 0, A == 0 ? IP <- IP+x : A <- B, B <- C, C <- ? |
| Bx      | ajw x     | O <- 0, W <- W+x |
| Cx      | eqc x     | A <- A==x, O <- 0 |
| Dx      | stl x     | m[W+x] <- A, A <- B, B <- C, C <- ?, O <- 0 |
| Ex      | stnl x    | m[A+x] <- B, A <- C, B <- ?, C <- ?, O <- 0 |
| Fx      |           | operate - indirect instructions |

The assembly names and opcode of the direct instructions are the same as the
Transputer, but two instructions have a slightly different operation. *call*
does not change *W* and only saves *IP* while the Transputer saves all registers
after changing "W" to have 4 new words. To save hardware the negative prefix does
not negate x and the previous *O* but instead loads a constant and unchanged x.

## Indirect Instructions

These are the "zero address" instructions which operate exclusively on the
internal stack. While the Transputer allows an arbitrary number of indirect
instructions using the prefixes and while these instructions are microcoded
and can be arbitrarily complex, T2H only uses the first 16 opcodes and limits
itself to one clock instructions.


| op code | assembler | operation |
|---------|-----------|-----------|     
| F0      | rev       | A <- B, B <- A          |
| F1      | shl       | A <- A<<1          |
| F2      | shr       | A <- A>>1          |
| F3      | xor       | A <- A^B, B <- C, C <- ?          |
| F4      |           |           |
| F5      | add       | A <- A+B, B <- C, C <- ?          |
| F6      | gcall     | A <- IP, IP <- A     |
| F7      | and       | A <- A&B, B <- C, C <- ?          |
| F8      |           |           |
| F9      | gt        | A <- B>A, B <- C, C <- ?          |
| FA      |           |           |
| FB      | or        | A <- A\|B, B <- C, C <- ?          |
| FC      | sub       | A <- B-A, B<- C, C <- ?          |
| FD      |           |           |
| FE      | gajw      | W <- A, A <- W          |
| FF      | ret       | IP <- mem[W]          |

The *shl* and *shr* instructions shift by a singlee bit instead of
by the number of bits indicated in *B* like the Transputer, so a loop
is required in the general case.