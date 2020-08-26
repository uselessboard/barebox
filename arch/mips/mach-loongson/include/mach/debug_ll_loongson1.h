/* SPDX-License-Identifier: GPL-2.0-only */
/*
 * Copyright (C) 2014 Antony Pavlov <antonynpavlov@gmail.com>
 */

#ifndef __INCLUDE_DEBUG_LL_LOONGSON1_H__
#define __INCLUDE_DEBUG_LL_LOONGSON1_H__

#include <mach/loongson1.h>

#define DEBUG_LL_UART_ADDR	0

#define DEBUG_LL_UART_SHIFT	2

#ifndef DEBUG_LL_UART_CLK
#define DEBUG_LL_UART_CLK	(48000000 / 16)
#endif
#define DEBUG_LL_UART_BPS	CONFIG_BAUDRATE
#define DEBUG_LL_UART_DIVISOR	(DEBUG_LL_UART_CLK / DEBUG_LL_UART_BPS)

#endif /* __INCLUDE_DEBUG_LL_JZ4780_H__ */
