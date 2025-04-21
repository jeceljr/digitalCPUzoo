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


| op code | assembler | A | B | C | IP | W | O | Addr | dOut |
|---------|-----------|---|---|---|----|---|---|------|------|
| 0x      | j x       |   |   |   |IP+x|   | 0 |      |      |
| 1x      | ldlp x    |W+x| A | B |IP+1|   | 0 |      |      |
| 2x      |           |   |   |   |IP+1|   |O<<4 + x |  |    |
| 3x      | ldnl x    |dIn|   |   |IP+1|   | 0 | A+x  |      |
| 4x      | ldc x     | x | A | B |IP+1|   | 0 |      |      |
| 5x      | ldnlp x   |A+x|   |   |IP+1|   | 0 |      |      |
| 6x      |           |   |   |   |IP+1|   | 0xFFF0 + x |  | |
| 7x      | ldl x     |dIn| A | B |IP+1|   | 0 | W+x  |      |
| 8x      | adc x     |A+x|   |   |IP+1|   | 0 |      |      |
| 9x      | call x    |   |   |   |IP+x|   | 0 | W    | IP   |
| Ax      | cj x (A==0)|  |   |   |IP+x|   | 0 |      |      |
| Ax      | cj x (A!=0)| B| C | ? |IP+1|   | 0 |      |      |
| Bx      | ajw x     |   |   |   |IP+1|W+x| 0 |      |      |
| Cx      | eqc x     |A==x|  |   |IP+1|   | 0 |      |      |
| Dx      | stl x     | B | C | ? |IP+1|   | 0 | W+x  | A    |
| Ex      | stnl x    | C | ? | ? |IP+1|   | 0 | A+x  | B    |

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


| op code | assembler | A | B | C | IP | W | O | Addr | dOut |
|---------|-----------|---|---|---|----|---|---|------|------|
| F0      | rev       | B | A |   |IP+1|   | 0 |      |      |
| F1      | shl       |A<<1|  |   |IP+1|   | 0 |      |      |
| F2      | shr       |A>>1|  |   |IP+1|   | 0 |      |      |
| F3      | xor       |A^B| C | ? |IP+1|   | 0 |      |      |
| F4      |           |   |   |   |    |   |   |      |      |
| F5      | add       |A+B| C | ? |IP+1|   | 0 |      |      |
| F6      | gcall     |IP |   |   | A  |   | 0 |      |      |
| F7      | and       |A&B| C | ? |IP+1|   | 0 |      |      |
| F8      |           |   |   |   |    |   |   |      |      |
| F9      | gt        |B>A| C | ? |IP+1|   | 0 |      |      |
| FA      | dup       | A | A | B |IP+1|   | 0 |      |      |
| FB      | or        |A\|B| C| ? |IP+1|   | 0 |      |      |
| FC      | sub       |B-A| C | ? |IP+1|   | 0 |      |      |
| FD      | swb       |AL,AH| |   |IP+1|   | 0 |      |      |
| FE      | gajw      | W |   |   |IP+1| A | 0 |      |      |
| FF      | ret       |   |   |   |dIn |   | 0 | W    |      |

The *shl* and *shr* instructions shift by a single bit instead of
by the number of bits indicated in *B* like the Transputer, so a loop
is required in the general case.

The *swb* (swap bytes) is not a Transputer instruction and used to compensate
for the lack of the word length independent features. It helps deal with byte
data stored in the 16 bit word addressed data memory.
