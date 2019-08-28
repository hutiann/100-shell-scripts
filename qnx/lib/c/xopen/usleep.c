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




#include <unistd.h>
#include <stdlib.h>
#include <time.h>
#include <sys/neutrino.h>

int usleep(useconds_t usec) {
    struct timespec ts;
    ldiv_t r;

    r = ldiv(usec, 1000000);
    ts.tv_sec = r.quot;
    ts.tv_nsec = 1000 * r.rem;
    return clock_nanosleep(CLOCK_REALTIME, 0, &ts, 0);
}

__SRCVERSION("usleep.c $Rev: 153052 $");
