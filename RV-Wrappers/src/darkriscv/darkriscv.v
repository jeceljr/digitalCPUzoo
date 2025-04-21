/*
 * Copyright (c) 2018, Marcelo Samsoniuk
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * * Neither the name of the copyright holder nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

`timescale 1ns / 1ps

// implemented opcodes:

`define LUI     7'b01101_11      // lui   rd,imm[31:12]
`define AUIPC   7'b00101_11      // auipc rd,imm[31:12]
`define JAL     7'b11011_11      // jal   rd,imm[xxxxx]
`define JALR    7'b11001_11      // jalr  rd,rs1,imm[11:0]
`define BCC     7'b11000_11      // bcc   rs1,rs2,imm[12:1]
`define LCC     7'b00000_11      // lxx   rd,rs1,imm[11:0]
`define SCC     7'b01000_11      // sxx   rs1,rs2,imm[11:0]
`define MCC     7'b00100_11      // xxxi  rd,rs1,imm[11:0]
`define RCC     7'b01100_11      // xxx   rd,rs1,rs2
`define CCC     7'b11100_11      // exx, csrxx, mret

// proprietary extension (custom-0)
`define CUS     7'b00010_11      // cus   rd,rs1,rs2,fc3,fct5

// not implemented opcodes:
//`define FCC     7'b00011_11      // fencex


// configuration file

/*
 * Copyright (c) 2018, Marcelo Samsoniuk
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * * Neither the name of the copyright holder nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

//`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// darkriscv configuration
////////////////////////////////////////////////////////////////////////////////

// pipeline stages:
//
// 2-stage version: core and memory in different clock edges result in less
// clock performance, but less losses when the program counter changes
// (pipeline flush = 1 clock).  Works like a 4-stage pipeline and remember
// the 68040 clock scheme, with instruction per clock = 1.  alternatively,
// it is possible work w/ 1 wait-state and 1 clock edge, but with a penalty
// in performance (instruction per clock = 0.5).
//
// 3-stage version: core and memory in the same clock edge require one extra
// stage in the pipeline, but keep a good performance most of time
// (instruction per clock = 1).  of course, read operations require 1
// wait-state, which means sometimes the read performance is reduced.
`define __3STAGE__

// RV32I vs RV32E:
//
// The difference between the RV32I and RV32E regarding the logic space is
// minimal in typical applications with modern 5 or 6 input LUT based FPGAs,
// but the RV32E is better with old 4 input LUT based FPGAs.
//`define __RV32E__

// muti-threading support:
//
// Decreases clock performance by 20% (80MHz), but enables two or more
// contexts (threads) in the core. The threads work in symmetrical way,
// which means that they will start with the same exactly core parameters
// (same initial PC, same initial SP, etc). The boot.s code is designed
// to handle this difference and set each thread to different
// applications.
// Notes:
// a) threading is currently supported only in the 3-stage pipeline version.
// b) the old experimental "interrupt mode" was removed, which means that
//    the multi-thread mode does not make anything "visible" other than
//    increment the gpio register.
// c) the threading in the non-interrupt mode switches when the program flow
//    changes, i.e. every jal instruction. When the core is idle, it is
//    probably in a jal loop.
// The number of threads must be 2**n (i.e. THREADS = 3 means 8 threads)
//`define __THREADS__ 3
//
// mac instruction:
//
// The mac instruction is similar to other register to register
// instructions, but with a different opcode 7'h1111111.  the format is mac
// rd,r1,r2, but is not currently possible encode in asm, by this way it is
// available in licb as int mac(int rd, short r1, short r2).  Although it
// can be used to accelerate the mul/div operations, the mac operation is
// designed for DSP applications.  with some effort (low level machine
// code), it is possible peak 100MMAC/s @100MHz.
//`define __MAC16X16__

// flexbuzz interface (experimental):
//
// A new data bus interface similar to a well known c*ldfire bus interface, in
// a way that part of the bus routing is moved to the core, in a way that
// is possible support different bus widths (8, 16 or 32 bit) and endians more
// easily (the new interface is natively big-endian, but the endian can be adjusted
// in the bus interface dinamically). Similarly to the standard 32-bit interface,
// the external logic must detect the RD/WR operation quick enough and assert HLT
// in order to insert wait-states and perform the required multiplexing to fit
// the DLEN operand size in the data bus width available.
//`define __FLEXBUZZ__

// interrupt support
//
// The interrupt support in the core uses the machine registers mtvec and
// mepc, which means support the control special register instruction csrrw,
// in a way that is possible read/write the mtvec and mepc.
// the interrupt itself works like the thread switch, with the difference
// that:
// a) the PC will be saved in the mepc register
// b)the PC will receive the mtvec value
// c) single interrupt, which means that the mtvec offset is always zero
// The interrupt support cannot be used with threading (because makes no
// much sense?)... also, it requires the 3 stage pipeline (again, makes no
// much sense use it with the 2-stage pipeline).
//`define __INTERRUPT__

// initial PC
//
// Typically, the PC is set [by HW] to address 0, representing the start of
// ROM memory and the SP is set [by SW] to the final of RAM memory.  In the
// linker, the start of ROM memory matches with the .text area, which is
// defined in the boot.c code and the start of RAM memory matches with the
// .data and other volatile data, in a way that the stack can be positioned
// in the top of RAM and does not match with the .data.
`define __RESETPC__ 32'd0

////////////////////////////////////////////////////////////////////////////////
// darksocv configuration:
////////////////////////////////////////////////////////////////////////////////

// interactive simulation:
//
// When enabled, will trick the simulator in order to enable interactive
// access via the stdin, in a way that is possible type interactive commands,
// which will make your simulator crazy! unfortunately, it works only with
// iverilog... at least, Xilinx ISIM does not liket the $fgetc()
//`define __INTERACTIVE__

// performance measurement:
//
// The performance measurement can be done in the simulation level by
// eabling the __PERFMETER__ define, in order to check how the clock cycles
// are used in the core. The report is displayed when the FINISH_REQ signal
// is actived by the UART.
`define __PERFMETER__

// icarus register debug:
//
// As most people observed, the icarus verilog does not dump the register
// bank because icarus does not dump arrays by default. However, it is possible
// activate this special option in order to dump the register bank. This
// makes no effect in other simulators, but it appears as a warning.
//`define __REGDUMP__

// full harvard architecture:
//
// When defined, enforses that the instruction and data buses are connected
// to fully separate memory banks.  Although the darkriscv always use
// harvard architecture in the core, with separate instruction and data
// buses, the logic levels outside the core can use different architectures
// and concepts, including von neumann, wich a single bus shared by
// instruction and data access, as well a mix between harvard and von
// neumann, which is possible in the case of dual-port blockrams, where is
// possible connect two separate buses in a single memory bank.  the main
// advantage of a single memory bank is that the .text and .data areas can
// be better allocated, but in this case is not possible protect the .text
// area as in the case of separate memory banks.
// WARNING: this setup must match with the src/darksocv.ld.src file!
//`define __HARVARD__

// memory size:
//
// The current test firmware requires 8KB of memory, but it depends of the
// memory layout: whenthe I-bus and D-bus are both attached in the same BRAM,
// it is possible assume that 8MB is enough, but when the I-bus and D-bus are
// attached to separate memories, the I-BRAM requires around 5KB and the
// D-BRAM requires about 1.5KB. A safe solution is just simply and set the
// size as the same.
// The size is defined as 2**MLEN, i.e. the address bits used in the memory.
// WARNING: this setup must match with the src/darksocv.ld.src file!
`ifdef __HARVARD__
    `define MLEN 13 // MEM[12:0] ->  8KBytes LENGTH = 0x2000
`else
    `define MLEN 12 // MEM[12:0] -> 4KBytes LENGTH = 0x1000
    //`define MLEN 15 // MEM[12:0] -> 32KBytes LENGTH = 0x8000 for coremark!
`endif

// read-modify-write cycle:
//
// Generate RMW cycles when writing in the memory. This option basically
// makes the read and write cycle symmetric and may work better in the cases
// when the 32-bit memory does not support separate write enables for
// separate 16-bit and 8-bit words. Typically, the RMW cycle results in a
// decrease of 5% in the performance (not the clock, but the instruction
// pipeline eficiency) due to memory wait-states.
//`define __RMW_CYCLE__

// UART speed is set in bits per second, typically 115200 bps:
//`define __UARTSPEED__ 115200

// UART queue:
//
// Optional RX/TX queue for communication oriented applications. The concept
// foreseen 256 bytes for TX and RX, in a way that frames up to 128 bytes can
// be easily exchanged via UART.
//`define __UARTQUEUE__

////////////////////////////////////////////////////////////////////////////////
// board definition:
////////////////////////////////////////////////////////////////////////////////

// The board is automatically defined in the xst/xise files via Makefile or
// ISE. Case it is not the case, please define you board name here:
//`define AVNET_MICROBOARD_LX9
//`define XILINX_AC701_A200
//`define QMTECH_SDRAM_LX16

// the following defines are automatically defined:

`ifdef __ICARUS__
    `define SIMULATION 1
`endif

`ifdef XILINX_ISIM
    `define SIMULATION 2
`endif

`ifdef MODEL_TECH
    `define SIMULATION 3
`endif

`ifdef XILINX_SIMULATOR
    `define SIMULATION 4
`endif

// the board definition is done on the tool, otherwise we assume simulation

`ifdef AVNET_MICROBOARD_LX9
    `define BOARD_ID 1
    //`define BOARD_CK 100000000
    //`define BOARD_CK 66666666
    //`define BOARD_CK 40000000
    // example of DCM logic:
    `define BOARD_CK_REF 100000000
    `define BOARD_CK_MUL 6
    `ifdef __3STAGE__
        `define BOARD_CK_DIV 6 // 3-stage, 1-ws, 100MHz
    `else
        `define BOARD_CK_DIV 9 // 2-stage, 1-ws, 66MHz
    `endif
    `define XILINX6CLK 1
`endif

`ifdef XILINX_AC701_A200
    `define BOARD_ID 2
    //`define BOARD_CK 90000000
    `define BOARD_CK_REF 90000000
    `define BOARD_CK_MUL 4
    `define BOARD_CK_DIV 2
`endif

`ifdef QMTECH_SDRAM_LX16
    `define BOARD_ID 3
    `define BOARD_CK_REF 50000000
    `define BOARD_CK_MUL 4
    `define BOARD_CK_DIV 2
    `define INVRES 1
    `define XILINX6CLK 1
`endif

`ifdef QMTECH_SPARTAN7_S15
    `define BOARD_ID 4
    `define BOARD_CK_REF 50000000
    `define BOARD_CK_MUL 20
    `define BOARD_CK_DIV 10
    `define XILINX7CLK 1
    `define VIVADO 1
    `define INVRES 1
`endif

`ifdef LATTICE_BREVIA2_XP2
    `define BOARD_ID 5
    `define BOARD_CK 50000000
    `define INVRES 1
`endif

`ifdef LATTICE_ECP5_COLORLIGHTI9
    `define LATTICE_ECP5_PLL_REF25MHZ 1
    `define BOARD_ID 14
    `define BOARD_CK 125_000_000 // cause we use a pll with 25MHz ref clks
    `define INVRES 1
`endif

`ifdef LATTICE_ECP5_COLORLIGHTI5
    `define LATTICE_ECP5_PLL_REF25MHZ 1
    `define BOARD_ID 15
    `define BOARD_CK 125_000_000 // cause we use a pll with 25MHz ref clks
    `define INVRES 1
`endif

`ifdef LATTICE_ECP5_ULX3S
    `define LATTICE_ECP5_PLL_REF25MHZ 1
    `define BOARD_ID 16
    `define BOARD_CK 125_000_000 // cause we use a pll with 25MHz ref clks
    `define INVRES 1
`endif

`ifdef LATTICE_ICE40_BREAKOUT_HX8K
    `define BOARD_ID 17
    `define BOARD_CK 65_000_000 // cause we use a pll with 25MHz ref clks
    `define INVRES 1
`endif


`ifdef PISWORDS_RS485_LX9
    `define BOARD_ID 6
    `define BOARD_CK_REF 50000000
    `define BOARD_CK_MUL 4
    `define BOARD_CK_DIV 2
    `define INVRES 1
    `define XILINX6CLK 1
`endif

`ifdef DIGILENT_SPARTAN3_S200
    `define BOARD_ID 7
    `define BOARD_CK 50000000
    `define __RMW_CYCLE__
`endif

`ifdef ALIEXPRESS_HPC40GBE_K420
    `define BOARD_ID 8
    //`define BOARD_CK 200000000
    `define BOARD_CK_REF 100000000
    `define BOARD_CK_MUL 12
    `define BOARD_CK_DIV 5
    `define XILINX7CLK 1
    `define INVRES 1
`endif

`ifdef QMTECH_ARTIX7_A35
    `define BOARD_ID 9
    `define BOARD_CK_REF 50000000
    `define BOARD_CK_MUL 20
    `define BOARD_CK_DIV 10
    `define XILINX7CLK 1
    `define VIVADO 1
    `define INVRES 1
`endif

`ifdef ALIEXPRESS_HPC40GBE_XKCU040
    `define BOARD_ID 10
    //`define BOARD_CK 200000000
    `define BOARD_CK_REF 100000000
    `define BOARD_CK_MUL 8  // x8/2 = 400MHZ (overclock!)
    `define BOARD_CK_DIV 2  // vivado reco. = 250MHz
    `define XILINX7CLK 1
    `define INVRES 1
`endif

`ifdef PAPILIO_DUO_LOGICSTART
    `define BOARD_ID 11
    `define BOARD_CK_REF 32000000
    `define BOARD_CK_MUL 2
    `define BOARD_CK_DIV 2
    `define XILINX6CLK 1
`endif

`ifdef QMTECH_KINTEX7_K325
    `define BOARD_ID 12
    `define BOARD_CK_REF 50000000
    `define BOARD_CK_MUL 20
    `define BOARD_CK_DIV 4
    `define XILINX7CLK 1
    `define INVRES 1
`endif

`ifdef SCARAB_MINISPARTAN6_PLUS_LX9
    `define BOARD_ID 13
    `define BOARD_CK_REF 50000000
    `define BOARD_CK_MUL 4
    `define BOARD_CK_DIV 2
    // `define INVRES 0
    `define XILINX6CLK 1
`endif

`ifdef QMTECH_CYCLONE10_CL016
    `define BOARD_ID 17
    `define BOARD_CK 50000000
	 `define INVRES 1
	 `define MIFBRAM 1
    `define __RMW_CYCLE__
`endif


// to port to a new board, use TESTMODE to test:
// - the reset button is working
// - the LED is blinking at 1Hz
// - the UART is looped
//`define TESTMODE

`ifndef BOARD_ID
    `define BOARD_ID 0
    `define BOARD_CK 100000000
`endif

`ifdef BOARD_CK_REF
    `define BOARD_CK (`BOARD_CK_REF * `BOARD_CK_MUL / `BOARD_CK_DIV)
`endif

// darkuart baudrate automtically calculated according to board clock:

`ifndef __UARTSPEED__
  `define __UARTSPEED__ 115200
`endif

`define  __BAUD__ ((`BOARD_CK/`__UARTSPEED__))

// register number depends of CPU type RV32[EI] and number of threads

`ifdef __THREADS__
    `undef __INTERRUPT__

    `ifdef __RV32E__
        `define RLEN 16*(2**`__THREADS__)
    `else
        `define RLEN 32*(2**`__THREADS__)
    `endif
`else
    `ifdef __RV32E__
        `define RLEN 16
    `else
        `define RLEN 32
    `endif
`endif
module darkriscv
//#(
//    parameter [31:0] RESET_PC = 0,
//    parameter [31:0] RESET_SP = 4096
//)
(
    input             CLK,   // clock
    input             RES,   // reset
    input             HLT,   // halt

`ifdef __THREADS__
    output [`__THREADS__-1:0] TPTR,  // thread pointer
`endif

`ifdef __INTERRUPT__
    input             INT,   // interrupt request
`endif

    input      [31:0] IDATA, // instruction data bus
    output     [31:0] IADDR, // instruction addr bus

    input      [31:0] DATAI, // data bus (input)
    output     [31:0] DATAO, // data bus (output)
    output     [31:0] DADDR, // addr bus

`ifdef __FLEXBUZZ__
    output     [ 2:0] DLEN, // data length
    output            RW,   // data read/write
`else
    output     [ 3:0] BE,   // byte enable
    output            WR,    // write enable
    output            RD,    // read enable
`endif

    output            IDLE,   // idle output

    output [3:0]  DEBUG       // old-school osciloscope based debug! :)
);

    // dummy 32-bit words w/ all-0s and all-1s:

    wire [31:0] ALL0  = 0;
    wire [31:0] ALL1  = -1;

    reg XRES = 1;

`ifdef __THREADS__
    reg [`__THREADS__-1:0] XMODE = 0;     // thread ptr

    assign TPTR = XMODE;
`endif

    // decode: IDATA is break apart as described in the RV32I specification

`ifdef __3STAGE__

    reg [31:0] XIDATA;

    reg XLUI, XAUIPC, XJAL, XJALR, XBCC, XLCC, XSCC, XMCC, XRCC, XCUS, XCCC; //, XFCC, XCCC;

    reg [31:0] XSIMM;
    reg [31:0] XUIMM;

    always@(posedge CLK)
    begin
        XIDATA <= XRES ? 0 : HLT ? XIDATA : IDATA;

        XLUI   <= XRES ? 0 : HLT ? XLUI   : IDATA[6:0]==`LUI;
        XAUIPC <= XRES ? 0 : HLT ? XAUIPC : IDATA[6:0]==`AUIPC;
        XJAL   <= XRES ? 0 : HLT ? XJAL   : IDATA[6:0]==`JAL;
        XJALR  <= XRES ? 0 : HLT ? XJALR  : IDATA[6:0]==`JALR;

        XBCC   <= XRES ? 0 : HLT ? XBCC   : IDATA[6:0]==`BCC;
        XLCC   <= XRES ? 0 : HLT ? XLCC   : IDATA[6:0]==`LCC;
        XSCC   <= XRES ? 0 : HLT ? XSCC   : IDATA[6:0]==`SCC;
        XMCC   <= XRES ? 0 : HLT ? XMCC   : IDATA[6:0]==`MCC;

        XRCC   <= XRES ? 0 : HLT ? XRCC   : IDATA[6:0]==`RCC;
        XCUS   <= XRES ? 0 : HLT ? XRCC   : IDATA[6:0]==`CUS;
        //XFCC   <= XRES ? 0 : HLT ? XFCC   : IDATA[6:0]==`FCC;
        XCCC   <= XRES ? 0 : HLT ? XCCC   : IDATA[6:0]==`CCC;

        // signal extended immediate, according to the instruction type:

        XSIMM  <= XRES ? 0 : HLT ? XSIMM :
                 IDATA[6:0]==`SCC ? { IDATA[31] ? ALL1[31:12]:ALL0[31:12], IDATA[31:25],IDATA[11:7] } : // s-type
                 IDATA[6:0]==`BCC ? { IDATA[31] ? ALL1[31:13]:ALL0[31:13], IDATA[31],IDATA[7],IDATA[30:25],IDATA[11:8],ALL0[0] } : // b-type
                 IDATA[6:0]==`JAL ? { IDATA[31] ? ALL1[31:21]:ALL0[31:21], IDATA[31], IDATA[19:12], IDATA[20], IDATA[30:21], ALL0[0] } : // j-type
                 IDATA[6:0]==`LUI||
                 IDATA[6:0]==`AUIPC ? { IDATA[31:12], ALL0[11:0] } : // u-type
                                      { IDATA[31] ? ALL1[31:12]:ALL0[31:12], IDATA[31:20] }; // i-type
        // non-signal extended immediate, according to the instruction type:

        XUIMM  <= XRES ? 0: HLT ? XUIMM :
                 IDATA[6:0]==`SCC ? { ALL0[31:12], IDATA[31:25],IDATA[11:7] } : // s-type
                 IDATA[6:0]==`BCC ? { ALL0[31:13], IDATA[31],IDATA[7],IDATA[30:25],IDATA[11:8],ALL0[0] } : // b-type
                 IDATA[6:0]==`JAL ? { ALL0[31:21], IDATA[31], IDATA[19:12], IDATA[20], IDATA[30:21], ALL0[0] } : // j-type
                 IDATA[6:0]==`LUI||
                 IDATA[6:0]==`AUIPC ? { IDATA[31:12], ALL0[11:0] } : // u-type
                                      { ALL0[31:12], IDATA[31:20] }; // i-type
    end

    reg [1:0] FLUSH = -1;  // flush instruction pipeline

`else

    wire [31:0] XIDATA;

    wire XLUI, XAUIPC, XJAL, XJALR, XBCC, XLCC, XSCC, XMCC, XRCC, XCUS, XCCC; //, XFCC, XCCC;

    wire [31:0] XSIMM;
    wire [31:0] XUIMM;

    assign XIDATA = XRES ? 0 : IDATA;

    assign XLUI   = XRES ? 0 : IDATA[6:0]==`LUI;
    assign XAUIPC = XRES ? 0 : IDATA[6:0]==`AUIPC;
    assign XJAL   = XRES ? 0 : IDATA[6:0]==`JAL;
    assign XJALR  = XRES ? 0 : IDATA[6:0]==`JALR;

    assign XBCC   = XRES ? 0 : IDATA[6:0]==`BCC;
    assign XLCC   = XRES ? 0 : IDATA[6:0]==`LCC;
    assign XSCC   = XRES ? 0 : IDATA[6:0]==`SCC;
    assign XMCC   = XRES ? 0 : IDATA[6:0]==`MCC;

    assign XRCC   = XRES ? 0 : IDATA[6:0]==`RCC;
    assign XCUS   = XRES ? 0 : IDATA[6:0]==`CUS;
    //assign XFCC   <= XRES ? 0 : IDATA[6:0]==`FCC;
    assign XCCC   = XRES ? 0 : IDATA[6:0]==`CCC;

    // signal extended immediate, according to the instruction type:

    assign XSIMM  = XRES ? 0 : 
                     IDATA[6:0]==`SCC ? { IDATA[31] ? ALL1[31:12]:ALL0[31:12], IDATA[31:25],IDATA[11:7] } : // s-type
                     IDATA[6:0]==`BCC ? { IDATA[31] ? ALL1[31:13]:ALL0[31:13], IDATA[31],IDATA[7],IDATA[30:25],IDATA[11:8],ALL0[0] } : // b-type
                     IDATA[6:0]==`JAL ? { IDATA[31] ? ALL1[31:21]:ALL0[31:21], IDATA[31], IDATA[19:12], IDATA[20], IDATA[30:21], ALL0[0] } : // j-type
                     IDATA[6:0]==`LUI||
                     IDATA[6:0]==`AUIPC ? { IDATA[31:12], ALL0[11:0] } : // u-type
                                          { IDATA[31] ? ALL1[31:12]:ALL0[31:12], IDATA[31:20] }; // i-type
        // non-signal extended immediate, according to the instruction type:

    assign XUIMM  = XRES ? 0: 
                     IDATA[6:0]==`SCC ? { ALL0[31:12], IDATA[31:25],IDATA[11:7] } : // s-type
                     IDATA[6:0]==`BCC ? { ALL0[31:13], IDATA[31],IDATA[7],IDATA[30:25],IDATA[11:8],ALL0[0] } : // b-type
                     IDATA[6:0]==`JAL ? { ALL0[31:21], IDATA[31], IDATA[19:12], IDATA[20], IDATA[30:21], ALL0[0] } : // j-type
                     IDATA[6:0]==`LUI||
                     IDATA[6:0]==`AUIPC ? { IDATA[31:12], ALL0[11:0] } : // u-type
                                          { ALL0[31:12], IDATA[31:20] }; // i-type

    reg FLUSH = -1;  // flush instruction pipeline

`endif

`ifdef __THREADS__
    `ifdef __RV32E__

        reg [`__THREADS__-1:0] RESMODE = -1;

        wire [`__THREADS__+3:0] DPTR   = XRES ? { RESMODE, 4'd0 } : { XMODE, XIDATA[10: 7] }; // set SP_RESET when RES==1
        wire [`__THREADS__+3:0] S1PTR  = { XMODE, XIDATA[18:15] };
        wire [`__THREADS__+3:0] S2PTR  = { XMODE, XIDATA[23:20] };
    `else
        reg [`__THREADS__-1:0] RESMODE = -1;

        wire [`__THREADS__+4:0] DPTR   = XRES ? { RESMODE, 5'd0 } : { XMODE, XIDATA[11: 7] }; // set SP_RESET when RES==1
        wire [`__THREADS__+4:0] S1PTR  = { XMODE, XIDATA[19:15] };
        wire [`__THREADS__+4:0] S2PTR  = { XMODE, XIDATA[24:20] };
    `endif
`else
    `ifdef __RV32E__
        wire [3:0] DPTR   = XRES ? 0 : XIDATA[10: 7]; // set SP_RESET when RES==1
        wire [3:0] S1PTR  = XIDATA[18:15];
        wire [3:0] S2PTR  = XIDATA[23:20];
    `else
        wire [4:0] DPTR   = XRES ? 0 : XIDATA[11: 7]; // set SP_RESET when RES==1
        wire [4:0] S1PTR  = XIDATA[19:15];
        wire [4:0] S2PTR  = XIDATA[24:20];
    `endif
`endif

    wire [6:0] OPCODE = FLUSH ? 0 : XIDATA[6:0];
    wire [2:0] FCT3   = XIDATA[14:12];
    wire [6:0] FCT7   = XIDATA[31:25];

    wire [31:0] SIMM  = XSIMM;
    wire [31:0] UIMM  = XUIMM;

    // main opcode decoder:

    wire    LUI = FLUSH ? 0 : XLUI;   // OPCODE==7'b0110111;
    wire  AUIPC = FLUSH ? 0 : XAUIPC; // OPCODE==7'b0010111;
    wire    JAL = FLUSH ? 0 : XJAL;   // OPCODE==7'b1101111;
    wire   JALR = FLUSH ? 0 : XJALR;  // OPCODE==7'b1100111;

    wire    BCC = FLUSH ? 0 : XBCC; // OPCODE==7'b1100011; //FCT3
    wire    LCC = FLUSH ? 0 : XLCC; // OPCODE==7'b0000011; //FCT3
    wire    SCC = FLUSH ? 0 : XSCC; // OPCODE==7'b0100011; //FCT3
    wire    MCC = FLUSH ? 0 : XMCC; // OPCODE==7'b0010011; //FCT3

    wire    RCC = FLUSH ? 0 : XRCC; // OPCODE==7'b0110011; //FCT3
    wire    CUS = FLUSH ? 0 : XCUS; // OPCODE==7'b0110011; //FCT3
    //wire    FCC = FLUSH ? 0 : XFCC; // OPCODE==7'b0001111; //FCT3
    wire    CCC = FLUSH ? 0 : XCCC; // OPCODE==7'b1110011; //FCT3

`ifdef __THREADS__
    `ifdef __3STAGE__
        reg [31:0] NXPC2 [0:(2**`__THREADS__)-1];       // 32-bit program counter t+2
    `endif

    `ifdef __RV32E__
        reg [31:0] REGS [0:16*(2**`__THREADS__)-1];	// general-purpose 16x32-bit registers (s1)
    `else
        reg [31:0] REGS [0:32*(2**`__THREADS__)-1];	// general-purpose 32x32-bit registers (s1)
    `endif
`else
    `ifdef __3STAGE__
        reg [31:0] NXPC2;       // 32-bit program counter t+2
    `endif

    `ifdef __RV32E__
        reg [31:0] REGS [0:15];	// general-purpose 16x32-bit registers (s1)
    `else
        reg [31:0] REGS [0:31];	// general-purpose 32x32-bit registers (s1)
    `endif
`endif

    reg [31:0] NXPC;        // 32-bit program counter t+1
    reg [31:0] PC;		    // 32-bit program counter t+0

`ifdef SIMULATION
    integer i;
    
    initial for(i=0;i!=16;i=i+1) REGS[i] = 0;
`endif

    // source-1 and source-1 register selection

    wire          [31:0] U1REG = REGS[S1PTR];
    wire          [31:0] U2REG = REGS[S2PTR];

    wire signed   [31:0] S1REG = U1REG;
    wire signed   [31:0] S2REG = U2REG;


    // L-group of instructions (OPCODE==7'b0000011)

`ifdef __FLEXBUZZ__

    wire [31:0] LDATA = FCT3[1:0]==0 ? { FCT3[2]==0&&DATAI[ 7] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[ 7: 0] } :
                        FCT3[1:0]==1 ? { FCT3[2]==0&&DATAI[15] ? ALL1[31:16]:ALL0[31:16] , DATAI[15: 0] } :
                                        DATAI;
`else
    wire [31:0] LDATA = FCT3==0||FCT3==4 ? ( DADDR[1:0]==3 ? { FCT3==0&&DATAI[31] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[31:24] } :
                                             DADDR[1:0]==2 ? { FCT3==0&&DATAI[23] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[23:16] } :
                                             DADDR[1:0]==1 ? { FCT3==0&&DATAI[15] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[15: 8] } :
                                                             { FCT3==0&&DATAI[ 7] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[ 7: 0] } ):
                        FCT3==1||FCT3==5 ? ( DADDR[1]==1   ? { FCT3==1&&DATAI[31] ? ALL1[31:16]:ALL0[31:16] , DATAI[31:16] } :
                                                             { FCT3==1&&DATAI[15] ? ALL1[31:16]:ALL0[31:16] , DATAI[15: 0] } ) :
                                             DATAI;
`endif

    // S-group of instructions (OPCODE==7'b0100011)

`ifdef __FLEXBUZZ__

    wire [31:0] SDATA = U2REG; /* FCT3==0 ? { ALL0 [31: 8], U2REG[ 7:0] } :
                        FCT3==1 ? { ALL0 [31:16], U2REG[15:0] } :
                                    U2REG;*/
`else
    wire [31:0] SDATA = FCT3==0 ? ( DADDR[1:0]==3 ? { U2REG[ 7: 0], ALL0 [23:0] } :
                                    DADDR[1:0]==2 ? { ALL0 [31:24], U2REG[ 7:0], ALL0[15:0] } :
                                    DADDR[1:0]==1 ? { ALL0 [31:16], U2REG[ 7:0], ALL0[7:0] } :
                                                    { ALL0 [31: 8], U2REG[ 7:0] } ) :
                        FCT3==1 ? ( DADDR[1]==1   ? { U2REG[15: 0], ALL0 [15:0] } :
                                                    { ALL0 [31:16], U2REG[15:0] } ) :
                                    U2REG;
`endif

    // C-group: CSRRW

`ifdef __INTERRUPT__

    reg [31:0] MEPC  = 0;
    reg [31:0] MTVEC = 0;
    reg        MIE   = 0;
    reg        MIP   = 0;

    wire [31:0] CDATA = XIDATA[31:20]==12'h344 ? MIP  : // machine interrupt pending
                        XIDATA[31:20]==12'h304 ? MIE   : // machine interrupt enable
                        XIDATA[31:20]==12'h341 ? MEPC  : // machine exception PC
                        XIDATA[31:20]==12'h305 ? MTVEC : // machine vector table
                                                 0;	 // unknown

    wire MRET = CCC && FCT3==0 && S2PTR==2;
    wire CSRW = CCC && FCT3==1;
    wire CSRR = CCC && FCT3==2;
`endif
    wire EBRK = CCC && FCT3==0 && S2PTR==1;

    // RM-group of instructions (OPCODEs==7'b0010011/7'b0110011), merged! src=immediate(M)/register(R)

    wire signed [31:0] S2REGX = XMCC ? SIMM : S2REG;
    wire        [31:0] U2REGX = XMCC ? UIMM : U2REG;

    wire [31:0] RMDATA = FCT3==7 ? U1REG&S2REGX :
                         FCT3==6 ? U1REG|S2REGX :
                         FCT3==4 ? U1REG^S2REGX :
                         FCT3==3 ? U1REG<U2REGX : // unsigned
                         FCT3==2 ? S1REG<S2REGX : // signed
                         FCT3==0 ? (XRCC&&FCT7[5] ? U1REG-S2REGX : U1REG+S2REGX) :
                         FCT3==1 ? S1REG<<U2REGX[4:0] :
                         //FCT3==5 ?
                         !FCT7[5] ? S1REG>>U2REGX[4:0] :
`ifdef MODEL_TECH
                                   -((-S1REG)>>U2REGX[4:0]); // workaround for modelsim
`else
//                                   $signed(S1REG)>>>U2REGX[4:0];  // (FCT7[5] ? U1REG>>>U2REG[4:0] :
                                     ({{32{S1REG[31]}}, S1REG}>>U2REGX[4:0]);
`endif

`ifdef __MAC16X16__

    // MAC instruction rd += s1*s2 (OPCODE==7'b1111111)
    //
    // 0000000 01100 01011 100 01100 0110011 xor a2,a1,a2
    // 0000000 01010 01100 000 01010 0110011 add a0,a2,a0
    // 0000000 01100 01011 000 01010 0001011 mac a0,a1,a2
    //
    // 0000 0000 1100 0101 1000 0101 0000 1011 = 00c5850b

    wire MAC = CUS && FCT3==0;

    wire signed [15:0] K1TMP = S1REG[15:0];
    wire signed [15:0] K2TMP = S2REG[15:0];
    wire signed [31:0] KDATA = K1TMP*K2TMP;

`endif

    // J/B-group of instructions (OPCODE==7'b1100011)

    wire BMUX       = FCT3==7 && U1REG>=U2REG  || // bgeu
                      FCT3==6 && U1REG< U2REGX || // bltu
                      FCT3==5 && S1REG>=S2REG  || // bge
                      FCT3==4 && S1REG< S2REGX || // blt
                      FCT3==1 && U1REG!=U2REGX || // bne
                      FCT3==0 && U1REG==U2REGX; // beq

    wire [31:0] PCSIMM = PC+SIMM;
    wire        JREQ = JAL||JALR||(BCC && BMUX);
    wire [31:0] JVAL = JALR ? DADDR : PCSIMM; // SIMM + (JALR ? U1REG : PC);

    always@(posedge CLK)
    begin
`ifdef __THREADS__
        RESMODE <= RES ? -1 : RESMODE ? RESMODE-1 : 0;
        XRES <= |RESMODE;
`else
        XRES <= RES;
`endif

`ifdef __3STAGE__
	    FLUSH <= XRES ? 2 : HLT ? FLUSH :        // reset and halt
	                       FLUSH ? FLUSH-1 :
    `ifdef __INTERRUPT__
                            MRET ? 2 :
    `endif
	                       JREQ ? 2 : 0;  // flush the pipeline!
`else
        FLUSH <= XRES ? 1 : HLT ? FLUSH :        // reset and halt
                       JREQ;  // flush the pipeline!
`endif
`ifdef __INTERRUPT__
        if(XRES)
        begin
            MTVEC <= 0;
            MEPC  <= 0;
            MIP   <= 0;
            MIE   <= 0;
        end
        else
        if(MIP&&MIE&&JREQ)
        begin
            MEPC <= JVAL;
            MIP  <= 1;
            MIE  <= 0;
        end
        else
        if(CSRW)
        begin
            case(XIDATA[31:20])
                12'h305: MTVEC <= U1REG;
                12'h341: MEPC  <= U1REG;
                12'h304: MIE   <= U1REG;
            endcase
        end
        else
        if(MRET)
        begin
            MIP <= 0;
            MIE <= 1;
        end
        else
        if(INT==1&&MIE==1)
        begin
            MIP <= 1;
        end
`endif
`ifdef __RV32E__
        REGS[DPTR] <=   XRES||DPTR[3:0]==0 ? 0  :        // reset sp
`else
        REGS[DPTR] <=   XRES||DPTR[4:0]==0 ? 0  :        // reset sp
`endif
                       HLT ? REGS[DPTR] :        // halt
                       LCC ? LDATA :
                     AUIPC ? PCSIMM :
                      JAL||
                      JALR ? NXPC :
                       LUI ? SIMM :
                  MCC||RCC ? RMDATA:

`ifdef __MAC16X16__
                       MAC ? REGS[DPTR]+KDATA :
`endif
`ifdef __INTERRUPT__
                       CSRR ? CDATA :
`endif
                             REGS[DPTR];

`ifdef __3STAGE__

    `ifdef __THREADS__

        NXPC <= /*XRES ? `__RESETPC__ :*/ HLT ? NXPC : NXPC2[XMODE];

        NXPC2[XRES ? RESMODE : XMODE] <=  XRES ? `__RESETPC__ : HLT ? NXPC2[XMODE] :   // reset and halt
                                      JREQ ? JVAL :                            // jmp/bra
	                                         NXPC2[XMODE]+4;                   // normal flow

        XMODE <= XRES ? 0 : HLT ? XMODE :        // reset and halt
                            /*JAL*/ JREQ ? XMODE+1 : XMODE;
	             //XMODE==0/*&& IREQ*/&&JREQ ? 1 :         // wait pipeflush to switch to irq
                 //XMODE==1/*&&!IREQ*/&&JREQ ? 0 : XMODE;  // wait pipeflush to return from irq

    `else
        NXPC <= /*XRES ? `__RESETPC__ :*/ HLT ? NXPC : NXPC2;

	    NXPC2 <=  XRES ? `__RESETPC__ : HLT ? NXPC2 :   // reset and halt
        `ifdef __INTERRUPT__
                     MRET ? MEPC :
                    MIE&&MIP&&JREQ ? MTVEC : // pending interrupt + pipeline flush
        `endif
	                 JREQ ? JVAL :                    // jmp/bra
	                        NXPC2+4;                   // normal flow

    `endif

`else
        NXPC <= XRES ? `__RESETPC__ : HLT ? NXPC :   // reset and halt
        `ifdef __INTERRUPT__
                     MRET ? MEPC :
                    MIE&&MIP&&JREQ ? MTVEC : // pending interrupt + pipeline flush
        `endif
              JREQ ? JVAL :                   // jmp/bra
                     NXPC+4;                   // normal flow
`endif
        PC   <= /*XRES ? `__RESETPC__ :*/ HLT ? PC : NXPC; // current program counter

`ifndef __YOSYS__
//
//        if(EBRK)
//        begin
//            $display("breakpoint at %x",PC);
//            $stop();
//        end
//        
//        if(!FLUSH && IDATA===32'dx)
//        begin
//            $display("invalid IDATA at %x",PC);
//            $stop();  
//        end
//        
//        if(LCC && !HLT && DATAI===32'dx)
//        begin
//            $display("invalid DATAI@%x at %x",DADDR,PC);
//            $stop();
//        end
`endif

    end

    // IO and memory interface

    assign DATAO = SDATA; // SCC ? SDATA : 0;
    assign DADDR = U1REG + SIMM; // (SCC||LCC) ? U1REG + SIMM : 0;

    // based in the Scc and Lcc

`ifdef __FLEXBUZZ__
    assign RW      = !SCC;
    assign DLEN[0] = (SCC||LCC)&&FCT3[1:0]==0;
    assign DLEN[1] = (SCC||LCC)&&FCT3[1:0]==1;
    assign DLEN[2] = (SCC||LCC)&&FCT3[1:0]==2;
`else
    assign RD = LCC;
    assign WR = SCC;
    assign BE = FCT3==0||FCT3==4 ? ( DADDR[1:0]==3 ? 4'b1000 : // sb/lb
                                     DADDR[1:0]==2 ? 4'b0100 :
                                     DADDR[1:0]==1 ? 4'b0010 :
                                                     4'b0001 ) :
                FCT3==1||FCT3==5 ? ( DADDR[1]==1   ? 4'b1100 : // sh/lh
                                                     4'b0011 ) :
                                                     4'b1111; // sw/lw
`endif

`ifdef __3STAGE__
    `ifdef __THREADS__
        assign IADDR = NXPC2[XMODE];
    `else
        assign IADDR = NXPC2;
    `endif
`else
    assign IADDR = NXPC;
`endif

    assign IDLE = |FLUSH;
`ifdef __INTERRUPT__
    assign DEBUG = { INT, MIP, MIE, MRET };
`else
    assign DEBUG = { XRES, IDLE, SCC, LCC };
`endif

endmodule
