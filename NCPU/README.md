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

The *B* in this table really means *I*, *B* or *M* depending on *s*.
