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

#define tmpsize         s1
#define msize           s2
#define output_en       s3
#define bonito          s4
#define dbg             s5
#define sdCfg           s6

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

#elif defined(LS1CSOC)
	li msize, MEM_SIZE
#if !defined(NAND_BOOT_EN)


# ----------------------------------------------------------------
# "sdram_cfg.S"

//#define	SD_FREQ	(6 * PLL_M) / (2 * SDRAM_PARAM_DIV_NUM)
#define	SD_FREQ	(((APB_CLK / 4) * (PLL_MULT / CPU_DIV)) / SDRAM_PARAM_DIV_NUM)
/* 颗粒行数 */
#define	ROW_1K		0x7
#define	ROW_2K		0x0
#define	ROW_4K		0x1
#define	ROW_8K		0x2
#define	ROW_16K		0x3
/* 颗粒列数 */
#define	COL_256		0x7
#define	COL_512		0x0
#define	COL_1K		0x1
#define	COL_2K		0x2
#define	COL_4K		0x3
/* 颗粒位宽 */
#define	WIDTH_8		0x0
#define	WIDTH_16	0x1
#define	WIDTH_32	0x2

#define	TRCD		3
#define	TCL			3
#define	TRP			3
#define	TRFC		8
#define	TRAS		6
#define	TREF		0x818
#define	TWR			2

#define	DEF_SEL		0x1
#define	DEF_SEL_N	0x0
#define	HANG_UP		0x1
#define	HANG_UP_N	0x0
#define	CFG_VALID	0x1

#define	SD_PARA0	(0x7f<<25 | \
					(TRAS << 21) | \
					(TRFC << 17) | (TRP << 14) | (TCL << 11) | \
					(TRCD << 8) | (WIDTH_16 << 6) | (COL_512 << 3) | \
					ROW_8K)

#define	SD_PARA1	((HANG_UP_N << 8) | (DEF_SEL_N << 7) | (TWR << 5) | (TREF >> 7))

#define	SD_PARA1_EN	((CFG_VALID << 9) | (HANG_UP_N << 8) | \
					(DEF_SEL_N << 7) | (TWR << 5) | (TREF >> 7))


#if (MEM_SIZE == 0)	/* 内存大小自动诊断 liushiwei@gmail.com*/
//检查rtc magic
	li	t1, 0xbfe64030
	lw	t0, (t1)
	and	t0, 0xffffff00
	li	t1, COL_512  //cpu版本1C300A, 固定使用32M内存
	beqz	t0, cpu_1c300b
	nop
cpu_1c300a:
	PRINTSTR("\r\nCPU:LS1C300A")
	b	csize_t1
	nop
cpu_1c300b:
	PRINTSTR("\r\nCPU:LS1C300B")
	li	t0, 0xbfe64030
	lw 	t0, (t0)
	move	t1, t0
	and 	t1, t1, 0xfffffff8
	li	t2, 0xe8
	bne	t1, t2, nomagic
	nop
	li	t2, 0x3abde000
	li	t1, 0xbfe6402c
	lw	t1, (t1)   //rtc L magic
	and	t1, t1, 0xfffff000
	bne	t1, t2, nomagic
	nop
magic_ok:
        and	t0, t0, 0b111
	li	t1, 0xbfe64024
	sw	zero, (t1)  //清 rtc magic
	sw	zero, 0x4(t1)
	b	setcsize
	nop
nomagic:
	li	v0, 0xbfc00000+(NVRAM_POS+RAM_CSIZE_OFFS)
        lb	t1, (v0)
csize_t1:
        li	t0, COL_256
        beq	t0, t1, setcsize
	nop
        li	t0, COL_512
        beq	t0, t1, setcsize
	nop
        li	t0,COL_1K
        beq	t0, t1, setcsize
	nop
        li	t0,COL_2K
        beq	t0, t1, setcsize
	nop
        li	t0,COL_4K
        beq	t0, t1, setcsize
	nop
	li	t0,COL_4K //默认4K
setcsize:
	li	t1,SD_PARA0 & 0b1111111111000111
        sll	t0,t0,3
	or	a0,t0,t1
#else
	move	a0, SD_PART0
#endif  //MEM_SIZE == 0
	li	a1, SD_PARA1
	li  	t1, 0xbfd00410
	sw	a0, 0x0(t1)
	sw	a1, 0x4(t1)
	sw	a0, 0x0(t1)
	sw	a1, 0x4(t1)
	sw	a0, 0x0(t1)
	li	a1, SD_PARA1_EN
	sw	a1, 0x4(t1)


	li	msize, 0xa0000000
	move	t1, msize
	li	t3, 0xa0002000

1:
	sw	msize, (msize)
	addiu	msize, 4
	bne	msize, t3, 1b
	nop
	move	msize, t1
2:
	lw	t2, (msize)
	bne	t2, msize, csize_test_err
	addiu	msize, 4
	bne	msize, t3, 2b
	nop
	b	csize_test_ok
	nop
csize_test_err:
/*
因为sdram控制器，只能初始化1次，所以在这里发现sdram的csize参数错误时，
要用看门狗重启，用rtc传递数据给下一次启动
rtc在分钟加1时，才做有效性判断，这样我们用特殊非有效数字保存数据给下次重启
rtc-L的最高2位必须是0,
rtc-H的又有最低8位可用， 0-FF
*/
	li	t1, 0xbfd00410
	lw	t0, (t1)
	ror	t0, t0, 3
	and	t0, t0, 0b111
	li	t1, COL_256
	bne	t0, t1, 2f
	nop
	PRINTSTR("\r\nsdram auto detect error")
1:
	b	1b
	nop
2:
	li	t1, COL_512
	bne	t0, t1, 3f
	nop
	PRINTSTR("\r\nsdram.csize:512 error, now try 256")
	li	t1, COL_256 //当前512 降到256
	b	set_rtc_magic
	nop
3:
	li	t1, COL_1K
	bne	t0, t1, 4f
	nop
	PRINTSTR("\r\nsdram.csize:1K error, now try 512")
	li	t1, COL_512 //当前1K 降到512
	b	set_rtc_magic
	nop
4:
	li	t1, COL_2K
	bne	t0, t1, 5f
	nop
	PRINTSTR("\r\nsdram.csize:2K error, now try 1K")
	li	t1, COL_1K //当前2K 降到1K
	b	set_rtc_magic
	nop
5:
	PRINTSTR("\r\nsdram.csize:4K error, now try 2K")
	li	t1, COL_2K //当前4K  降到2K
set_rtc_magic:
	ori	t1, 0xe8
	li	t0, 0xbfe64028
	sw	t1, (t0)   //rtc H magic
	li	t0, 0xbfe64024
	li	t2, 0x3abde000
	sw	t2, (t0)   //rtc L magic
	li	t0, 0xbfd00420
	lw	t1, (t0)
	and	t1, ~(0b1111 << 10) //关闭所有的串口
	sw	t1, (t0)
	li	t0, 0xbfe5c060 //WDT_EN
	li	t1, 1
	sw	t1, (t0)
	sw	t1, 0x4(t0) //WDT_timer
	sw	t1, 0x8(t0) //WDT_set
6:      //等待看门狗wdt重启系统
	b 6b
	nop

csize_test_ok:
	
//	PRINTSTR("\r\nSD_PARA0=")
//	li  	t1, 0xbfd00410
//	lw	a0, 0x0(t1)
//	bal	hexserial
//	nop
//	DELAY(100)

#if (MEM_SIZE == 0)	/* 内存大小自动诊断  liushiwei@gmail.com*/
	li	msize, 0xa0000000
	move	t4, msize
	sw	zero, (t4)
	li	t1, 0xdeadbeef
	li	t3, 0xa0000000 + 0x10000000 //最大检查到256M
msizetest_continue:
	add	msize, msize, 0x100000  //步进1M
	sw	t1, (msize)
	lw	t2, (msize)
	beq	msize, t3, msizetest_out
	nop
	bne	t1, t2, msizetest_out
	nop
	lw	t2, (t4)
        bne	t1, t2, msizetest_continue //如果ram[0]也被修改了， 那么就是循环了
	nop
	b	msizetest_out
	nop
sdram_init_fault_handler:
	PRINTSTR("\r\nsdram fault!")

msizetest_out:
	sub	msize, msize, 0xa0000000
	nop
	PRINTSTR("\r\nmsize=0x")
        move	a0, msize
	bal	hexserial
	nop
#endif  //MEM_SIZE == 0

#endif
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
