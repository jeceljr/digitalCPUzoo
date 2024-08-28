/** tests all drv16 instructions (eventually) and shows results in terminal **/

.include "drv16.inc"

	.equ term, 0xFFFE

loop:
	li a0, 0x35  /* "5" in ASCII */
	sh a0,zero,term
	j loop
