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



/*
 *  _pack64.h: Set structure packing to 64 bits (8 bytes)
 *

 */

#if defined(__WATCOMC__)
 #pragma pack(__push,8);
#elif defined(__HIGHC__)
 #pragma push_align_members(64);
#elif defined(__GNUC__)
 #pragma pack()		/* 4 is the highest GCC pragma pack can take, but the default it higher */
#elif defined(__INTEL_COMPILER)
 #pragma pack()		/* 4 is the highest GCC pragma pack can take, but the default it higher */
#elif defined(__MWERKS__)
#else
 #error Compiler not supported
#endif

/* __SRCVERSION("_pack64.h $Rev: 153052 $"); */
