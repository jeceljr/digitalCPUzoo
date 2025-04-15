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

*drv16b* is a byte wide implementation of drv16 with a reorganized binary for the
instructions. The goal is to reduce the FPGA resources required at the cost of a
lower performance.

## Proposed

*NCPU16* is a 16 bit processor in the spirit of the 8 bit *NCPU* but even more similar
to the Data General Nova. The goal is to reduce the complexity of the control unit.

*retro8* is an 8 bit processor with 24 bit addresses and represents an attempt to
define an 8 bit processor that is nicer than the 6809.

*T2H* is a Havard 16 bit processor with instructions based on the Inmos Transputer

## RISC-V Wrappers

In the addition to the processor designs created in Digital, several third party
RISC-V processors written in Verilog have been included as Digital components in
order to run the same benchmarks.

They are:

- [SERV by Olof Kindgren](https://github.com/olofk/serv): a serial implementation trades off performance for small size by doing operations one bit at a time
- [Glacial by Eric Smith](https://github.com/brouhaha/glacial): this 8 bit implementation uses microcode to execute 32 bit RISC-V instructions
- [Darkriscv by Marcelo Samsoniuk](https://github.com/darklife/darkriscv): designed in a single night it is a very typical small RISC-V
- [PicoRV32 by Claire Xenia Wolf](https://github.com/YosysHQ/picorv32): created to fit into small FPGAs this is a popular option for embedded systems
- [Vexriscv by Papon Charles](https://github.com/SpinalHDL/VexRiscv): the SpinalHDL implementation offers many options, one of which is the exported Verilog used here

## Benchmarks

The benchmark programs are:

- *sieve.S*: calculates the first 1899 prime numbers using the "sieve of Erastothenes" method
- *term2048.S*: a terminal version of the 2048 puzzle game
- sine.S: a simple sine wave using only shifts
- mandelbrot.S: a text version of the famous fractal


|            | drv16   | MCPU16 | NCPU16 | T2H    | baby8   | SERV   | Glacial  |  Darkriscv  | PicoRV32 | Vexriscv |
|------------|--------:|-------:|-------:|-------:|--------:|-------:|---------:|------------:|---------:|---------:|
| Gowin LUTs | 282     | 69     |        |        |         | 264    | 249      | 1431        |          |          |
| Gowin FFs  | 33      | 48     |        |        |         | 182    | 84       | 176         |          |          |
| Gowin Fmax | 95MHz   | 313MHz |        |        |         | 127MHz | 176MHz   | 76MHz       |          |          |
| Gowin power| 140mW (19) | 138mW (17) |        |        |         | 183mW (62) | 135mW (14) | 178mW (57) |          |         |
| sieve lines| 129     |        |        |        |         |        |          |             |          |          |
| sieve bytes| 280     |        |        |        |         |        |          |             |          |          |
| sieve clocks| 456486 |        |        |        |         |        |          |             |          |          |
| sieve ps   | 208     |        |        |        |         |        |          |             |          |          |
| sine lines | 62      | 129    |        |        |         |        |          | 57        |          |              |
| sine bytes | 164     | 2403   |        |        |         |        |          | 128       |          |              |
| sine clocks| 23118   | 130831 |        |        |         |        |          | 9360      |          |              |
| sine ps    | 4109    | 2392   |        |        |         |        |          | 8120      |          |              |
| mandelbrot lines | 143     |        |        |        |         |        |          |           |          |            |
| mandelbrot bytes | 392     |        |        |        |         |        |          |           |          |            |
| mandelbrot clocks| 13726887|        |        |        |         |        |          |           |          |            |
| mandelbrot ps    | 7       |        |        |        |         |        |          |           |          |            |

The "gowin power" numbers are the total power in mW and in parenthesis the dynamic power (the
static power is always 121mW independent of the project).

Note that "lines" and "bytes" are exactly the same for all RISC-V processors so these numbers are only shown in the SERV column.

The "ps" lines are "per second" which is simply Fmax divided by the number of clock cycles taken up by each benchmark
and this represents absolute performance which can be directly compared between the different processors. In the
case of the sine benchmark this would be the frequency that would be heard if the output were sent to a speaker. In the
case of the mandelbrot benchmark this would be the frames per second that would be output in the case of an animation. This number
could be divided bu the number of LUTs to calculate the relativer perforamance per FPGA area or the power could be
divided by this number to obtain the energy (in Joules) used by each processor to generate the resule (another relative
measurement that might be interesting for estimating battery life).
