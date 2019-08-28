/*
 * $QNXLicenseC:
 * Copyright 2007, QNX Software Systems. All Rights Reserved.
 * 
 * You must obtain a written license from and pay applicable license fees to QNX 
 * Software Systems before you may reproduce, modify or distribute this software, 
 * or any work that includes all or part of this software.   Free development 
 * licenses are available for evaluation and non-commercial purposes.  For more 
 * information visit http://licensing.qnx.com or email licensing@qnx.com.
 *  
 * This file may contain contributions from others.  Please review this entire 
 * file for other proprietary rights or license notices, as well as the QNX 
 * Development Suite License Guide at http://licensing.qnx.com/license-guide/ 
 * for other information.
 * $
 */




/*-
 * core: interface to system mmap,munmap,etc...
 *
 * Some OS versions don't support munmap, so core keeps around bits that
 * don't make it back.  There are other versions which have buggy munmaps
 * that only work on the same range as the mmap which allocated it.
 * These are handled by the upper layer.
 *
 * Compiling with the "TESTING" flag sets allows you to select the behaviour
 *
 * of unmap based on the environment variable MUNMAP_WORKS:
 * = 0   simulate munmap always failing.
 * = 1   use underlying munmap
 * = *   pretend munumap works, but don't invoke it (ie. leak).
 *
 */

#include <assert.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <errno.h>
#include "malloc-lib.h"

typedef struct core_blk {
	unsigned sz;		
	struct core_blk *next;
	struct core_blk *prev;
} core_blk_t;

#define DEFAULT_MAX_ARENA 12

static core_blk_t *core_cache_list=NULL;
unsigned __core_cache_max_num=DEFAULT_MAX_ARENA;
unsigned __core_cache_max_sz=0;
static unsigned core_cache_size=0;
static unsigned core_cache_num=0;

#define CORE_CACHE_ENQ(__addr, __size, __status, __force) \
	{ \
		core_blk_t *cblk = (core_blk_t *)__addr; \
		cblk->sz = __size; \
		cblk->prev = NULL; \
		if (!(__force) && \
			( ((__core_cache_max_sz == 0) && (__core_cache_max_num == 0)) || \
				((__core_cache_max_sz) && \
         ((core_cache_size + __size) > __core_cache_max_sz)) ||\
				((__core_cache_max_num) && \
         (core_cache_num >= __core_cache_max_num)) \
			)) { \
			__status = 1; /* not cached */ \
		} \
		else { \
			if (core_cache_list == NULL) { \
				core_cache_list = cblk; \
				cblk->next = NULL; \
			} \
			else {\
				cblk->next = core_cache_list; \
				core_cache_list->prev = cblk; \
				core_cache_list = cblk; \
			} \
			core_cache_size +=__size; \
			core_cache_num++; \
			__status = 0; /* cached */ \
			_malloc_stats.m_freemem += __size; \
		} \
	}

#define CORE_CACHE_DEQ(__addr, __size, __fixed, __rsize) \
	{ \
		core_blk_t *cblk=NULL; \
		core_blk_t *temp; \
		temp = core_cache_list; \
		while (temp) { \
			if ((__size == 0) || \
					((!__fixed) && (temp->sz >= __size)) || \
					(temp->sz == __size) \
				) { \
				cblk = temp; \
				core_cache_num--; \
				core_cache_size -= temp->sz; \
				if (temp == core_cache_list) { \
					core_cache_list = temp->next; \
					if (core_cache_list != NULL) \
						core_cache_list->prev = NULL; \
				} \
				else { \
					temp->prev->next = temp->next; \
					if (temp->next != NULL) { \
						temp->next->prev = temp->prev; \
					} \
				} \
				break; \
			} \
			temp = temp->next; \
		} \
		if (cblk != NULL) { \
			__addr = cblk; \
			*__rsize = cblk->sz; \
			_malloc_stats.m_freemem -= cblk->sz; \
		} \
		else { \
			__addr = NULL; \
		} \
	}

#ifndef TESTING
#define getmem __getmem
#define putmem __putmem
#else
static int works = -1;

static char *
getmem(unsigned nbytes)
{
	return __getmem(nbytes);
}

static int
putmem(char *cp, unsigned nbytes)
{
	if (works == -1) {
		char *p = getenv("MUNMAP_WORKS");
		works = p?strtol(p,0,0):0;
	}
	switch (works) {
	case 0:
		return -1;
	case 1:
		return munmap(cp,nbytes);
	default:
		return 0;
	}
}

#endif

void __core_cache_adjust()
{
	void *addr;
	int rsize;
	while ((core_cache_num > __core_cache_max_num) ||
				(core_cache_size > __core_cache_max_sz)) {
		CORE_CACHE_DEQ(addr, 0, 0, &rsize);
		putmem(addr, rsize);
		_malloc_stats.m_corefrees++;
	}
}

void __core_prealloc_cache(unsigned size)
{
	void *addr;
	unsigned sz;
	int status;
	sz = _amblksiz;
	while (core_cache_size < size) {
		addr = getmem(sz);
		if (addr == (void *)-1) {
			return;
		}
		CORE_CACHE_ENQ(addr, sz, status, 1);
		_malloc_stats.m_heapsize += sz;
		_malloc_stats.m_coreallocs++;
	}
	return;
}

char *
morecore(unsigned nbytes, int fixed, int *rsize)
{
	char *z;
	void *addr=NULL;
	CORE_CACHE_DEQ(addr, nbytes, fixed, rsize);
	if (addr == NULL) {
		z = getmem(nbytes);
		_malloc_stats.m_heapsize += nbytes;
		_malloc_stats.m_coreallocs++;
		*rsize = nbytes;
	}
	else  
		z = (char *)addr;
	return z;
}

int
donecore(void *cp, unsigned nbytes)
{
	int status=0;
	CORE_CACHE_ENQ(cp, nbytes, status, 0);
	if (status) { // not cached
		putmem(cp, nbytes);
		_malloc_stats.m_heapsize -= nbytes;
		_malloc_stats.m_corefrees++;
	}
	return 0;
}

__SRCVERSION("core.c $Rev: 153052 $");
