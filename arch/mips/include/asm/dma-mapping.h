#ifndef _ASM_DMA_MAPPING_H
#define _ASM_DMA_MAPPING_H

#include <common.h>
#include <xfuncs.h>
#include <asm/addrspace.h>
#include <asm/types.h>
#include <malloc.h>
#include <asm/io.h>

static inline void *dma_alloc_coherent(size_t size, dma_addr_t *dma_handle)
{
	void *ret;

	ret = xmemalign(PAGE_SIZE, size);

	memset(ret, 0, size);

	if (dma_handle)
		*dma_handle = CPHYSADDR(ret);

	dma_flush_range((unsigned long)ret, (unsigned long)(ret + size));

	return (void *)CKSEG1ADDR(ret);
}

static inline void dma_free_coherent(void *vaddr, dma_addr_t dma_handle,
				     size_t size)
{
	if (IS_ENABLED(CONFIG_MMU))
		free((void *)CKSEG0ADDR(vaddr));
	else
		free(vaddr);
}

static inline dma_addr_t dma_map_single(struct device_d *dev, void *ptr, size_t size,
					enum dma_data_direction dir)
{
	return (dma_addr_t)ptr;
}

static inline void dma_unmap_single(struct device_d *dev, dma_addr_t addr, size_t size,
				    enum dma_data_direction dir)
{
}

#endif /* _ASM_DMA_MAPPING_H */
