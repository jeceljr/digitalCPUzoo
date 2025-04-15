# drv16b processor

The drv16b processor is based on the RISC-V standard but with only 16 registers
of 16 bits each. It implements fewer instructions than RV32E, but the ones it
does implement use the same mneomonic and have the same functionality.

In many cases drv16b will be used for helper functions in a project, like
abstracting the interface to a keyboard or SD card. Any logic taken up by drv16b
is logic not available to the main project. Just being 16 instead of 32 bits
should make it take half as much area as a RV32E processor and even less than
that relative to a RV32I. Such applications need very little memory so the
ability to address more than 64KB would be wasted. The use of an 8 bit datapath
further reduces the needed FPGA resources and eliminates the byte adapter
circuit present in the drv16.

An additional motivation for reducing state is to make it easier for people
to handle it. A 16 bit number like 0xC7F0 is more digestible than something
like 0xC7F0AA35, which is important in an educational context.

## Instructions

The binary encoding of the instructions is 16 bits but is not compatible with the
RISC-V C extension.

All other instructions have the format:

| 15 14 13 12 | 11 10 09 08 | 07 06 05 04 | 03 02 01 00 |
|-------------|-------------|-------------|-------------|
| rD | rS1 | rS2 | operation |

Register x0 holds the current program counter (PC), but when the rD field is
zero no register is changed and when rS1 or rS2 are zero the value 0 is used
in place of whatever is in x0.

The operation field indicates the instruction or group of instructions:

|      | xx00 | xx01 | xx10 | xx11 |
|------|------|------|------|------|
| 00xx | ADD  | SUB  | SLT  | SRS  |
| 01xx | AND  | OR   | XOR  | 1    |
| 10xx | ADDI | 3    | SLTI | JALR |
| 11xx | ANDI | ORI  | XORI | 2     |

For the immediate instructions, rS2 is replaced with a number from 1 to 15. Since
register x0 can be used as rS2 with the normal instructions for an immediate value
of 0, this encoding for an immediate instruction indicates that the actual immediate
value is in the 16 bits following the instruction.

For groups 1 and 2 the bottom two bits of rD select the actual instructions while the
top two bits are the immediate values 0, 1 or 2. If these bits are 3 then the actual
immediate value is in the 16 bits following the instruction.

Group 3 uses the same encoding but in the rS2 field.

- 1) BEQ, BNE, BLT, BGE
- 2) SB, SH
- 3) LB, LH, LBU, JAL

Missing relative to RV32E are unsigned comparisons (**SLTIU**, **SLTU**,
**BLTU**, **BGEU**). Also missing are  **LUI** and **AUI** since constants larger than
12 bits are generated differently.

The hardware to implement shifts can be very large compared to the rest of the
processor, so the shift operations (**SLLI**, **SRLI**, **SRAI**,
**SLL**, **SRL**, **SRA**) were also omitted. But the `SLLI x3,x4,3` can be
implemented using the sequence `ADD x3,x4,x4. ADD x3,x3,x3. ADD x3,x3,x3`.
Right shifts are implemented using the **SRS** (shift right step) instruction
that is not a RV32E one. So `SRAI x3,x4,3` can be implemented as the sequence
`SRS x3,x4,x4. SRS x3,x3,x3. SRS x3,x3,x3` while `SRLI x3,x4,3` can become
`SRS x3,x4,zero. SRS x3,x3,zero. SRS x3,x3,zero`.

**ECALL** and **EBREAK** are the two remaining RV32E instructions missing from drv16b.


