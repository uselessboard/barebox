// SPDX-License-Identifier: GPL-2.0-only
/*
 * Copyright (C) 2014 Antony Pavlov <antonynpavlov@gmail.com>
 * Copyright (C) 2020 Du Huanpeng <u74147@gmail.com>
 *
 * Based on the Linux ath79 clock code
 */

#include <common.h>
#include <init.h>
#include <io.h>
#include <linux/clk.h>
#include <linux/clkdev.h>
#include <linux/err.h>

//#include <mach/ath79.h>
//#include <dt-bindings/clock/ath79-clk.h>

enum {
LS1B_CLK_PLL,

LS1B_CLK_CPU_MUX,
LS1B_CLK_CPU_DIV,

LS1B_CLK_DDR_DIV,
LS1B_CLK_DDR_MUX,
LS1B_CLK_APB_DIV,

LS1B_CLK_DC_DIV,
LS1B_CLK_DIV4,
LS1B_CLK_DC_MUX,

LS1B_CLK_END
};
//#define LS1B_CLK_PLL	0
//#define LS1B_CLK_CPU_MUX 6
//#define LS1B_CLK_CPU	1
//#define LS1B_CLK_DDR	2
//#define LS1B_CLK_APB	3
//#define LS1B_CLK_DC	4
//#define LS1B_CLK_DIV4	5
//#define LS1B_CLK_END	7

#define LS1B_CPU_DIV_SHIFT	20
#define LS1B_CPU_DIV_WIDTH	4

#define LS1B_DDR_DIV_SHIFT	14
#define LS1B_DDR_DIV_WIDTH	4

#define LS1B_DC_DIV_SHIFT	26
#define LS1B_DC_DIV_WIDTH	4

#define LS1B_CLK_APB_MULT	1
#define LS1B_CLK_APB_DIV	2

#define PLL_FREQ	0
#define PLL_DIV_PARAM	4

static struct clk *clks[LS1B_CLK_END];
static struct clk_onecell_data clk_data;

struct clk_ls1b200 {
	struct clk clk;
	void __iomem *base;
	unsigned div_shift;
	unsigned div_mask;
	const char *parent;
};

static unsigned long clk_ls1b200_recalc_rate(struct clk *clk, unsigned long parent_rate)
{
	int n;
	unsigned long rate;
	int pll_freq;
	struct clk_ls1b200 *ls1bclk;

	ls1bclk = container_of(clk, struct clk_ls1b200, clk);
	pll_freq = __raw_readl(ls1bclk->base);

	n  = 12 * 1024;
	n += (pll_freq & 0x3F) * 1024;
	n += (pll_freq >> 8) & 0x3FF;

	rate = parent_rate / 2 / 1024;
	/* avoid overflow. */
	rate *= n;

	return rate;
}

struct clk_ops clk_ls1b200_ops = {
	.recalc_rate = clk_ls1b200_recalc_rate,
};

static struct clk *clk_ls1b200(const char *name, const char *parent,
	void __iomem *base, int div_shift, int div_mask)
{
	struct clk_ls1b200 *f = xzalloc(sizeof(struct clk_ls1b200));

	f->parent = parent;
	f->base = base;
	f->div_shift = div_shift;
	f->div_mask = div_mask;

	f->clk.ops = &clk_ls1b200_ops;
	f->clk.name = name;
	f->clk.parent_names = &f->parent;
	f->clk.num_parents = 1;

	clk_register(&f->clk);

	return &f->clk;
}

static const char *cpu_mux[] = {"cpu_div", "oscillator", };
static const char *ddr_mux[] = {"ddr_div", "oscillator", };
static const char *dc_mux[]  = {"dc_div", "oscillator", };


//static const char *sel_io0[]  = { "ref_io0", "ref_xtal", };


static void ls1b200_pll_init(void __iomem *base)
{

	clks[LS1B_CLK_PLL] = clk_ls1b200("pll", "oscillator", base + PLL_FREQ, 0, 0);


	clks[LS1B_CLK_CPU_DIV] = clk_divider("cpu_div", "pll", 0,
		base + PLL_DIV_PARAM , LS1B_CPU_DIV_SHIFT, LS1B_CPU_DIV_WIDTH, 0);
	clks[LS1B_CLK_CPU_MUX] = clk_mux("cpu_mux", 0, base + PLL_DIV_PARAM,
		    8, 1, cpu_mux,  ARRAY_SIZE(cpu_mux), 0);

	clks[LS1B_CLK_DDR_DIV] = clk_divider("ddr_div", "pll", 0,
		base + PLL_DIV_PARAM, LS1B_DDR_DIV_SHIFT, LS1B_DDR_DIV_WIDTH, 0);
	clks[LS1B_CLK_DDR_MUX] = clk_mux("ddr_mux", 0, base + PLL_DIV_PARAM,
		    10, 1, ddr_mux,  ARRAY_SIZE(ddr_mux), 0);
	clks[LS1B_CLK_APB_DIV] = clk_fixed_factor("apb_div", "ddr_mux", LS1B_CLK_APB_MULT, LS1B_CLK_APB_DIV, 0);

	clks[LS1B_CLK_DIV4] = clk_fixed_factor("dc_div4", "pll", 1, 4, 0);

	clks[LS1B_CLK_DC_DIV] = clk_divider("dc_div", "dc_div4", 0,
		base + PLL_DIV_PARAM, LS1B_DC_DIV_SHIFT, LS1B_DC_DIV_WIDTH, 0);
	clks[LS1B_CLK_DC_MUX] = clk_mux("dc_mux", 0, base + PLL_DIV_PARAM,
		    10, 1, dc_mux,  ARRAY_SIZE(dc_mux), 0);
}

static int ls1b200_clk_probe(struct device_d *dev)
{
	struct resource *iores;
	void __iomem *base;

	iores = dev_request_mem_resource(dev, 0);
	if (IS_ERR(iores))
	 	return PTR_ERR(iores);
	base = IOMEM(iores->start);

	/* now got the controller base address */
	ls1b200_pll_init(base);

	clk_data.clks = clks;
	clk_data.clk_num = ARRAY_SIZE(clks);
	of_clk_add_provider(dev->device_node, of_clk_src_onecell_get, &clk_data);

	return 0;
}

static __maybe_unused struct of_device_id ls1b200_clk_dt_ids[] = {
	{
		.compatible = "loongson,ls1b-pll",
	}, {
		/* sentinel */
	}
};

static struct driver_d ls1b200_clk_driver = {
	.probe	= ls1b200_clk_probe,
	.name	= "ls1b-clk",
	.of_compatible = DRV_OF_COMPAT(ls1b200_clk_dt_ids),
};

postcore_platform_driver(ls1b200_clk_driver);
