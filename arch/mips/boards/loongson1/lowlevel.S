/* SPDX-License-Identifier: GPL-2.0-only */
/*
 * Copyright (C) 2014 Antony Pavlov <antonynpavlov@gmail.com>
 */

#define BOARD_PBL_START start_loongson1

#include <asm/pbl_macros.h>
#include <mach/loongson1.h>
#include <mach/debug_ll.h>
#include <asm/pbl_nmon.h>
#include <linux/sizes.h>

#include <mach/pbl_macros.h>
#include <mach/pbl_ll_init_loongson1.h>

#define CONFIG_BASE 0xaffffe00
#define CONFIG_DDR16BIT 1
#undef  EIGHT_BANK_MODE

ENTRY_FUNCTION(BOARD_PBL_START)

	mips_barebox_10h

	mips_disable_interrupts

	pbl_loongson1_pll

	pbl_loongson1_uart_enable
//	pbl_loongson1_calc_prescale 115200
	debug_ll_ns16550_init
	debug_ll_ns16550_outnl
	debug_ll_outc '.'
	debug_ll_ns16550_outnl
	debug_ll_outc '1'

	pbl_loongson1_remap
	debug_ll_outc '2'

	/* initial ddr2 controller */
	pbl_reg_writel 0xfc000000, 0xbfd010c8
	pbl_reg_writel 0x14000000, 0xbfd010f8

	pbl_loongson1_ddr2_init
10:
	pbl_reg_writel  0x01010100, 0xaffffe34

9: //not_locked
	li	t0, 0xaffffe00
	lw      t1, 0x10 (t0)
	andi    t1, t1, 1
	beqz    t1, 9b
	nop

	lh      t1, 0xf2 (t0)
	sltiu 	t1, t1, 5
	beqz 	t1, 1f
	nop

	lw      t1, 0xf4 (t0)
	addiu   t1, t1, 4
	sw      t1, 0xf4 (t0)
	b       10b
	nop
1:

#ifdef CONFIG_DDR16BIT
	/*16bit ddr and disable conf*/
	pbl_reg_set 0x110000, 0xbfd00424
#else
	/*disable conf*/
	pbl_reg_set 0x100000, 0xbfd00424
#endif //#ifdef CONFIG_DDR16BIT

	debug_ll_outc '3'

	debug_ll_ns16550_outnl

ENTRY_FUNCTION_END(BOARD_PBL_START, loongson1, SZ_64M)
