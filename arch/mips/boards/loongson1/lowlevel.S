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

#define LED (LED8+LED6)

#define UART2_RX 0x400000
#define UART2_TX 0x800000

#if 0
ENTRY_FUNCTION(BOARD_PBL_START)

        pbl_reg_set 0x2C0 GPIOCFG1
        pbl_reg_clr 0x2C0 GPIOOE1

	pbl_reg_set 0x2C0 GPIOOUT1



	li a0, LED
	li a1, LED
	li a2, GPIOOUT1

1:

	pbl_sleep (1<<8)

	xor a0, a0, a1
	sw  a0, 0 (a2)
	b   1b
	  nop

STOP_WITH_DEBUG_EVENT
#endif

ENTRY_FUNCTION(BOARD_PBL_START)

	mips_barebox_10h

	mips_disable_interrupts

	pbl_reg_clr UART2_RX GPIOCFG1
	pbl_reg_clr UART2_TX GPIOCFG1

        pbl_reg_set 0x2C0 GPIOCFG1
        pbl_reg_clr 0x2C0 GPIOOE1

	pbl_reg_set 0x2C0 GPIOOUT1


//	pbl_loongson1_calc_prescale 115200
	pbl_loongson1_pll
	debug_ll_ns16550_init

	/* write v0 to hardware */
1984:

	li a0, LED
	li a2, GPIOOUT1
	lw a2, 0 (a2)
	xor a0, a0, a2

	li a2, GPIOOUT1
	sw  a0, 0 (a2)

	/* write uart */
	debug_ll_outc 'U'
	debug_ll_ns16550_outnl
	b 1984b
	nop


	pbl_loongson1_ddr2_init

ENTRY_FUNCTION_END(BOARD_PBL_START, loongson1, SZ_64M)
