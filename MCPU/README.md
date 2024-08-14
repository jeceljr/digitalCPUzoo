# MCPU

This simple 8 bit processor by Tim Böscke only implements 4 instructions and
can address 64 bytes of memory. More information as well as VHDL and Verilog
implementations can be found in (https://github.com/cpldcpu/MCPU).

The instructions are:

| assembler | binary | operation |
|-----------|--------|-----------|
| NOR addr  | 00?????? | Akku = ~(Akku | mem[addr]) |
| ADD addr  | 01?????? | Akku = Akku + mem[addr] |
| STA addr  | 10?????? | mem[addr] = Akku |
| JCC addr  | 11?????? | if carry == 0 then PC = addr; carry = 0 |

These instructions are defined as GNU AS macros in *mcpu.inc* so
an assembly program such as *gcd.S* which calculates the greatest
commond denominator can be assembled using the x86 version of as:

    as -a -o gcd.o gcd.S

where *gcd.S* includes *mcpu.inc*. The "-a" option creates a listing
on the terminal while "-o" selects a name different than a.out. The
next step is to convert the binary into a format that can be used
by the Digital simulator, such as Intel Hex:

    objcopy -S -O ihex gcd.o gcd.hex

The project *mcpu_bram.dig* uses an FPGA block RAM but has two bugs
in it: the carry bit is not being calculated correctly and there
should be a third cycle for the NOR and ADD instructions so they
can get the data from the memory.
