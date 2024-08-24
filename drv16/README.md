# drv16

The drv16 processor is based on the RISC-V standard but with only 16 registers
of 16 bits each. It implements fewer instructions than RV32E, but the ones it
does implement use the same mneomonic and have the same functionality.

In many cases drv16 will be used for helper functions in a project, like
abstracting the interface to a keyboard or SD card. Any logic taken up by drv16
is logic not available to the main project. Just being 16 instead of 32 bits
should make it take half as much area as a RV32E processor and even less than
that relative to a RV32I. Such applications need very little memory so the
ability to address more than 64KB would be wasted.

An additional motivation for reducing state is to make it easier for people
to handle it. A 16 bit number like 0xC7F0 is more digestible than something
like 0xC7F0AA35, which is important in an educational context.

## Performance

The priority is having a very small implementation, but performance is not too
bad for a multi-cycle processor. All instructions execute in two clock cycles
(*fetch* and *execute*) with an immediate extension word adding another cycle
before the *fetch* for a total of three clock cycle(multiple extensions can be
present resulting in more than three cycles, but only the last one is actually
used. Memory regions with all zeros will execute a sequence of extensions at
one clock per word).

The clock frequency is limited by the critical path which makes this processor
slower than a pipelined one, `clock cycle > IR delay + control unit delay +
register bank delay + alu input select delay + alu delay + address mux delay +
memory delay`.

## Instructions

The binary encoding of the instructions is 16 bits but is not compatible with the
RISC-V C extension. The most significant difference is the instruction which adds
12 bits to the 4 bit immediate value of the following instruction (it is treated
as a single 32 bit instruction).

All other instructions have the format:

| 15 14 13 12 | 11 10 09 08 | 07 06 05 04 | 03 02 01 00 |
|-------------|-------------|-------------|-------------|
| rD | rS1 | rS2 | operation |

Register x0 holds the current program counter (PC), but when the rD field is
zero no register is changed and when rS1 or rS2 are zero the value 0 is used
in place of whatever is in x0.

Using a non latched memory (an option for BRAMs in some FPGAs and
how external SRAM chips work) all instructions can run in two clock cycles
(fetch and execute). *PC* holds the address of the currently executing instruction
during the execute phase, so the address presented during fetch is the result
of adding 2 to *PC*. This has a side effect that the offset for **JAL** and the
branches is from the current instruction and not the next one like in RISC-V.
This is compensated for in the assembler to avoid complicating the hardware.
Since we have 16 bit instead of 12 bit offsets, this is not a limitation. The
offset for **JALR** does not need any changes since *PC* doesn't enter into
its calculation.

In the table below, **@rS2** indicates the 16 bit value in the register addressed
by the rS2 field of the instruction while a plain **rS2** indicates a 4 bit
immediate value extended to 16 bits from the start of a 32 bit instruction pair.
**rD** indicates a 4 bit immediate value that might be extended or not depending
on whether the previous instruction is par of a pair.

| operation | mnemonic | execute | fetch |
|-----------|----------|---------|-------|
| 0 |  |  | @IM := @IR, @IR := mem[@PC := @PC + 2] |
| 1 | JAL | @rD := @PC + 2 | @IR := mem[@PC := @PC + (@IM \| rS2)] |
| 1 | JALR | @rD := @PC + 2 | @IR := mem[@PC := @rS1 + (@IM \| rS2)] |
| 2 | BEQ | cond := @rS1 = @rS2 | @RI := mem[@PC := @PC + (cond?(@IM \| rD):2)] |
| 2 | BNE | cond := @rS1 ~= @rS2 | @RI := mem[@PC := @PC + (cond?(@IM \| rD):2)] |
| 3 | BLT | cond := @rS1 < @rS2 | @RI := mem[@PC := @PC + (cond?(@IM \| rD):2)]] |
| 3 | BGE | cond := @rS1 \>= @rS2 | @RI := mem[@PC := @PC + (cond?(@IM \| rD):2)] |
| 4 | LB | @rD := SignExtend(mem[@rS1 + (@IM \| rS2)]) | @IR := mem[@PC := @PC + 2] |
| 5 | LH | @rD := mem[@rS1 + (@IM \| rS2)] | @IR := mem[@PC := @PC + 2] |
| 6 | SB | mem[@rS1 + rD] := 8Bits(@rS2) | @IR := mem[@PC := @PC + 2] |
| 7 | SH | mem[@rS1 + rD] := @rS2 | @IR := mem[@PC := @PC + 2] |
| 8 | LBU | @rD := ZeroExtend(mem[@rS1 + (@IM \| rS2)]) | @IR := mem[@PC := @PC + 2] |
| 9 | ADD | @rD := @rS1 + @rS2 | @IR := mem[@PC := @PC + 2] |
| 9 | ADDI | @rD := @rS1 + (@IM \| rS2) | @IR := mem[@PC := @PC + 2] |
| A | SUB | @rD := @rS1 - @rS2 | @IR := mem[@PC := @PC + 2] |
| A | SUBI | @rD := @rS1 - (@IM \| rS2) | @IR := mem[@PC := @PC + 2] |
| B | SLT | @rD := @rS1 < @rS2 | @IR := mem[@PC := @PC + 2] |
| B | SLTI | @rD := @rS1 < (@IM \| rS2) | @IR := mem[@PC := @PC + 2] |
| C | SRS | @rD := (@rS1>>1) \| (@rS2 & 0x8000) | @IR := mem[@PC := @PC + 2] |
| C | SRSI | @rD := (@rS1>>1) \| (@IM & 0x8000) | @IR := mem[@PC := @PC + 2] |
| D | AND | @rD := @rS1 & @rS2 | @IR := mem[@PC := @PC + 2] |
| D | ANDI | @rD := @rS1 & (@IM \| rS2) | @IR := mem[@PC := @PC + 2] |
| E | OR | @rD := @rS1 \| @rS2 | @IR := mem[@PC := @PC + 2] |
| E | ORI | @rD := @rS1 \| (@IM \| rS2) | @IR := mem[@PC := @PC + 2] |
| F | XOR | @rD := @rS1 ^ @rS2 | @IR := mem[@PC := @PC + 2] |
| F | XORI | @rD := @rS1 ^ (@IM \| rS2) | @IR := mem[@PC := @PC + 2] |

Most instructions have two variations and the presence or not of the extension
selects between them. In the case of **BEQ** and **BNE** it is the least
significant bit of **rD** (extended or not) that selects between them as the
bit would otherwise be wasted since we can't branch or odd addresses. The same
trick is used to select between **JAL** and **JALR**.

drv16 has a **SUBI** instruction that RV32E lacks (since it can have negative
constants for **ADDI**). Missing are unsigned comparisons (**SLTIU**, **SLTU**,
**BLTU**, **BGEU**). Also missing are  **LUI** and **AUI** since constants larger than
12 bits are generated differently.

The hardware to implement shifts can be very large compared to the rest of the
processor, so the shift operations (**SLLI**, **SRLI**, **SRAI**,
**SLL**, **SRL**, **SRA**) were also omitted. But the `SLLI x3,x4,3` can be
implemented using the sequence `ADD x3,x4,x4. ADD x3,x3,x3. ADD x3,x3,x3`.
Right shifts are implemented using the **SRS** (shift right step) instruction
that is not a RV32E one. So `SRAI x3,x4,3` can be implemented as the sequence
`SRS x3,x4,x4. SRS x3,x3,x3. SRS x3,x3,x3` while `SRLI x3,x4,3` can become
`SRS x3,x4,zero. SRS x3,x3,zero. SRS x3,x3,zero`. The **SRSI** instruction is
present to simplify the hardware, but is not as useful.

**ECALL** and **EBREAK** are the two remaining RV32E instructions missing from drv16.

## Implementation

![top level](system.svg)

The project *system.dig* includes the drv16 processor connected to an asynchronous RAM
with 32K words of 16 bits each. Address 0xFFFE (word address 0x7FFF) is also mapped
to the terminal.

![drv16](drv16.svg)

Two complications that RISC-V shares with drv16 relative to some simpler processors are
the byte access to memory and the special treatment of register zero. This is further
complicated in drv16 by storing the program counter in the register bank's address zero
since that would have been otherwise unused. This also allows the adder in the ALU to
also increment the program counter.

### Datapath

![ALU](alu.svg)

Looking at all instructions, we need to be able to add and substract a pair of 16 bit
number, do a bitwise *AND*, *OR* and *XOR* operations between them and also handle the
odd shift to the right combining with a bit from the other operand. When subtracting
we need to indicate the signed compatisons `A >= B` and `A != B`.

![ALU input adaptor](adapt.svg)

While the most common operations use the registers selected by fields *rS1* and *rS2*
as operands, the exceptions mean we can't just connect the register outputs to the ALU.
When the fields are 0 the data must be 0 instead of the PC which is actually stored
there. For incrementing the PC we replace 0 with 2 as the constant. In addition, it
is possible to have an immediate value as the second operand. The bottom bits of the
immediate can come from either field *rS2* or *rD* of the instruction (following the
RISC-V philosophy of not using field *rD* for a source in store or branch instructions).
The bottom bit of the immediate can be forced to 0 while its actual value is reported.

![word to byte adaptation](bytes.svg)

Normally writing bytes to wider memory is implemented by having a per byte chip enable
signal. For simulations in Digital it is easier to have a single, wide memory as the tool
can then easily load an Intel Hex file before simulation starts. With memories that have
separate Data In and Data Out pins, an option is to just write back the bytes that are
not supposed to be changed.

| word | A0 | rD[15:8] | rD[7:0] | dOut[15:8] | dOut[7:0] |
|------|----|----------|---------|------------|-----------|
| 0    | 0  | 8x(sign&rD[7] | dIn[7:0] | dIn[15:8] | rS2[7:0] |
| 0    | 1  | 8x(sign&rD[7] | dIn[15:8] | rS2[7:0] | dIn[7:0] |
| 1    | x  | dIn[15:8] | dIn[7:0] | rS2[15:8] | rS2[7:0] |

The table indicates how the various 8 bit multiplexers are controlled by the signals *word* (IR[0]),
*A0* and *sign* (/IR[3]). Only the multiplexer for dOut[15:8] needs more than two inputs and is best
implemented as a sequence of two selectors of two inputs each.

### Control Unit

The control unit uses the following inputs to do its job: *clock*, *reset*, *dIn*, *alt*,
*NE* and *GE*. It generates: *wr*, *rd*, *sign*, *word*, *sub*, *logic*, *logSelect*, *topImm*, *even*,
*const2*, *selImm*, *selConst*, *Azero*, *we*, *Rw*, *Ra*, *Rb*, *selRd* and *selAddr*.

![r0 handling](r0.svg)

This simple circuit helps handle register zero. It allows any of the three instruction
fields to be overridden by the PC and indicates if special handling (replace with 0 for
the sources and don't write for the destination) is needed.

![control unit](controlUnit.svg)

*IR* saves the instruction read from memory during the fetch cycle. *IM* saves the previous value of
the top 12 bits for *IM* for prefix instructions or is cleared to 0 at the end of all other
instructions.
