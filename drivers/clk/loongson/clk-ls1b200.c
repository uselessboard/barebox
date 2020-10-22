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




#define LS1B_CLK_PLL	0
#define LS1B_CLK_CPU	1
#define LS1B_CLK_DDR	2
#define LS1B_CLK_APB	3
#define LS1B_CLK_DC	4
#define LS1B_CLK_DIV4	5

#define LS1B_CLK_END	6

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


#define LS1B_CPU_DIV_SHIFT	20
#define LS1B_CPU_DIV_WIDTH	4

#define LS1B_DDR_DIV_SHIFT	14
#define LS1B_DDR_DIV_WIDTH	4

/* TODO: pll_out/4/DC_DIV */
#define LS1B_DC_DIV_SHIFT	26
#define LS1B_DC_DIV_WIDTH	4

#define LS1B_CLK_APB_MULT	1
#define LS1B_CLK_APB_DIV	2


#define LS1B_PLL_FREQ	0
#define LS1B_DIV_PARAM	4


static void ls1b200_pll_init(void __iomem *base)
{
	clks[LS1B_CLK_PLL] = clk_ls1b200("pll", "oscillator", base + LS1B_PLL_FREQ, 0, 0);

	clks[LS1B_CLK_CPU] = clk_divider("cpu", "pll", 0,
		base + LS1B_DIV_PARAM , LS1B_CPU_DIV_SHIFT, LS1B_CPU_DIV_WIDTH, 0);
	clks[LS1B_CLK_DDR] = clk_divider("ddr", "pll", 0,
		base + LS1B_DIV_PARAM, LS1B_DDR_DIV_SHIFT, LS1B_DDR_DIV_WIDTH, 0);
	clks[LS1B_CLK_DIV4] = clk_fixed_factor("div4", "pll", 1, 4, 0);
	clks[LS1B_CLK_DC] = clk_divider("dc", "div4", 0,
		base + LS1B_DIV_PARAM, LS1B_DC_DIV_SHIFT, LS1B_DC_DIV_WIDTH, 0);
	clks[LS1B_CLK_APB] = clk_fixed_factor("apb", "ddr", LS1B_CLK_APB_MULT, LS1B_CLK_APB_DIV, 0);
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
