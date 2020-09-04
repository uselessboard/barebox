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

ENTRY_FUNCTION(BOARD_PBL_START)

	mips_barebox_10h

	mips_disable_interrupts

	pbl_loongson1_pll
	pbl_loongson1_uart_enable
//	pbl_loongson1_calc_prescale 115200
	debug_ll_ns16550_init
	debug_ll_outc '.'
	debug_ll_ns16550_outnl

loongson1b_war_1:
	set_cpu_window 0, 0x1c300000, 0xfff00000, 0x1c3000d2 // dc        1M must cachable
	set_cpu_window 1, 0x1fe10000, 0xffffe000, 0x1fe100d3 // gmac0     8K
	set_cpu_window 2, 0x1fe20000, 0xffffe000, 0x1fe200d3 // gmac1     8K
	set_cpu_window 3, 0x1fe10000, 0xffff0000, 0x1fe100d0 // gmac0     64K
	set_cpu_window 4, 0x1fe20000, 0xffff0000, 0x1fe200d0 // gmac1     64K
	set_cpu_window 5, 0x1ff00000, 0xfff00000, 0x1ff000d0 // reserved  1M
	set_cpu_window 6, 0x1f000000, 0xff000000, 0x1f0000d3 // AXIMUX    16M
	set_cpu_window 7, 0x00000000, 0x00000000, 0x000000f0 // ddr       0
	li	t0, 0xbfd000e0
	lw	t1, 0x0(t0)	//0xbfd000e0
	and t1, t1, 0xffffff00
	ori	t1, 0xd0
	sw	t1, 0x0(t0)
	lw	t1, 0x8(t0)	//0xbfd000e8
	and t1, t1, 0xffffff00
	ori	t1, 0xd0
	sw	t1, 0x8(t0)
loongson1b_war_1end:

	pbl_loongson1_ddr2_init

ENTRY_FUNCTION_END(BOARD_PBL_START, loongson1, SZ_64M)
