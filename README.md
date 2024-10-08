# digitalCPUzoo

Several simple processors, including existing ones, are reimplemented as schematics
using the [Digital simulator](https://github.com/hneemann/Digital).

## Basic blocks

The first project, *combinational*, is not actually a processor but a tour through the basic logic gates and other combinational circuits.

The second project, *sequential*, shows the basic sequential circuits.

Project *fpga* implements a simple, but functional, Field Programmable Gate Array.

## Working

*MCPU* is a very simple accumulator based 8 bit processor with only four instructions.

*NCPU* is similar to the *MCPU* but has two accumulators and a nicer instruction set.
It addresses 256 bytes of memory compared to just 64 for the *MCPU*.

*drv16* is a 16 bit processor that is compatible at the assembly language level with
the RV32E standard.

## Proposed

*NCPU16* is a 16 bit processor in the spirit of the 8 bit *NCPU* but even more similar
to the Data General Nova. The goal is to reduce the complexity of the control unit.

*retro8* is an 8 bit processor with 24 bit addresses and represents an attempt to
define an 8 bit processor that is nicer than the 6809.
