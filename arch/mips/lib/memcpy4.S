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

LEAF(memcpy4)
	.set	noreorder

	move	v0, ra
	bal	1f
	nop
1:	nop
	addiu	ra, (__memcpy0 - 1b)

	li	t0, 0x200
	andi	t2, a2, 0x1ff
	subu	t2, t0, t2
	addu	t2, t2, t2
	subu	ra, ra, t2

	move	t8, a0
	move	t9, a1
	sub	t2, zero, 512
	and	t2, a2, t2

	/* wait for jtag */
//	move	a3, zero
//	beq	a3, zero, .
//	nop

	jr	ra	/* goto .L001 ~ .L128 */
	 nop

__memcpy4:
#if 0
#define __offset xxx
666:	lw	t0, __offset (t8)
	sw	t0, __offset (t9)
#else
.L000: lw t0, 512 (t8); sw t0, 512 (t9)
.L001: lw t0, 508 (t8); sw t0, 508 (t9)
.L002: lw t0, 504 (t8); sw t0, 504 (t9)
.L003: lw t0, 500 (t8); sw t0, 500 (t9)
.L004: lw t0, 496 (t8); sw t0, 496 (t9)
.L005: lw t0, 492 (t8); sw t0, 492 (t9)
.L006: lw t0, 488 (t8); sw t0, 488 (t9)
.L007: lw t0, 484 (t8); sw t0, 484 (t9)
.L008: lw t0, 480 (t8); sw t0, 480 (t9)
.L009: lw t0, 476 (t8); sw t0, 476 (t9)
.L010: lw t0, 472 (t8); sw t0, 472 (t9)
.L011: lw t0, 468 (t8); sw t0, 468 (t9)
.L012: lw t0, 464 (t8); sw t0, 464 (t9)
.L013: lw t0, 460 (t8); sw t0, 460 (t9)
.L014: lw t0, 456 (t8); sw t0, 456 (t9)
.L015: lw t0, 452 (t8); sw t0, 452 (t9)
.L016: lw t0, 448 (t8); sw t0, 448 (t9)
.L017: lw t0, 444 (t8); sw t0, 444 (t9)
.L018: lw t0, 440 (t8); sw t0, 440 (t9)
.L019: lw t0, 436 (t8); sw t0, 436 (t9)
.L020: lw t0, 432 (t8); sw t0, 432 (t9)
.L021: lw t0, 428 (t8); sw t0, 428 (t9)
.L022: lw t0, 424 (t8); sw t0, 424 (t9)
.L023: lw t0, 420 (t8); sw t0, 420 (t9)
.L024: lw t0, 416 (t8); sw t0, 416 (t9)
.L025: lw t0, 412 (t8); sw t0, 412 (t9)
.L026: lw t0, 408 (t8); sw t0, 408 (t9)
.L027: lw t0, 404 (t8); sw t0, 404 (t9)
.L028: lw t0, 400 (t8); sw t0, 400 (t9)
.L029: lw t0, 396 (t8); sw t0, 396 (t9)
.L030: lw t0, 392 (t8); sw t0, 392 (t9)
.L031: lw t0, 388 (t8); sw t0, 388 (t9)
.L032: lw t0, 384 (t8); sw t0, 384 (t9)
.L033: lw t0, 380 (t8); sw t0, 380 (t9)
.L034: lw t0, 376 (t8); sw t0, 376 (t9)
.L035: lw t0, 372 (t8); sw t0, 372 (t9)
.L036: lw t0, 368 (t8); sw t0, 368 (t9)
.L037: lw t0, 364 (t8); sw t0, 364 (t9)
.L038: lw t0, 360 (t8); sw t0, 360 (t9)
.L039: lw t0, 356 (t8); sw t0, 356 (t9)
.L040: lw t0, 352 (t8); sw t0, 352 (t9)
.L041: lw t0, 348 (t8); sw t0, 348 (t9)
.L042: lw t0, 344 (t8); sw t0, 344 (t9)
.L043: lw t0, 340 (t8); sw t0, 340 (t9)
.L044: lw t0, 336 (t8); sw t0, 336 (t9)
.L045: lw t0, 332 (t8); sw t0, 332 (t9)
.L046: lw t0, 328 (t8); sw t0, 328 (t9)
.L047: lw t0, 324 (t8); sw t0, 324 (t9)
.L048: lw t0, 320 (t8); sw t0, 320 (t9)
.L049: lw t0, 316 (t8); sw t0, 316 (t9)
.L050: lw t0, 312 (t8); sw t0, 312 (t9)
.L051: lw t0, 308 (t8); sw t0, 308 (t9)
.L052: lw t0, 304 (t8); sw t0, 304 (t9)
.L053: lw t0, 300 (t8); sw t0, 300 (t9)
.L054: lw t0, 296 (t8); sw t0, 296 (t9)
.L055: lw t0, 292 (t8); sw t0, 292 (t9)
.L056: lw t0, 288 (t8); sw t0, 288 (t9)
.L057: lw t0, 284 (t8); sw t0, 284 (t9)
.L058: lw t0, 280 (t8); sw t0, 280 (t9)
.L059: lw t0, 276 (t8); sw t0, 276 (t9)
.L060: lw t0, 272 (t8); sw t0, 272 (t9)
.L061: lw t0, 268 (t8); sw t0, 268 (t9)
.L062: lw t0, 264 (t8); sw t0, 264 (t9)
.L063: lw t0, 260 (t8); sw t0, 260 (t9)
.L064: lw t0, 256 (t8); sw t0, 256 (t9)
.L065: lw t0, 252 (t8); sw t0, 252 (t9)
.L066: lw t0, 248 (t8); sw t0, 248 (t9)
.L067: lw t0, 244 (t8); sw t0, 244 (t9)
.L068: lw t0, 240 (t8); sw t0, 240 (t9)
.L069: lw t0, 236 (t8); sw t0, 236 (t9)
.L070: lw t0, 232 (t8); sw t0, 232 (t9)
.L071: lw t0, 228 (t8); sw t0, 228 (t9)
.L072: lw t0, 224 (t8); sw t0, 224 (t9)
.L073: lw t0, 220 (t8); sw t0, 220 (t9)
.L074: lw t0, 216 (t8); sw t0, 216 (t9)
.L075: lw t0, 212 (t8); sw t0, 212 (t9)
.L076: lw t0, 208 (t8); sw t0, 208 (t9)
.L077: lw t0, 204 (t8); sw t0, 204 (t9)
.L078: lw t0, 200 (t8); sw t0, 200 (t9)
.L079: lw t0, 196 (t8); sw t0, 196 (t9)
.L080: lw t0, 192 (t8); sw t0, 192 (t9)
.L081: lw t0, 188 (t8); sw t0, 188 (t9)
.L082: lw t0, 184 (t8); sw t0, 184 (t9)
.L083: lw t0, 180 (t8); sw t0, 180 (t9)
.L084: lw t0, 176 (t8); sw t0, 176 (t9)
.L085: lw t0, 172 (t8); sw t0, 172 (t9)
.L086: lw t0, 168 (t8); sw t0, 168 (t9)
.L087: lw t0, 164 (t8); sw t0, 164 (t9)
.L088: lw t0, 160 (t8); sw t0, 160 (t9)
.L089: lw t0, 156 (t8); sw t0, 156 (t9)
.L090: lw t0, 152 (t8); sw t0, 152 (t9)
.L091: lw t0, 148 (t8); sw t0, 148 (t9)
.L092: lw t0, 144 (t8); sw t0, 144 (t9)
.L093: lw t0, 140 (t8); sw t0, 140 (t9)
.L094: lw t0, 136 (t8); sw t0, 136 (t9)
.L095: lw t0, 132 (t8); sw t0, 132 (t9)
.L096: lw t0, 128 (t8); sw t0, 128 (t9)
.L097: lw t0, 124 (t8); sw t0, 124 (t9)
.L098: lw t0, 120 (t8); sw t0, 120 (t9)
.L099: lw t0, 116 (t8); sw t0, 116 (t9)
.L100: lw t0, 112 (t8); sw t0, 112 (t9)
.L101: lw t0, 108 (t8); sw t0, 108 (t9)
.L102: lw t0, 104 (t8); sw t0, 104 (t9)
.L103: lw t0, 100 (t8); sw t0, 100 (t9)
.L104: lw t0,  96 (t8); sw t0,  96 (t9)
.L105: lw t0,  92 (t8); sw t0,  92 (t9)
.L106: lw t0,  88 (t8); sw t0,  88 (t9)
.L107: lw t0,  84 (t8); sw t0,  84 (t9)
.L108: lw t0,  80 (t8); sw t0,  80 (t9)
.L109: lw t0,  76 (t8); sw t0,  76 (t9)
.L110: lw t0,  72 (t8); sw t0,  72 (t9)
.L111: lw t0,  68 (t8); sw t0,  68 (t9)
.L112: lw t0,  64 (t8); sw t0,  64 (t9)
.L113: lw t0,  60 (t8); sw t0,  60 (t9)
.L114: lw t0,  56 (t8); sw t0,  56 (t9)
.L115: lw t0,  52 (t8); sw t0,  52 (t9)
.L116: lw t0,  48 (t8); sw t0,  48 (t9)
.L117: lw t0,  44 (t8); sw t0,  44 (t9)
.L118: lw t0,  40 (t8); sw t0,  40 (t9)
.L119: lw t0,  36 (t8); sw t0,  36 (t9)
.L120: lw t0,  32 (t8); sw t0,  32 (t9)
.L121: lw t0,  28 (t8); sw t0,  28 (t9)
.L122: lw t0,  24 (t8); sw t0,  24 (t9)
.L123: lw t0,  20 (t8); sw t0,  20 (t9)
.L124: lw t0,  16 (t8); sw t0,  16 (t9)
.L125: lw t0,  12 (t8); sw t0,  12 (t9)
.L126: lw t0,   8 (t8); sw t0,   8 (t9)
.L127: lw t0,   4 (t8); sw t0,   4 (t9)
.L128: lw t0,   0 (t8); sw t0,   0 (t9)
#endif
__memcpy0:
	addiu	t8, 512
	andi	t0, a0, 511
	subu	t8, t0

	addiu	t9, 512
	andi	t0, a1, 511
	subu	t9, t0

	sra	ra, t2, 9
	subu	t2, 512
	bnez	ra, .L001
	nop

//	move	a3, zero
//	beq	a3, zero, .
//	nop

	jr	v0
	nop

	END(memcpy4)
