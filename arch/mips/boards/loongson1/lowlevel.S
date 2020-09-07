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


################################################################

#define msize           s2

################################################################

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

	debug_ll_outc '2'

//	pbl_loongson1_ddr2_init

# ----------------------------------
# "war_ddr1.S"
# ----------------------------------
#define LS1BSOC         1
#define MEM_SIZE        (64*1024*1024)
#define CONFIG_DDR16BIT 1

#undef  EIGHT_BANK_MODE
################################################################################

	/* 配置内存 */
#if defined(LS1ASOC) || defined(LS1BSOC)
	/*
	 * set *_ssel and *_tsel
	 * *_ssel参数用于配置DDR IO的驱动强度 01: 弱驱动 11: 强驱动
	 * *_tsel参数用于配置DDR IO的ODT输入匹配阻抗 00: disable 01: 75ohm 10: 150ohm 11: 50ohm
	 * pad_st不用于SSTL18模式，应保持为0
	 */
	li	t0, 0xbfd010c8
	li	t1, 0xfc000000
	sw	t1, (t0)
	li	t0, 0xbfd010f8
	li	t1, 0x14000000
	sw	t1, (t0)

	/* DDR2 config begin */
	bal     ddr2_config
	nop

	/* memory size defined in conf */
	li msize, MEM_SIZE

#ifdef CONFIG_DDR16BIT
	/*16bit ddr and disable conf*/ 
	li a1, 0x110000
#else
	/*disable conf*/
	li a1, 0x100000
#endif //#ifdef CONFIG_DDR16BIT

	li a0, 0xbfd00424
	lw a2, 0x0(a0)
	or a2, a1
	sw a2, 0x0(a0)
#endif

################################################################################


# ----------------------------------

	debug_ll_outc '3'
	debug_ll_outc '4'

	li t0, 0xa0080000
	li a0, 0xdeadbeef
	debug_ll_outc 'a'
	nop
	nop
	nop
	nop
	nop
	nop
	sw a0, 0 (t0)
	debug_ll_outc 'b'
	lw a1, 0 (t0)
	debug_ll_outc 'c'
	beq a0, a1, same
	 nop
	debug_ll_outc 'x'

diff:
	debug_ll_outc 'X'
	b .
	nop
same:
	debug_ll_outc 'R'
	debug_ll_outc 'A'
	debug_ll_outc 'M'
	debug_ll_outc 'O'
	debug_ll_outc 'K'
	b .
	nop

# ----------------------------------
# "ddr2fconfig-samsung-CL3.S"
# ----------------------------------

#define REG_ADDRESS 0x0
#define CONFIG_BASE 0xaffffe00

	.global ddr2_config
	.ent    ddr2_config
	.set    noreorder
#	.set    mips32
ddr2_config:
    la      t0, ddr2_reg_data
    addu    t0, t0, s0
    li      t1, 0x1d
    li      t2, CONFIG_BASE

reg_write:
    ld      a1, 0x0(t0)
    sd      a1, REG_ADDRESS(t2)
    subu    t1, t1, 0x1
    addiu   t0, t0, 0x8
    bne     t1, $0, reg_write
    addiu   t2, t2, 0x10

    ############start##########
ddr2_config_start:
    li      t2, CONFIG_BASE
    la      t0, DDR2_CTL_03_DATA_HI
    addu    t0, t0, s0
10:    
    lw      a1, 0x0(t0)
    sw      a1, 0x34(t2)
    lw      a1, 0x0(t0)
    ori     a1, 0x0100
    sw      a1, 0x34(t2)

9: //not_locked
	ld      a1, 0x10(t2)
	andi    a1, 0x01
	beqz    a1, 9b
	nop
	lh      a1, 0xf2(t2)
	sltiu 	a1, 5
	beqz 	a1, 1f
	nop
	lw      a1, 0xf4(t2)
	addiu   a1, 4
	sw      a1, 0xf4(t2)
	b       10b
	nop
1:
	jr      ra
	nop
	.end    ddr2_config

//	.rdata
	.align 5

ddr2_reg_data:
DDR2_CTL_00_DATA_LO: .word 0x00000101
DDR2_CTL_00_DATA_HI: .word 0x01000100 #no_concurrentap
DDR2_CTL_01_DATA_LO: .word 0x00000000
#ifdef EIGHT_BANK_MODE
DDR2_CTL_01_DATA_HI: .word 0x01000001 //内存颗粒有8bank和4bank的区分，请认真看清使用的内存颗粒的bank数
#else
DDR2_CTL_01_DATA_HI: .word 0x01000000
#endif
DDR2_CTL_02_DATA_LO: .word 0x00000000
DDR2_CTL_02_DATA_HI: .word 0x01000101
DDR2_CTL_03_DATA_LO: .word 0x01000100
DDR2_CTL_03_DATA_HI: .word 0x01010000
DDR2_CTL_04_DATA_LO: .word 0x01010101
DDR2_CTL_04_DATA_HI: .word 0x01000202
DDR2_CTL_05_DATA_LO: .word 0x04030201 #CL=3	//CL=3
DDR2_CTL_05_DATA_HI: .word 0x07000000
DDR2_CTL_06_DATA_LO: .word 0x02020203 #400	//tRTP=2(1.5) tRRD=2 tEMRS=2 tCKE=3
//DDR2_CTL_06_DATA_LO: .word 0x07070202 #800	//
DDR2_CTL_06_DATA_HI: .word 0x0a020203 #400	//WRLAT=CL-1=2  tWTR=2  tWR=3
//DDR2_CTL_06_DATA_HI: .word 0x0a060707 #800	//
DDR2_CTL_07_DATA_LO: .word 0x00010506 #CL=3 //CASLAT_LIN_GATE=CASLAT_LIN-1=5-1=4  CASLAT_LIN=CASLATx2-1=3x2-1=5
DDR2_CTL_07_DATA_HI: .word 0x00000400 #400
DDR2_CTL_08_DATA_LO: .word 0x08040201	//片选
DDR2_CTL_08_DATA_HI: .word 0x08040201	//片选
DDR2_CTL_09_DATA_LO: .word 0x00000000
DDR2_CTL_09_DATA_HI: .word 0x00000306 #400 //tRP=tRCD=3 tDAL=tWR+tRP=3+3=6(min 2)
DDR2_CTL_10_DATA_LO: .word 0x3f0b020a #400 //tRC=tRAS+tRP=8+3=11 tMRD=min 2 tFAW=10
//DDR2_CTL_10_DATA_LO: .word 0x3f1f0214 #800 //tRC=tRAS+tRP
DDR2_CTL_10_DATA_HI: .word 0x0000003f //yanhua //DQS延迟百分比
DDR2_CTL_11_DATA_LO: .word 0x00000000 //yanhua
DDR2_CTL_11_DATA_HI: .word 0x37570000 //yanhua  0x4060 -- 0x2d4d-取中
DDR2_CTL_12_DATA_LO: .word 0x08000000 #400 //tRAS = 8
//DDR2_CTL_12_DATA_LO: .word 0x18000000 #800 //tRAS
DDR2_CTL_12_DATA_HI: .word 0x002a1503 #400 //tRFC=21 tRCD=tRP=3
DDR2_CTL_13_DATA_LO: .word 0x002a002a
DDR2_CTL_13_DATA_HI: .word 0x002a002a
DDR2_CTL_14_DATA_LO: .word 0x002a002a
DDR2_CTL_14_DATA_HI: .word 0x002a002a //
DDR2_CTL_15_DATA_LO: .word 0x00000002 //
DDR2_CTL_15_DATA_HI: .word 0x00b40020 //
DDR2_CTL_16_DATA_LO: .word 0x00000087
DDR2_CTL_16_DATA_HI: .word 0x000007ff #no_interrupt
DDR2_CTL_17_DATA_LO: .word 0x44240618 //EMRS(1)  tREF=1560/780 设置为0x00010c30时 CPU频率高了跑不起来 使能DLL
//DDR2_CTL_17_DATA_LO: .word 0x47a40618
//DDR2_CTL_17_DATA_LO: .word 0x44260618
DDR2_CTL_17_DATA_HI: .word 0x80808080
DDR2_CTL_18_DATA_LO: .word 0x80808080
DDR2_CTL_18_DATA_HI: .word 0x001c8080
DDR2_CTL_19_DATA_LO: .word 0x00c8006b
DDR2_CTL_19_DATA_HI: .word 0x36b00002 #400	//tRAS_MAX=14000 TPDEX=min2
DDR2_CTL_20_DATA_LO: .word 0x00c80017 #400	//tXSR=min200 tXSNR=tRFC+10(ns)=23
DDR2_CTL_20_DATA_HI: .word 0x00000000
DDR2_CTL_21_DATA_LO: .word 0x00009c40 //tINIT=200(us)x0.2=40000tCK
DDR2_CTL_21_DATA_HI: .word 0x00000000
DDR2_CTL_22_DATA_LO: .word 0x00000000
DDR2_CTL_22_DATA_HI: .word 0x00000000
DDR2_CTL_23_DATA_LO: .word 0x00000000
DDR2_CTL_23_DATA_HI: .word 0x00000000
DDR2_CTL_24_DATA_LO: .word 0x00000000
DDR2_CTL_24_DATA_HI: .word 0x00000000
DDR2_CTL_25_DATA_LO: .word 0x00000000
DDR2_CTL_25_DATA_HI: .word 0x00000000
DDR2_CTL_26_DATA_LO: .word 0x00000000
DDR2_CTL_26_DATA_HI: .word 0x00000000
DDR2_CTL_27_DATA_LO: .word 0x00000000
DDR2_CTL_27_DATA_HI: .word 0x00000000
DDR2_CTL_28_DATA_LO: .word 0x00000000
DDR2_CTL_28_DATA_HI: .word 0x00000000

# ----------------------------------


ENTRY_FUNCTION_END(BOARD_PBL_START, loongson1, SZ_64M)
