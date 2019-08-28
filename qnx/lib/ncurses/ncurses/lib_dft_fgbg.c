/****************************************************************************
 * Copyright (c) 1998 Free Software Foundation, Inc.                        *
 *                                                                          *
 * Permission is hereby granted, free of charge, to any person obtaining a  *
 * copy of this software and associated documentation files (the            *
 * "Software"), to deal in the Software without restriction, including      *
 * without limitation the rights to use, copy, modify, merge, publish,      *
 * distribute, distribute with modifications, sublicense, and/or sell       *
 * copies of the Software, and to permit persons to whom the Software is    *
 * furnished to do so, subject to the following conditions:                 *
 *                                                                          *
 * The above copyright notice and this permission notice shall be included  *
 * in all copies or substantial portions of the Software.                   *
 *                                                                          *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS  *
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF               *
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.   *
 * IN NO EVENT SHALL THE ABOVE COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,   *
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR    *
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR    *
 * THE USE OR OTHER DEALINGS IN THE SOFTWARE.                               *
 *                                                                          *
 * Except as contained in this notice, the name(s) of the above copyright   *
 * holders shall not be used in advertising or otherwise to promote the     *
 * sale, use or other dealings in this Software without prior written       *
 * authorization.                                                           *
 ****************************************************************************/

/****************************************************************************
 *  Author: Thomas E. Dickey <dickey@clark.net> 1997                        *
 ****************************************************************************/
#include <curses.priv.h>
#include <term.h>

MODULE_ID("$Id: lib_dft_fgbg.c 153052 2007-11-02 21:10:56Z coreos $")

/*
 * Modify the behavior of color-pair 0 so that the library doesn't assume that
 * it is black on white.  This is an extension to XSI curses.
 *
 * Invoke this function after 'start_color()'.
 */
int
use_default_colors(void)
{
	T((T_CALLED("use_default_colors()")));

	if (!SP->_coloron)
		returnCode(ERR);

	if (!orig_pair && !orig_colors)
		returnCode(ERR);

	if (initialize_pair)	/* don't know how to handle this */
		returnCode(ERR);

#if	defined(__QNX__) || defined(__QNXNTO__)
	/* I have problem to handle default color with TERM=qnx,
	 * shut it off at the moment.
	 */
	if (strnicmp(cur_term->type.term_names, "qnx", 3) == 0)
		returnCode(ERR);
#endif

	SP->_default_color = TRUE;
	SP->_color_pairs[0] = PAIR_OF(C_MASK, C_MASK);
	returnCode(OK);
}
