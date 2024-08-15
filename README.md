# digitalCPUzoo

Several simple processors, including existing ones, are reimplemented as schematics
using the [Digital simulator](https://github.com/hneemann/Digital).

The first project, *combinational*, is not actually a processor but a tour through the basic logic gates and other combinational circuits.

The second project, *sequential*, shows the basic sequential circuits.

Project *fpga* implements a simple, but functional, Field Programmable Gate Array.

*MCPU* is a very simple accumulator based 8 bit processor with only four instructions.

*NCPU* is similar to the *MCPU* but has two accumulators and a nicer instruction set.
It addresses 256 bytes of memory compared to just 64 for the *MCPU*.
