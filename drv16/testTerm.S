/** tests all drv16 instructions (eventually) and shows results in terminal **/

/* tests: prefix
 *
 * partially tests: li (addi ,zero,), sh, j (jal zero,)
 *
 * does not test: jalr, beq, bne, blt, bge,
 *                lb, lh, sb, lbu,
 *                add, sub, subi, slt, slti,
 *                srs, srsi, abd, andi, or, ori, xor, xori
 */

.include "drv16.inc"

	.equ term, 0xFFFE

loop:
	li a0, 0x35  /* "5" in ASCII */
	sh a0,zero,term
	j loop
