/* SPDX-License-Identifier: GPL-2.0-only */
/*
 * Copyright (C) 2014 Antony Pavlov <antonynpavlov@gmail.com>
 */

#ifndef __INCLUDE_DEBUG_LL_LOONGSON1_H__
#define __INCLUDE_DEBUG_LL_LOONGSON1_H__

#include <mach/loongson1.h>

#define DEBUG_LL_UART_ADDR	0xbfE48000

#define DEBUG_LL_UART_SHIFT	0

#define DEBUG_LL_UART_CLK	(165000000 / 2)
#define DEBUG_LL_UART_BPS	115200
//#define DEBUG_LL_UART_DIVISOR	(DEBUG_LL_UART_CLK / DEBUG_LL_UART_BPS/16)
#define DEBUG_LL_UART_DIVISOR	(165000000 /(32*115200))

#endif /* __INCLUDE_DEBUG_LL_JZ4780_H__ */
