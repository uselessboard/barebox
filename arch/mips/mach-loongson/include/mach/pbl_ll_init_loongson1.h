#ifndef __ASM_MACH_LOONGSON1_PBL_LL_INIT_LOONGSON1_H
#define __ASM_MACH_LOONGSON1_PBL_LL_INIT_LOONGSON1_H

#include <asm/addrspace.h>
#include <asm/regdef.h>


.macro	pbl_loongson1_ddr2_init
	.set	push
	.set	noreorder

	pbl_reg_writel 0x00000000 , 0x00000000

	.set	pop
.endm

#endif /* __ASM_MACH_LOONGSON1_PBL_LL_INIT_LOONGSON1_H */