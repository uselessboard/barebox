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
 * memset(void *s, int c, size_t n)
 *
 * a0: start of area to clear
 * a1: char to fill with
 * a2: size of area to clear
 */

LEAF(memset4)
	move	v0, ra
	bal	1f
	nop
1:	nop
	addiu	ra, (.L200 - 1b)
	andi	t2, a2, 0x1ff
	subu	ra, t2

	move	t0, a0
	move	t2, a2
	jr	ra
	 nop

	.L000:	sw	a1, 512 (t0)
memset512:
	.L004:	sw	a1, 508 (t0)
	.L008:	sw	a1, 504 (t0)
	.L00c:	sw	a1, 500 (t0)
	.L010:	sw	a1, 496 (t0)
	.L014:	sw	a1, 492 (t0)
	.L018:	sw	a1, 488 (t0)
	.L01c:	sw	a1, 484 (t0)
	.L020:	sw	a1, 480 (t0)
	.L024:	sw	a1, 476 (t0)
	.L028:	sw	a1, 472 (t0)
	.L02c:	sw	a1, 468 (t0)
	.L030:	sw	a1, 464 (t0)
	.L034:	sw	a1, 460 (t0)
	.L038:	sw	a1, 456 (t0)
	.L03c:	sw	a1, 452 (t0)
	.L040:	sw	a1, 448 (t0)
	.L044:	sw	a1, 444 (t0)
	.L048:	sw	a1, 440 (t0)
	.L04c:	sw	a1, 436 (t0)
	.L050:	sw	a1, 432 (t0)
	.L054:	sw	a1, 428 (t0)
	.L058:	sw	a1, 424 (t0)
	.L05c:	sw	a1, 420 (t0)
	.L060:	sw	a1, 416 (t0)
	.L064:	sw	a1, 412 (t0)
	.L068:	sw	a1, 408 (t0)
	.L06c:	sw	a1, 404 (t0)
	.L070:	sw	a1, 400 (t0)
	.L074:	sw	a1, 396 (t0)
	.L078:	sw	a1, 392 (t0)
	.L07c:	sw	a1, 388 (t0)
	.L080:	sw	a1, 384 (t0)
	.L084:	sw	a1, 380 (t0)
	.L088:	sw	a1, 376 (t0)
	.L08c:	sw	a1, 372 (t0)
	.L090:	sw	a1, 368 (t0)
	.L094:	sw	a1, 364 (t0)
	.L098:	sw	a1, 360 (t0)
	.L09c:	sw	a1, 356 (t0)
	.L0a0:	sw	a1, 352 (t0)
	.L0a4:	sw	a1, 348 (t0)
	.L0a8:	sw	a1, 344 (t0)
	.L0ac:	sw	a1, 340 (t0)
	.L0b0:	sw	a1, 336 (t0)
	.L0b4:	sw	a1, 332 (t0)
	.L0b8:	sw	a1, 328 (t0)
	.L0bc:	sw	a1, 324 (t0)
	.L0c0:	sw	a1, 320 (t0)
	.L0c4:	sw	a1, 316 (t0)
	.L0c8:	sw	a1, 312 (t0)
	.L0cc:	sw	a1, 308 (t0)
	.L0d0:	sw	a1, 304 (t0)
	.L0d4:	sw	a1, 300 (t0)
	.L0d8:	sw	a1, 296 (t0)
	.L0dc:	sw	a1, 292 (t0)
	.L0e0:	sw	a1, 288 (t0)
	.L0e4:	sw	a1, 284 (t0)
	.L0e8:	sw	a1, 280 (t0)
	.L0ec:	sw	a1, 276 (t0)
	.L0f0:	sw	a1, 272 (t0)
	.L0f4:	sw	a1, 268 (t0)
	.L0f8:	sw	a1, 264 (t0)
	.L0fc:	sw	a1, 260 (t0)
	.L100:	sw	a1, 256 (t0)
	.L104:	sw	a1, 252 (t0)
	.L108:	sw	a1, 248 (t0)
	.L10c:	sw	a1, 244 (t0)
	.L110:	sw	a1, 240 (t0)
	.L114:	sw	a1, 236 (t0)
	.L118:	sw	a1, 232 (t0)
	.L11c:	sw	a1, 228 (t0)
	.L120:	sw	a1, 224 (t0)
	.L124:	sw	a1, 220 (t0)
	.L128:	sw	a1, 216 (t0)
	.L12c:	sw	a1, 212 (t0)
	.L130:	sw	a1, 208 (t0)
	.L134:	sw	a1, 204 (t0)
	.L138:	sw	a1, 200 (t0)
	.L13c:	sw	a1, 196 (t0)
	.L140:	sw	a1, 192 (t0)
	.L144:	sw	a1, 188 (t0)
	.L148:	sw	a1, 184 (t0)
	.L14c:	sw	a1, 180 (t0)
	.L150:	sw	a1, 176 (t0)
	.L154:	sw	a1, 172 (t0)
	.L158:	sw	a1, 168 (t0)
	.L15c:	sw	a1, 164 (t0)
	.L160:	sw	a1, 160 (t0)
	.L164:	sw	a1, 156 (t0)
	.L168:	sw	a1, 152 (t0)
	.L16c:	sw	a1, 148 (t0)
	.L170:	sw	a1, 144 (t0)
	.L174:	sw	a1, 140 (t0)
	.L178:	sw	a1, 136 (t0)
	.L17c:	sw	a1, 132 (t0)
	.L180:	sw	a1, 128 (t0)
	.L184:	sw	a1, 124 (t0)
	.L188:	sw	a1, 120 (t0)
	.L18c:	sw	a1, 116 (t0)
	.L190:	sw	a1, 112 (t0)
	.L194:	sw	a1, 108 (t0)
	.L198:	sw	a1, 104 (t0)
	.L19c:	sw	a1, 100 (t0)
	.L1a0:	sw	a1, 96 (t0)
	.L1a4:	sw	a1, 92 (t0)
	.L1a8:	sw	a1, 88 (t0)
	.L1ac:	sw	a1, 84 (t0)
	.L1b0:	sw	a1, 80 (t0)
	.L1b4:	sw	a1, 76 (t0)
	.L1b8:	sw	a1, 72 (t0)
	.L1bc:	sw	a1, 68 (t0)
	.L1c0:	sw	a1, 64 (t0)
	.L1c4:	sw	a1, 60 (t0)
	.L1c8:	sw	a1, 56 (t0)
	.L1cc:	sw	a1, 52 (t0)
	.L1d0:	sw	a1, 48 (t0)
	.L1d4:	sw	a1, 44 (t0)
	.L1d8:	sw	a1, 40 (t0)
	.L1dc:	sw	a1, 36 (t0)
	.L1e0:	sw	a1, 32 (t0)
	.L1e4:	sw	a1, 28 (t0)
	.L1e8:	sw	a1, 24 (t0)
	.L1ec:	sw	a1, 20 (t0)
	.L1f0:	sw	a1, 16 (t0)
	.L1f4:	sw	a1, 12 (t0)
	.L1f8:	sw	a1, 8 (t0)
	.L1fc:	sw	a1, 4 (t0)
	.L200:	sw	a1, 0 (t0)

	addiu	t0, 512
	sra	t8, t2, 9
	subu	t2, 512
	bnez	t8, memset512
	nop

	jr	v0
	nop

	END(memset4)
