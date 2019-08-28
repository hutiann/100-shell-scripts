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




#include <signal.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/neutrino.h>
#include <sys/netmgr.h>


int sigqueue(pid_t pid, int signo, union sigval data) {

	if(pid < 0) {		/* POSIX does not allow process groups here */
		errno = ESRCH;
		return(-1);
		}

    return(SignalKill(ND_LOCAL_NODE, pid, 0, signo, SI_QUEUE, *(int *) &data));
	}

__SRCVERSION("sigqueue.c $Rev: 153052 $");
