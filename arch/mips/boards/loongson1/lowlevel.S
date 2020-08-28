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

#include <mach/pbl_ll_init_loongson1.h>

#define GPIOCFG0  0xbfd010C0
#define GPIOCFG1  0xbfd010C4
#define GPIOOE0   0xbfd010D0
#define GPIOOE1   0xbfd010D4
#define GPIOIN0   0xbfd010E0
#define GPIOIN1   0xbfd010E4
#define GPIOOUT0  0xbfd010F0
#define GPIOOUT1  0xbfd010F4

#define LED9 0x040
#define LED6 0x080
#define LED7 0x100 /* beep, don't use it */
#define LED8 0x200

#define LED LED8

ENTRY_FUNCTION(BOARD_PBL_START)

	mips_barebox_10h

	mips_disable_interrupts


	/* 0x3C0 controls four leds */
	pbl_reg_set LED GPIOCFG1

	pbl_reg_clr LED GPIOOE1



blink:
	pbl_reg_clr LED GPIOOUT1
	nop

	pbl_reg_set LED GPIOOUT1
	nop

	b blink
	  nop

	debug_ll_ns16550_init

	debug_ll_outc '.'
	debug_ll_ns16550_outnl

	pbl_loongson1_ddr2_init

ENTRY_FUNCTION_END(BOARD_PBL_START, loongson1, SZ_64M)
