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

*T2H* is a Havard 16 bit processor with instructions based on the Inmos Transputer

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
| sieve bytes| 279     |        |        |        |         |        |          |             |          |          |
| sieve clocks| 456486 |        |        |        |         |        |          |             |          |          |
| 2048 puzzle lines |         | 567    |        |        |         |        |          |           |          |           |
| 2048 puzzle bytes |         | 3865   |        |        |         |        |          |           |          |           |
| 2048 puzzle clocks|         | 14250  |        |        |         |        |          |           |          |           |
| sine lines | 62      | 129    |        |        |         |        |          |           |          |              |
| sine bytes | 163     | 2403   |        |        |         |        |          |           |          |              |
| sine clocks| 23118   | 130831 |        |        |         |        |          |           |          |              |
| mandelbrot lines | 143     |        |        |        |         |        |          |           |          |            |
| mandelbrot bytes | 391     |        |        |        |         |        |          |           |          |            |
| mandelbrot clocks| 13726887|        |        |        |         |        |          |           |          |            |

The "gowin power" numbers are the total power in mW and in parenthesis the dynamic power (the
static power is always 121mW independent of the project).