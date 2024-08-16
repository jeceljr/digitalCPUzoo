# NCPU

This simple 8 bit processor was inspired by the MCPU (hence the similar name),
the Data General Nova (so the "N" in the name) and has a lot in common with
the Femto8 from Steven Hugg's book "Designing Video Game Hardware in Verilog"
and used in the [8 Bit Workshop](https://8bitworkshop.com/) tool.

There are two instruction formats:

| 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|
| s | s | d | d | c | c | a | i |
| 1 | 1 | t | t | b | b | b | b |

The second format is for conditional branches. The *t* field selects between
different tests on the two flags (carry=0, carry=1, zero=0 or zero=1) and the
"b" field is how much to add to the program counter (*P*) if the test passes.

*d* indicates where the result of an option is stored (accumulator *A*,
accumulator *B*, memory addressed by B indicated as *M* or the program
counter *P*).

*s* indicates where the second source (the first is always the accumulator *A*)
of the operation comes from (an immediate value following the instrucion *I*,
the accumlator *B* or memory addressed by B *M*). The *s* field can only be 0,
1 or 2.

*c* indicates where the carry in comes from (always 0, always 1, the C register
or this is a logical operation instead of an addition). *a* means accumulator
is added and *i* means input b is bitwise inverted. The possible operations are:

| carry | a=0, i=0 | a=0, i=1 | a=1, i=0 | a=1, i-1 |
|-------|----------|----------|----------|----------|
| 0     | B        | not B    | A+B      | A-B-1    |
| 1     | B+1      | 0-B      | A+B+1    | A-B      |
| C     | B+C      | (1-C)-B  | A+B+C    | A-B+(1-C)|
| logic | A or B   | A xor B  | A and B  | A        | 

The *B* in this table really means *I*, *B* or *M* depending on *s*. Four of these
operations are unlikely to be useful but are a side effect of how the ALU is
designed.

The first letter in an assembly instruction selects the destination and can be
"a", "b", "m" or "p". The next letters select the function and can be
"b", "not", "add", ?, "inc", "neg", ?, "sub",
?, ?, "addc", "subc", "or", "xor", "and", "a". The final letter indicates the
source and can be "i", nothing or "m". In the first case there is also an
expression that generates the second byte in the instruction. That means that
there are 4 times 12 times 3 possible mnemonics, 144 in all.

There are 4 more mnemonics for the branches, but given the use of "b" above to
indicate a destination these will instead be "jcc", "jcs", "jzc" and "jzs". It
might seem odd to only have condiction branches and with such a limited range
but "pbi 210" can be used to jump to location 210.

![test ALU](alu_test.svg)

The circuit *alu_test.dig* is a test to see what the complexity of the ALU needed
for the NCPU is and how long it takes to create it. So far 12 of the 16 functions
have been tested. The *enable* pins of the *C* and *Z* registers are not connected
correctly but it is enough to implement the remaining 4 tests.
