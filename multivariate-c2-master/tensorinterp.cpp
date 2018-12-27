/**
 * Copyright (c) 2013 Vasily Kartashov <info@kartashov.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 * documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
 * Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
 * WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#include "mex.h"
#include <math.h>
#include "pchip.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* function values and input points */
    double *fs = (double *) mxGetData(prhs[1]);
    double *xi = (double *) mxGetData(prhs[2]);
    
    /* get the number of points to be interpolated */
    unsigned n = (unsigned) mxGetM(prhs[2]);
    
    /* allocate for results */
    plhs[0] = mxCreateDoubleMatrix(n, 1, mxREAL);
    double *fi = (double *) mxGetData(plhs[0]);
    
    /* parse the grid object */
    mxArray *a_dims    = mxGetField(prhs[0], 0, "dims");
    mxArray *a_xss     = mxGetField(prhs[0], 0, "axes");
    mxArray *a_hss     = mxGetField(prhs[0], 0, "hss");
    mxArray *a_iss     = mxGetField(prhs[0], 0, "iss");
    mxArray *a_ins     = mxGetField(prhs[0], 0, "ins");
    mxArray *a_offsets = mxGetField(prhs[0], 0, "offsets");
    mxArray *a_bs      = mxGetField(prhs[0], 0, "bs");
    
    /* create grid object */
    grid_t g;
    g.d  = *(unsigned *) mxGetData(a_dims);
    g.ns =  (unsigned *) mxGetData(a_ins); 
    g.os =  (unsigned *) mxGetData(a_offsets);
    g.bs =  (unsigned *) mxGetData(a_bs);
    for (int i = 0; i < g.d; i++) {
        g.xss[i] = (double *) mxGetData(mxGetCell(a_xss, i));
        g.hss[i] = (double *) mxGetData(mxGetCell(a_hss, i));
        g.iss[i] = (double *) mxGetData(mxGetCell(a_iss, i));
    }
    
    /* loop over all points */
    double x[32];
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < g.d; j++) {
            x[j] = *(xi + j * n + i);
        }
        fi[i] = interpolate(&g, fs, x, 0, 0);
    }
}