/* SPDX-License-Identifier: GPL-2.0-or-later */
/*
 * Copyright (C) 2018 Oleksij Rempel <linux@rempel-privat.de>
 * Copyright (C) 2019 Du Huanpeng <u74147@gmail.com>
 */

#define BOARD_PBL_START start_okud_max9331_boot0

#include <mach/debug_ll.h>
#include <asm/asm.h>
#include <asm/pbl_macros.h>
#include <mach/pbl_macros.h>
#include <asm/pbl_nmon.h>


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

        pbl_reg_set 0x2C0 GPIOCFG1
        pbl_reg_clr 0x2C0 GPIOOE1

	pbl_reg_set 0x2C0 GPIOOUT1


	li a0, LED
	li a1, LED
	li a2, GPIOOUT1

1:
	li t0, 1<<8
delay:
	subu t0, 1
	bne  t0, zero, delay
	  nop

	xor a0, a0, a1
	sw  a0, 0 (a2)
	b   1b
	  nop

STOP_WITH_DEBUG_EVENT
