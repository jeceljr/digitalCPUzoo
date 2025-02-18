.nolist
        .org 0
absStart:


/* drv16 instructions */

/***** registers *****/

        .equ x0,   0
        .equ zero, 0
        .equ x1,   1
        .equ ra,   1
        .equ x2,   2
        .equ sp,   2
        .equ x3,   3
        .equ gp,   3
        .equ x4,   4
        .equ tp,   4
        .equ x5,   5
        .equ t0,   5
        .equ x6,   6
        .equ t1,   6
        .equ x7,   7
        .equ t2,   7
        .equ x8,   8
        .equ fp,   8
        .equ s0,   8
        .equ x9,   9
        .equ s1,   9
        .equ x10, 10
        .equ a0,  10
        .equ x11, 11
        .equ a1,  11
        .equ x12, 12
        .equ a2,  12
        .equ x13, 13
        .equ a3,  13
        .equ x14, 14
        .equ a4,  14
        .equ x15, 15
        .equ a5,  15

/***** instruction formats *****/

.macro  format_r op, d, a, b
        .word (\d<<12)+(\a<<8)+(\b<<4)+\op 
.endm

.macro  format_lib op, d, a, b
        .word (\b&0xFFF0)
        format_r \op, \d, \a, (\b&0x000F)
.endm

.macro  format_lid op, d, a, b
        .word (\d&0xFFF0)
        format_r \op, (\d&0x000F), \a, \b
.endm

.macro  format_ib op, d, a, b
	/* .if \b&0xFFF0 */
        format_lib \op, \d, \a, \b
        /* .else
        format_r \op, \d, \a, \b
        .endifi */
.endm

.macro  format_id op, d, a, b
        /* .if \d&0xFFF0 */
        format_lid \op, \d, \a, \b
        /* .else
        format_r \op, \d, \a, \b
        .endif */
.endm

/***** hardware instructions *****/

.macro	srs d, a, b
	format_r 0xc, \d, \a, \b
.endm

.macro	srsi d, a, b
	format_lib 0xc, \d, \a, \b
.endm

.macro  and d, a, b
        format_r 0xd, \d, \a, \b
.endm

.macro  andi d, a, b
        format_lib 0xd, \d, \a, \b
.endm

.macro  or d, a, b
        format_r 0xe, \d, \a, \b
.endm

.macro  ori d, a, b
        format_lib 0xe, \d, \a, \b
.endm

.macro  xor d, a, b
        format_r 0xf, \d, \a, \b
.endm

.macro  xori d, a, b
        format_lib 0xf, \d, \a, \b
.endm

.macro jal  d, b
	.set jOff, (\b-.)
        format_ib 1, \d, 0, (jOff-2) 
.endm

.macro  jalr d, a, b
        format_ib 1, \d, \a, (\b+1)
.endm

.macro  add d, a, b
        format_r 9, \d, \a, \b
.endm

.macro  addi d, a, b
        format_lib 9, \d, \a, \b
.endm

.macro  sub d, a, b
        format_r 0xa, \d, \a, \b
.endm

.macro  subi d, a, b
        format_lib 0xa, \d, \a, \b
.endm

.macro  slt d, a, b
        format_r 0xb, \d, \a, \b
.endm

.macro  slti d, a, b
        format_lib 0xb, \d, \a, \b
.endm

.macro  lh d, a, b
        format_ib 5, \d, \a, \b
.endm

.macro  lb d, a, b
        format_ib 4, \d, \a, \b
.endm

.macro  lbu d, a, b
        format_ib 8, \d, \a, \b
.endm

.macro  sh b, a, d
        format_id 7, \d, \a, \b
.endm

.macro  sb b, a, d
        format_id 6, \d, \a, \b
.endm

.macro  beq a, b, d
	.set jOff, (\d-.)
        format_id 2, (jOff-2), \a, \b
.endm

.macro  bne a, b, d
	.set jOff, (\d-.)
        format_id 2, (jOff-1), \a, \b
.endm

.macro  blt a, b, d
	.set jOff, (\d-.)
        format_id 3, (jOff-2), \a, \b
.endm

.macro  bge a, b, d
	.set jOff, (\d-.)
        format_id 3, (jOff-1), \a, \b
.endm

/***** RISC-V instructions not implemented in hardware *****/

/* sltiu, sltu, bltu, bgeu */

/* lui, auipc */
.macro  lui a, b
        addi \a, zero, \b
.endm
.macro  auipc a, b
        jal \a, .+2
        addi \a, \a, (\b-2)
.endm

/* slli, srli, srai */
.macro slli a, b, c
.if \c
	add \a, \b, \b
	slli2 \a, "(\c-1)"
.endif
.endm
.macro slli2 a, c
.if \c
	add \a, \a, \a
	slli2 \a, "(\c-1)"
.endif
.endm
.macro srli a, b, c
.if \c
	srs \a, \b, zero
	srli2 \a, "(\c-1)"
.endif
.endm
.macro srli2 a, c
.if \c
	srs \a, \a, zero
	srli2 \a, "(\c-1)"
.endif
.endm
.macro srai a, b, c
.if \c
	srs \a, \b, \b
	srai2 \a, "(\c-1)"
.endif
.endm
.macro srai2 a, c
.if \c
	srs \a, \a, \a
	srai2 \a, "(\c-1)"
.endif
.endm
/* sll, srl, sra */

/* ecall, ebreak */

/***** RISC-V pseudo-instructions *****/

.macro  nop
        addi zero,zero,0
.endm
.macro  li d, a
        addi \d,zero,\a
.endm
.macro  la d, a
        addi \d,zero,(\a-absStart)
.endm
.macro  mv d, a
        add \d, \a, zero
.endm
.macro  not d, a
        xori \d, \a, -1
.endm
.macro  neg d, a
        sub \d, zero, \a
.endm

/* seqz, snez, sltz, sgtz */

.macro  beqz a, b
        beq \a, zero, \b
.endm
.macro  bnez a, b
        bne \a, zero, \b
.endm
.macro  blez a, b
        bge zero, \a, \b
.endm
.macro  bgez a, b
        bge \a, zero, \b
.endm
.macro  bltz a, b
        blt \a, zero, \b
.endm
.macro  bgtz a, b
        blt zero, \a, \b
.endm
.macro  bgt d, a, b
        blt \a, \d, \b
.endm
.macro  ble d, a, b
        bge \a, \d, \b
.endm
.macro  bgtu d, a, b
        bltu \a, \d, \b
.endm
.macro  bleu d, a, b
        bgeu \a, \d, \b
.endm
.macro  j a
        jal zero, \a
.endm
.macro  jr a
        jalr zero, \a, 0
.endm
.macro  ret
        jalr zero, ra, 0
.endm

.list
