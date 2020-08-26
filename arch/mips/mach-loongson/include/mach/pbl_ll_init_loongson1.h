#ifndef __ASM_MACH_LOONGSON1_PBL_LL_INIT_LOONGSON1_H
#define __ASM_MACH_LOONGSON1_PBL_LL_INIT_LOONGSON1_H

#include <asm/addrspace.h>
#include <asm/regdef.h>


.macro	pbl_loongson1_ddr2_init
	.set	push
	.set	noreorder

	pbl_reg_writel 0x00000101, 0xAFFFFE00
	pbl_reg_writel 0x01000100, 0xAFFFFE04
	pbl_reg_writel 0x00000000, 0xAFFFFE08
	pbl_reg_writel 0x01000000, 0xAFFFFE0C
	pbl_reg_writel 0x00000000, 0xAFFFFE10
	pbl_reg_writel 0x01000101, 0xAFFFFE14
	pbl_reg_writel 0x01000100, 0xAFFFFE18
	pbl_reg_writel 0x01010000, 0xAFFFFE1C
	pbl_reg_writel 0x01010101, 0xAFFFFE20
	pbl_reg_writel 0x01000202, 0xAFFFFE24
	pbl_reg_writel 0x04030201, 0xAFFFFE28
	pbl_reg_writel 0x07000000, 0xAFFFFE2C
	pbl_reg_writel 0x02020203, 0xAFFFFE30
	pbl_reg_writel 0x0a020203, 0xAFFFFE34
	pbl_reg_writel 0x00010506, 0xAFFFFE38
	pbl_reg_writel 0x00000400, 0xAFFFFE3C
	pbl_reg_writel 0x08040201, 0xAFFFFE40
	pbl_reg_writel 0x08040201, 0xAFFFFE44
	pbl_reg_writel 0x00000000, 0xAFFFFE48
	pbl_reg_writel 0x00000306, 0xAFFFFE4C
	pbl_reg_writel 0x3f0b020a, 0xAFFFFE50
	pbl_reg_writel 0x0000003f, 0xAFFFFE54
	pbl_reg_writel 0x00000000, 0xAFFFFE58
	pbl_reg_writel 0x37570000, 0xAFFFFE5C
	pbl_reg_writel 0x08000000, 0xAFFFFE60
	pbl_reg_writel 0x002a1503, 0xAFFFFE64
	pbl_reg_writel 0x002a002a, 0xAFFFFE68
	pbl_reg_writel 0x002a002a, 0xAFFFFE6C
	pbl_reg_writel 0x002a002a, 0xAFFFFE70
	pbl_reg_writel 0x002a002a, 0xAFFFFE74
	pbl_reg_writel 0x00000002, 0xAFFFFE78
	pbl_reg_writel 0x00b40020, 0xAFFFFE7C
	pbl_reg_writel 0x00000087, 0xAFFFFE80
	pbl_reg_writel 0x000007ff, 0xAFFFFE84
	pbl_reg_writel 0x44240618, 0xAFFFFE88
	pbl_reg_writel 0x80808080, 0xAFFFFE8C
	pbl_reg_writel 0x80808080, 0xAFFFFE90
	pbl_reg_writel 0x001c8080, 0xAFFFFE94
	pbl_reg_writel 0x00c8006b, 0xAFFFFE98
	pbl_reg_writel 0x36b00002, 0xAFFFFE9C
	pbl_reg_writel 0x00c80017, 0xAFFFFEA0
	pbl_reg_writel 0x00000000, 0xAFFFFEA4
	pbl_reg_writel 0x00009c40, 0xAFFFFEA8
	pbl_reg_writel 0x00000000, 0xAFFFFEAC
	pbl_reg_writel 0x00000000, 0xAFFFFEB0
	pbl_reg_writel 0x00000000, 0xAFFFFEB4
	pbl_reg_writel 0x00000000, 0xAFFFFEB8
	pbl_reg_writel 0x00000000, 0xAFFFFEBC
	pbl_reg_writel 0x00000000, 0xAFFFFEC0
	pbl_reg_writel 0x00000000, 0xAFFFFEC4
	pbl_reg_writel 0x00000000, 0xAFFFFEC8
	pbl_reg_writel 0x00000000, 0xAFFFFECC
	pbl_reg_writel 0x00000000, 0xAFFFFED0
	pbl_reg_writel 0x00000000, 0xAFFFFED4
	pbl_reg_writel 0x00000000, 0xAFFFFED8
	pbl_reg_writel 0x00000000, 0xAFFFFEDC
	pbl_reg_writel 0x00000000, 0xAFFFFEE0
	pbl_reg_writel 0x00000000, 0xAFFFFEE4

	.set	pop
.endm

#endif /* __ASM_MACH_LOONGSON1_PBL_LL_INIT_LOONGSON1_H */
