// SPDX-License-Identifier: GPL-2.0-only
/*
 * Copyright (C) 2014 Antony Pavlov <antonynpavlov@gmail.com>
 * Copyright (C) 2020 Du Huanpeng <dhu@hodcarrier.cn>
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


#define LS1B_CLK_CPU		0
#define LS1B_CLK_DDR		1
#define LS1B_CLK_DC		2
#define LS1B_CLK_APB		3
#define LS1B_CLK_PLL		4

#define LS1B_CLK_END		5

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

	int pll;
	int n;
	int osc;
	int div;
	unsigned long rate;

	struct clk_ls1b200 *ls1bclk;

	ls1bclk = container_of(clk, struct clk_ls1b200, clk);

	// FIXME: clk_mux
	if(clk->name[0] == 'p' && clk->name[1] == 'l'){
		int pll_freq;
		pll_freq = __raw_readl(ls1bclk->base);
		n  = 12 * 1024;
		n += (pll_freq & 0x3F) * 1024;
		n += (pll_freq >> 8) & 0x3FF;

		rate = parent_rate / 2 / 1024;
		/* avoid overflow. */
		rate *= n;
	} else {
		int div_param;
		div_param = __raw_readl(ls1bclk->base + 4);
		n = (div_param >> ls1bclk->div_shift) & ls1bclk->div_mask;

		rate = parent_rate;
		if(n) rate /= n;
	}
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


#define LS1B200_CLK_CPU 0
#define LS1B200_CLK_DDR 1
#define LS1B200_CLK_AHB 2
#define LS1B200_CLK_DC  3
#define LS1B200_CLK_END 4

#define LS1B200_CPU_DIV_SHIFT 20
#define LS1B200_CPU_DIV_MASK  0xf

#define LS1B200_DDR_DIV_SHIFT 14
#define LS1B200_DDR_DIV_MASK  0xf

/* TODO: pll_out/4/DC_DIV */
#define LS1B200_DC_DIV_SHIFT  26
#define LS1B200_DC_DIV_MASK   0xf

#define LS1B200_CLK_AHB_DIV_SHIFT 0
#define LS1B200_CLK_AHB_MASK      0

static void ls1b200_pll_init(void __iomem *base)
{
	clks[LS1B200_CLK_CPU] = clk_ls1b200("pll", "oscillator", base,
		0, 0);

	clks[LS1B200_CLK_CPU] = clk_ls1b200("cpu", "pll", base,
		LS1B200_CPU_DIV_SHIFT, LS1B200_CPU_DIV_MASK);

	clks[LS1B200_CLK_DDR] = clk_ls1b200("ddr", "pll", base,
		LS1B200_DDR_DIV_SHIFT, LS1B200_DDR_DIV_MASK);

	clks[LS1B200_CLK_AHB] = clk_ls1b200("dc", "pll", base,
		LS1B200_CLK_AHB_DIV_SHIFT, LS1B200_CLK_AHB_MASK);

	clks[LS1B200_CLK_DC]  = clk_ls1b200("apb", "ddr", base,
		LS1B200_DC_DIV_MASK, LS1B200_DC_DIV_MASK);
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
	of_clk_add_provider(dev->device_node, of_clk_src_onecell_get,
			    &clk_data);

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
