/* SPDX-License-Identifier: GPL-2.0-only */
/*
 * Copyright (C) 1998, 1999, 2000 by Ralf Baechle
 * Copyright (C) 1999, 2000 Silicon Graphics, Inc.
 * Copyright (C) 2007 by Maciej W. Rozycki
 * Copyright (C) 2011, 2012 MIPS Technologies, Inc.
 *
 * Kernel-mode memset function without exceptions
 * by Aleksey Kuleshov (rndfax@yandex.ru), 2015
 */
#include <asm/asm.h>
#include <asm/asm-offsets.h>
#include <asm/regdef.h>

/*
 * memcpy(void *s, int c, size_t n)
 *
 * a0: start of area to clear
 * a1: char to fill with
 * a2: size of area to clear
 */

        .text
        .align  5
        .set    noreorder
LEAF(memcpy4)
	move	v0, ra
	bal	1f
1:	nop
__ra:	addiu	ra, (__memcpy0 - __ra)

//	ra = __memcpy0 - t2 * 2
	andi	t2, a2, 511
	sltiu	t0, t2, 1
	sll	t0, t0, 9
	or	t2, t2, t0

	subu	ra, ra, t2
	subu	ra, ra, t2

	addu	t8, a0, t2
	subu	t8, 512

	addu	t9, a1, t2
	subu	t9, 512

	subu	t2, a2, t0
	sra	t2, t2, 9

	jr	ra	/* goto .L001 ~ .L128 */
	 nop

__memcpy4:
#if 0
#define __offset xxx
666:	lw	t0, __offset (t8)
	sw	t0, __offset (t9)
#else

.L512: lw t0,   0 (t9); sw t0,   0 (t8)
.L508: lw t0,   4 (t9); sw t0,   4 (t8)
.L504: lw t0,   8 (t9); sw t0,   8 (t8)
.L500: lw t0,  12 (t9); sw t0,  12 (t8)
.L496: lw t0,  16 (t9); sw t0,  16 (t8)
.L492: lw t0,  20 (t9); sw t0,  20 (t8)
.L488: lw t0,  24 (t9); sw t0,  24 (t8)
.L484: lw t0,  28 (t9); sw t0,  28 (t8)
.L480: lw t0,  32 (t9); sw t0,  32 (t8)
.L476: lw t0,  36 (t9); sw t0,  36 (t8)
.L472: lw t0,  40 (t9); sw t0,  40 (t8)
.L468: lw t0,  44 (t9); sw t0,  44 (t8)
.L464: lw t0,  48 (t9); sw t0,  48 (t8)
.L460: lw t0,  52 (t9); sw t0,  52 (t8)
.L456: lw t0,  56 (t9); sw t0,  56 (t8)
.L452: lw t0,  60 (t9); sw t0,  60 (t8)
.L448: lw t0,  64 (t9); sw t0,  64 (t8)
.L444: lw t0,  68 (t9); sw t0,  68 (t8)
.L440: lw t0,  72 (t9); sw t0,  72 (t8)
.L436: lw t0,  76 (t9); sw t0,  76 (t8)
.L432: lw t0,  80 (t9); sw t0,  80 (t8)
.L428: lw t0,  84 (t9); sw t0,  84 (t8)
.L424: lw t0,  88 (t9); sw t0,  88 (t8)
.L420: lw t0,  92 (t9); sw t0,  92 (t8)
.L416: lw t0,  96 (t9); sw t0,  96 (t8)
.L412: lw t0, 100 (t9); sw t0, 100 (t8)
.L408: lw t0, 104 (t9); sw t0, 104 (t8)
.L404: lw t0, 108 (t9); sw t0, 108 (t8)
.L400: lw t0, 112 (t9); sw t0, 112 (t8)
.L396: lw t0, 116 (t9); sw t0, 116 (t8)
.L392: lw t0, 120 (t9); sw t0, 120 (t8)
.L388: lw t0, 124 (t9); sw t0, 124 (t8)
.L384: lw t0, 128 (t9); sw t0, 128 (t8)
.L380: lw t0, 132 (t9); sw t0, 132 (t8)
.L376: lw t0, 136 (t9); sw t0, 136 (t8)
.L372: lw t0, 140 (t9); sw t0, 140 (t8)
.L368: lw t0, 144 (t9); sw t0, 144 (t8)
.L364: lw t0, 148 (t9); sw t0, 148 (t8)
.L360: lw t0, 152 (t9); sw t0, 152 (t8)
.L356: lw t0, 156 (t9); sw t0, 156 (t8)
.L352: lw t0, 160 (t9); sw t0, 160 (t8)
.L348: lw t0, 164 (t9); sw t0, 164 (t8)
.L344: lw t0, 168 (t9); sw t0, 168 (t8)
.L340: lw t0, 172 (t9); sw t0, 172 (t8)
.L336: lw t0, 176 (t9); sw t0, 176 (t8)
.L332: lw t0, 180 (t9); sw t0, 180 (t8)
.L328: lw t0, 184 (t9); sw t0, 184 (t8)
.L324: lw t0, 188 (t9); sw t0, 188 (t8)
.L320: lw t0, 192 (t9); sw t0, 192 (t8)
.L316: lw t0, 196 (t9); sw t0, 196 (t8)
.L312: lw t0, 200 (t9); sw t0, 200 (t8)
.L308: lw t0, 204 (t9); sw t0, 204 (t8)
.L304: lw t0, 208 (t9); sw t0, 208 (t8)
.L300: lw t0, 212 (t9); sw t0, 212 (t8)
.L296: lw t0, 216 (t9); sw t0, 216 (t8)
.L292: lw t0, 220 (t9); sw t0, 220 (t8)
.L288: lw t0, 224 (t9); sw t0, 224 (t8)
.L284: lw t0, 228 (t9); sw t0, 228 (t8)
.L280: lw t0, 232 (t9); sw t0, 232 (t8)
.L276: lw t0, 236 (t9); sw t0, 236 (t8)
.L272: lw t0, 240 (t9); sw t0, 240 (t8)
.L268: lw t0, 244 (t9); sw t0, 244 (t8)
.L264: lw t0, 248 (t9); sw t0, 248 (t8)
.L260: lw t0, 252 (t9); sw t0, 252 (t8)
.L256: lw t0, 256 (t9); sw t0, 256 (t8)
.L252: lw t0, 260 (t9); sw t0, 260 (t8)
.L248: lw t0, 264 (t9); sw t0, 264 (t8)
.L244: lw t0, 268 (t9); sw t0, 268 (t8)
.L240: lw t0, 272 (t9); sw t0, 272 (t8)
.L236: lw t0, 276 (t9); sw t0, 276 (t8)
.L232: lw t0, 280 (t9); sw t0, 280 (t8)
.L228: lw t0, 284 (t9); sw t0, 284 (t8)
.L224: lw t0, 288 (t9); sw t0, 288 (t8)
.L220: lw t0, 292 (t9); sw t0, 292 (t8)
.L216: lw t0, 296 (t9); sw t0, 296 (t8)
.L212: lw t0, 300 (t9); sw t0, 300 (t8)
.L208: lw t0, 304 (t9); sw t0, 304 (t8)
.L204: lw t0, 308 (t9); sw t0, 308 (t8)
.L200: lw t0, 312 (t9); sw t0, 312 (t8)
.L196: lw t0, 316 (t9); sw t0, 316 (t8)
.L192: lw t0, 320 (t9); sw t0, 320 (t8)
.L188: lw t0, 324 (t9); sw t0, 324 (t8)
.L184: lw t0, 328 (t9); sw t0, 328 (t8)
.L180: lw t0, 332 (t9); sw t0, 332 (t8)
.L176: lw t0, 336 (t9); sw t0, 336 (t8)
.L172: lw t0, 340 (t9); sw t0, 340 (t8)
.L168: lw t0, 344 (t9); sw t0, 344 (t8)
.L164: lw t0, 348 (t9); sw t0, 348 (t8)
.L160: lw t0, 352 (t9); sw t0, 352 (t8)
.L156: lw t0, 356 (t9); sw t0, 356 (t8)
.L152: lw t0, 360 (t9); sw t0, 360 (t8)
.L148: lw t0, 364 (t9); sw t0, 364 (t8)
.L144: lw t0, 368 (t9); sw t0, 368 (t8)
.L140: lw t0, 372 (t9); sw t0, 372 (t8)
.L136: lw t0, 376 (t9); sw t0, 376 (t8)
.L132: lw t0, 380 (t9); sw t0, 380 (t8)
.L128: lw t0, 384 (t9); sw t0, 384 (t8)
.L124: lw t0, 388 (t9); sw t0, 388 (t8)
.L120: lw t0, 392 (t9); sw t0, 392 (t8)
.L116: lw t0, 396 (t9); sw t0, 396 (t8)
.L112: lw t0, 400 (t9); sw t0, 400 (t8)
.L108: lw t0, 404 (t9); sw t0, 404 (t8)
.L104: lw t0, 408 (t9); sw t0, 408 (t8)
.L100: lw t0, 412 (t9); sw t0, 412 (t8)
.L096: lw t0, 416 (t9); sw t0, 416 (t8)
.L092: lw t0, 420 (t9); sw t0, 420 (t8)
.L088: lw t0, 424 (t9); sw t0, 424 (t8)
.L084: lw t0, 428 (t9); sw t0, 428 (t8)
.L080: lw t0, 432 (t9); sw t0, 432 (t8)
.L076: lw t0, 436 (t9); sw t0, 436 (t8)
.L072: lw t0, 440 (t9); sw t0, 440 (t8)
.L068: lw t0, 444 (t9); sw t0, 444 (t8)
.L064: lw t0, 448 (t9); sw t0, 448 (t8)
.L060: lw t0, 452 (t9); sw t0, 452 (t8)
.L056: lw t0, 456 (t9); sw t0, 456 (t8)
.L052: lw t0, 460 (t9); sw t0, 460 (t8)
.L048: lw t0, 464 (t9); sw t0, 464 (t8)
.L044: lw t0, 468 (t9); sw t0, 468 (t8)
.L040: lw t0, 472 (t9); sw t0, 472 (t8)
.L036: lw t0, 476 (t9); sw t0, 476 (t8)
.L032: lw t0, 480 (t9); sw t0, 480 (t8)
.L028: lw t0, 484 (t9); sw t0, 484 (t8)
.L024: lw t0, 488 (t9); sw t0, 488 (t8)
.L020: lw t0, 492 (t9); sw t0, 492 (t8)
.L016: lw t0, 496 (t9); sw t0, 496 (t8)
.L012: lw t0, 500 (t9); sw t0, 500 (t8)
.L008: lw t0, 504 (t9); sw t0, 504 (t8)
.L004: lw t0, 508 (t9); sw t0, 508 (t8)

#endif
__memcpy0:

	addiu	t8, 512
	addiu	t9, 512

	subu	t2, 1
	bge	t2, zero, .L512
	nop

	move	ra, v0
	jr	ra
	nop

	END(memcpy4)
