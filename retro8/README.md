# Retro 8

On June 21, 2013 Keith Clark wrote in the Retro Computing community in Google Plus:



> What about some Retro Computing community project ideas here.
> 
> 1.)  Design/build the ultimate 8 bit cpu.
> 2.)  Design/build the ultimate 8 bit computer
> 
> Both would be emulated in software, of course, so the sky would be the limit.  Pick open source, multi platform software to build with so everyone can participate.  A custom OS could be made for it, or several of them.
> 
> I don't know, just toying with ideas.  I know I had ideas of what the ultimate system would be in the late 70's, early 80's.  Maybe time to make them come to life!
> 
> Any interest in such an idea?

This is one suggestion.

## retro8 processor:

The goal is a clean and usable 8 bit processor (where the "8" in the name comes from) that could have reasonably existed when microcomputers were built around such processor (where the "retro" comes from).

A secondary goal is to clear up a misunderstanding: all popular 8 bit processors used 16 bit addresses so it is easy to think these two features go together. A pure 8 bit processor would also have 8 bit addresses and that would limit it to 256 bytes of memory. What some consider the first computer, [the Kenbak-1](https://en.wikipedia.org/wiki/Kenbak-1), is an example of this and the NCPU in this repository is another example. This can be educational, but not very practical. The solution is to have a hybrid architecture with some kind of address extension, like using a pair of registers for addresses. The first practical computer designed in Brazil, the ["Patinho Feio"](https://en.wikipedia.org/wiki/Patinho_Feio) (Ugly Duckling), was an 8 bit computer that used 12 bit addresses to handle 4KB of memory (it was later upgraded so indirect addressing could use 16 bits instead). A pure 16 bit architecture is limited to 64KB (or 128KB if it is word addressed) which is why the Intel 8086 had the segment scheme to extend that to 20 bits with a pair of 16 bit registers.

Retro8 uses a group of three 8 bit registers to generate its addresses, so can have up to 16MB of memory.

### Registers

12 registers in four triples

          11xx, 10xx, 01xx
    xx00: AH,   AM,   AL
    xx01: BH,   BM,   BL
    xx10: CH,   CM,   CL
    xx11: DH,   DM,   DL

byte in memory pointed by a triple (if not modified by prefix)

    0000: *A
    0001: *B
    0010: *C
    0011: *D

register triples in 24 bit instructions

    00: A
    01: B
    10: C
    11: D

alternative registers (only used by pushalt and popalt)

    00: PC - 24 bits
    01: SP - 24 bits
    10: Status - 8 bits: IL2 IL1 IL0 EI   Z N V C
    11:

### instruction formats

| first byte | binary | type | instructions |
|------------|--------|------|--------------|
| A0-AF | oooo ssss oooo dddd | combine source with destination | add, sub, addc, subb, mov, xor, or, and, shl, asr, shr, rot, mul, muh, mus, rotc |
| 00-7F | oooo dddd iiii iiii | combine immediate with destination | addi, subi, addci, subbi, movi, xori, ori, andi |
| C0-EF | oooo ssdd           | 24 bit operations, transfer source to destination | movl (d<=s), (*d<=s) or (d<=*s) |
| 80-9F | oooo oodd           | 24 bit operations, change destination | inc, dec, callr, jumpr, push, pop, pushalt, popalt |
| B0-BF | oooo cccc iiii iiii | branch on condition | br??, call (coded as brnv which has cccc=1111) |
| F0-FB | oooo oooo           | implied operands | cc, sc, cv, sv, cn, sn, cz, sz, di, ei, rti, brk |

Here is how the first byte is interpreted:

|    | x0    | x1    | x2    | x3    | x4    | x5    | x6    | x7    | x8    | x9    | xA    | xB    | xC    | xD    | xE    | xF    |
|----|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|
| 0x | addi  *A| addi  *B| addi  *C| addi  *D| addi  AL| addi  BL| addi  CL| addi  DL| addi  AM| addi  BM| addi  CM| addi  DM| addi  AH| addi  BH| addi  CH| addi  DH|
| 1x | subi  *A| subi  *B| subi  *C| subi  *D| subi  AL| subi  BL| subi  CL| subi  DL| subi  AM| subi  BM| subi  CM| subi  DM| subi  AH| subi  BH| subi  CH| subi  DH|
| 2x | addci *A| addci *B| addci *C| addci *D| addci AL| addci BL| addci CL| addci DL| addci AM| addci BM| addci CM| addci DM| addci AH| addci BH| addci CH| addci DH|
| 3x | subbi *A| subbi *B| subbi *C| subbi *D| subbi AL| subbi BL| subbi CL| subbi DL| subbi AM| subbi BM| subbi CM| subbi DM| subbi AH| subbi BH| subbi CH| subbi DH|
| 4x | movi  *A| movi  *B| movi  *C| movi  *D| movi  AL| movi  BL| movi  CL| movi  DL| movi  AM| movi  BM| movi  CM| movi  DM| movi  AH| movi  BH| movi  CH| movi  DH|
| 5x | xori  *A| xori  *B| xori  *C| xori  *D| xori  AL| xori  BL| xori  CL| xori  DL| xori  AM| xori  BM| xori  CM| xori  DM| xori  AH| xori  BH| xori  CH| xori  DH|
| 6x | ori   *A| ori   *B| ori   *C| ori   *D| ori   AL| ori   BL| ori   CL| ori   DL| ori   AM| ori   BM| ori   CM| ori   DM| ori   AH| ori   BH| ori   CH| ori   DH|
| 7x | andi  *A| andi  *B| andi  *C| andi  *D| andi  AL| andi  BL| andi  CL| andi  DL| andi  AM| andi  BM| andi  CM| andi  DM| andi  AH| andi  BH| andi  CH| andi  DH|
| 8x | inc24 A | inc24 B | inc24 C | inc24 D | dec24 A | dec24 B | dec24 C | dec24 D | callr A | callr B | callr C | callr D | jmpr A  | jmpr B  | jmpr C  | jmpr D  |
| 9x | push A  | push B  | push C  | push D  | pop A   | pop B   | pop C   | pop D   | push PC | push SP | push status |     | pop PC  | pop SP  | pop status |      |
| Ax | ? ?,*A  | ? ?,*B  | ? ?,*C  | ? ?,*D  | ? ?,AL  | ? ?,BL  | ? ?,CL  | ? ?,DL  | ? ?,AM  | ? ?,BM  | ? ?,CM  | ? ?,DM  | ? ?,AH  | ? ?,BH  | ? ?,CH  | ? ?,DH  |
| Bx | beq | bne | bnc | bc | bp | bn | bnv | bv | bge | blt | bgt | ble | bhi | bls | br | call |
| Cx |  | movl A,B | movl A,C | movl A,D | movl B,A |  | movl B,C | movl B,D | movl C,A | movl C,B |  | movl C,D | movl D,A | movl D,B | movl D,C |  |
| Dx | movl *A,A | movl *A,B | movl *A,C | movl *A,D | movl *B,A | movl *B,B | movl *B,C | movl *B,D | movl *C,A | movl *C,B | movl *C,C | movl *C,D | movl *D,A | movl *D,B | movl *D,C | movl *D,D |
| Ex | movl A,*A | movl A,*B | movl A,*C | movl A,*D | movl B,*A | movl B,*B | movl B,*C | movl B,*D | movl C,*A | movl C,*B | movl C,*C | movl C,*D | movl D,*A | movl D,*B | movl D,*C | movl D,*D |
| Fx | cc | sc | cv | sv | cn | sn | cz | sZ | di | ei | rti | brk |

The second byte is normally an immediate source or an offset for branches. The exception is for the line "Ax" in the above table, which defines the source for the instruction and is followed by a byte that defines the operation and destination:

|    | x0    | x1    | x2    | x3    | x4    | x5    | x6    | x7    | x8    | x9    | xA    | xB    | xC    | xD    | xE    | xF    |
|----|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|
| 0x | add *A,?| add *B,?| add *C,?| add *D,?| add AL,?| add BL,?| add CL,?| add DL,?| add AM,?| add BM,?| add CM,?| add DM,?| add AH,?| add BH,?| add CH,?| add DH,?|
| 1x | sub *A,?| sub *B,?| sub *C,?| sub *D,?| sub AL,?| sub BL,?| sub CL,?| sub DL,?| sub AM,?| sub BM,?| sub CM,?| sub DM,?| sub AH,?| sub BH,?| sub CH,?| sub DH,?|
| 2x | addc *A,?| addc *B,?| addc *C,?| addc *D,?| addc AL,?| addc BL,?| addc CL,?| addc DL,?| addc AM,?| addc BM,?| addc CM,?| addc DM,?| addc AH,?| addc BH,?| addc CH,?| addc DH,?|
| 3x | subb *A,?| subb *B,?| subb *C,?| subb *D,?| subb AL,?| subb BL,?| subb CL,?| subb DL,?| subb AM,?| subb BM,?| subb CM,?| subb DM,?| subb AH,?| subb BH,?| subb CH,?| subb DH,?|
| 4x | mov *A,?| mov *B,?| mov *C,?| mov *D,?| mov AL,?| mov BL,?| mov CL,?| mov DL,?| mov AM,?| mov BM,?| mov CM,?| mov DM,?| mov AH,?| mov BH,?| mov CH,?| mov DH,?|
| 5x | xor *A,?| xor *B,?| xor *C,?| xor *D,?| xor AL,?| xor BL,?| xor CL,?| xor DL,?| xor AM,?| xor BM,?| xor CM,?| xor DM,?| xor AH,?| xor BH,?| xor CH,?| xor DH,?|
| 6x | or *A,? | or *B,? | or *C,? | or *D,? | or AL,? | or BL,? | or CL,? | or DL,? | or AM,? | or BM,? | or CM,? | or DM,? | or AH,? | or BH,? | or CH,? | or DH,? |
| 7x | and *A,?| and *B,?| and *C,?| and *D,?| and AL,?| and BL,?| and CL,?| and DL,?| and AM,?| and BM,?| and CM,?| and DM,?| and AH,?| and BH,?| and CH,?| and DH,?|
| 8x | shl *A,?| shl *B,?| shl *C,?| shl *D,?| shl AL,?| shl BL,?| shl CL,?| shl DL,?| shl AM,?| shl BM,?| shl CM,?| shl DM,?| shl AH,?| shl BH,?| shl CH,?| shl DH,?|
| 9x | asr *A,?| asr *B,?| asr *C,?| asr *D,?| asr AL,?| asr BL,?| asr CL,?| asr DL,?| asr AM,?| asr BM,?| asr CM,?| asr DM,?| asr AH,?| asr BH,?| asr CH,?| asr DH,?|
| Ax | shr *A,?| shr *B,?| shr *C,?| shr *D,?| shr AL,?| shr BL,?| shr CL,?| shr DL,?| shr AM,?| shr BM,?| shr CM,?| shr DM,?| shr AH,?| shr BH,?| shr CH,?| shr DH,?|
| Bx | rot *A,?| rot *B,?| rot *C,?| rot *D,?| rot AL,?| rot BL,?| rot CL,?| rot DL,?| rot AM,?| rot BM,?| rot CM,?| rot DM,?| rot AH,?| rot BH,?| rot CH,?| rot DH,?|
| Cx | mul *A,?| mul *B,?| mul *C,?| mul *D,?| mul AL,?| mul BL,?| mul CL,?| mul DL,?| mul AM,?| mul BM,?| mul CM,?| mul DM,?| mul AH,?| mul BH,?| mul CH,?| mul DH,?|
| Dx | muh *A,?| muh *B,?| muh *C,?| muh *D,?| muh AL,?| muh BL,?| muh CL,?| muh DL,?| muh AM,?| muh BM,?| muh CM,?| muh DM,?| muh AH,?| muh BH,?| muh CH,?| muh DH,?|
| Ex | mus *A,?| mus *B,?| mus *C,?| mus *D,?| mus AL,?| mus BL,?| mus CL,?| mus DL,?| mus AM,?| mus BM,?| mus CM,?| mus DM,?| mus AH,?| mus BH,?| mus CH,?| mus DH,?|
| Fx | rotc *A,?| rotc *B,?| rotc *C,?| rotc *D,?| rotc AL,?| rotc BL,?| rotc CL,?| rotc DL,?| rotc AM,?| rotc BM,?| rotc CM,?| rotc DM,?| rotc AH,?| rotc BH,?| rotc CH,?| rotc DH,?|

### Interrupts

first 32 bytes in RAM are the interrupt table. Each entry has three bytes to be loaded into the PC and one into STATUS. There is no interrupt level 0, so the first four bytes are used by the brk instruction. The last 7 bytes in memory are loaded into the PC, STATUS and SP after a reset and are normally in ROM. An interrupt pushes the PC and STATUS to the stack and if the newly loaded STATUS doesn't have EI set then further interrupts will be ignored. When EI is set, interrupts at a lower or equal level than IL[2:0] are ignored.

24 bit values are stored in memory in little endian order, though that makes hex dumps harder to read.

## retro8+ processor:

The set of instructions described for retro8 are complete and make for a very
nice 8 bit processor that can elegantly handle 8MB of memory. 10 opcodes of
the possible 256 first bytes are not used, so for the enhanced retro8+ they
are defined as prefixes that modify the behavior of the following instruction,
From an interrupt point of view they are a part of the instruction. With the
prefix that adds a 3 byte displacement, the longest instruction can have 48 bits
(6 bytes: prefix, two bytes of instruction, 3 bytes of displacement).

C0, C5, CA, CF would be a 24 bit move from a register group to itself, so they
are instead defined to add A, B, C or D respectively as an offset to the
address. This can be either the source or the destination or even both,
depending on which are in memory and not a register.

9B and 9F would be push/pop an undefined alternate register so they are instead
defined to add 1 or 3, respectively, bytes that follow the instruction as an
offset to the address. Again, this might be the source, destination or both.

FC, FD, FE, FF would be implied operand instructions that haven't been defined,
so instead they modify the address to increment before, increment after,
decrement before and decrement after, respectively. Since the inc and dec
instructions are a single byte long, these prefixes are only interesting if both
source and destinations are addresses to be changed.

## PACKAGE/PINOUT

Most 8 bit microprocessors used 40 pin dual inline packages (DIP), either
ceramic or plastic. With 24 address lines instead of the usual 16 it is a bit
harder to fit retro8 there, but a very frugal interface should be possible:

    D0 to D7
    A0 to A23
    Read, Write and Wait
    Power and Ground
    Clock and Reset
    Interrupt

Missing is any way to allow other devices to take over the address and data
busses, so no DMA in this system.

It would be amusing to use an even smaller package like the EPROMs did. 24 pins,
for example. An option optimized for DRAMs could be:

    A16 to A23 / D0 to D7
    A8 to A15 / A0 to A7
    !RAS, !CAS and R!W
    Power and Ground
    Clock and Reset
    Interrupt

The MOS technologies of the 1970s could not switch their pins fast enough to
make this work, but in the mid 1980s this would be a practical option. The
!RAS signal should use external latches to save the top 16 address bits so
EPROMs and other non DRAM devices could be used. This is missing the Wait or
equivalent signal, so the Clock would have to be streched to achieve the
same result.

## alphabetical list of assembly instructions:

| hex | assembly | operation |
|-----|----------|-----------|
| As 0d |   add d,s    |  d += s |
| As 2d |   addc d,s   |  d += s + carry |
| 2d ii |   addci d,#i |  d += i + carry |
| 0d ii |   addi d,#i  |  d += i |
| As 7d |   and d,s    |  d &= s |
| 7d ii |   andi d,#i  |  d &= i |
| As 9d |   asr d,s    |  d >>= s |
| B3 ii |   bc         |  if c = 1 then pc += i |
| B1 ii |   beq        |  if z = 1 then pc += i |
| BC ii |   bhi        |  higher unsigned if !(z=1 \| c=0) then pc += i |
| B8 ii |   bge        |  if n^v = 0 then pc += i |
| BA ii |   bgt        |  if !(z=1 \| n^v) then pc += i |
| BB ii |   ble        |  if z=1 \| n^v then pc += i |
| BD ii |   bls        |  lower or same unsgined if z=1 \| c=0 then pc += i |
| B9 ii |   blt        |  if n^v = 1 then pc += i |
| B5 ii |   bn         |  if n = 1 then pc += i |
| B2 ii |   bnc        |  if c = 0 then pc += i |
| B0 ii |   bne        |  if z = 0 then pc += i |
| B6 ii |   bnv        |  if v = 0 then pc += i |
| B4 ii |   bp         |  if n = 0 then pc += i |
| BE ii |   br ii      |  pc += i |
| FB    |   brk        |  push PC, push Status, PC = *0 , Status = *3 |
| B7 ii |   bv         |  if v = 1 then pc += i |
| BF ii |   call ii    |  push pc , pc += i |
| 88-8B |   callr A-D  |  push pc , pc = d |
| F0    |   cc         |  c = 0 |
| F4    |   cn         |  n = 0 |
| F2    |   cv         |  v = 0 |
| F6    |   cz         |  z = 0 |
| 84-87 |   dec A-D    |  d -= 1 (24 bits) |
| F8    |   di         |  ei = 0 |
| F9    |   ei         |  ei = 1 |
| 80-83 |   inc A-D    |  d += 1 (24 bits) |
| 8C-8F |   jumpr A-D  |  pc = d |
| As 4d |   mov d,s    |  d = s |
| 4d ii |   movi d,#i  |  d = i |
| C?    |   movl d,s   |  d = s (24 bits) |
| D?    |   movl *d,s  |  *d = s (24 bits) |
| E?    |   movl d,*s  |  d = *s (24 bits) |
| As Dd |   muh d,s    |  d = ((unsigned) d * (unsigned) s) >> 8 |
| As Cd |   mul d,s    |  d = (0x00FF) d * s |
| As Ed |   mus d,s    |  d = (d * s) >> 8 |
| As 6d |   or d,s     |  d \|= s |
| 6d ii |   ori d,#i   |  d \|= i |
| 94-97 |   pop A-D | |
| 9C-9E |   pop PC, SP, Status | |
| 90-93 |   push A-D | |
| 98-9A |   push PC, SP, Status | |
| As Bd |   rot d,s    |  d = (d << s ) \| (d >> (8 - s)) |
| As Fd |   rotc d,s   |  t = (d >> (8 - s)) & 0x01 |
|       |              |  d = carry << s - 1 \| d << s \| (d >> (9 - s)) |
|       |              |  carry = t |
| FA    |   rti        |  pop Status , pop PC |
| F1    |   sc         |  c = 1 |
| As 8d |   shl d,s    |  d <<= s |
| As Ad |   shr d,s    |  (unsigned) d >>= s |
| F5    |   sn         |  n = 1 |
| As 1d |   sub d,s    |  d -= s |
| As 3d |   subb d,s   |  d -= s - carry |
| 1d ii |   subi d,#i  |  d -= i |
| 3d ii |   subbi d,#i |  d -= i - carry |
| F3    |   sv         |  v = 1 |
| F7    |   sz         |  z = 1 |
| As 5d |   xor d,s    |  d ^= s |
| 5d ii |   xori d,#i  |  d ^= i |

