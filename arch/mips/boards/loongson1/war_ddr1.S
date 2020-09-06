#define LS1BSOC         1
#define MEM_SIZE        (64*1024*1024)
#define CONFIG_DDR16BIT 1

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
#ifdef LS1ASOC
	li	t1, 0x00000000
#endif
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
	#ifdef LS1ASOC
		li a1, 0x3
	#elif LS1BSOC
		li a1, 0x110000
	#endif
#else
	/*disable conf*/
	#ifdef LS1ASOC
		li a1, 0x2
	#elif LS1BSOC
		li a1, 0x100000
	#endif
#endif //#ifdef CONFIG_DDR16BIT

#ifdef LS1ASOC
	li a0, 0xbfd00420
#elif LS1BSOC
	li a0, 0xbfd00424
#endif
	lw a2, 0x0(a0)
	or a2, a1
	sw a2, 0x0(a0)

#elif defined(LS1CSOC)
	li msize, MEM_SIZE
#if !defined(NAND_BOOT_EN)
#include "sdram_cfg.S"

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

