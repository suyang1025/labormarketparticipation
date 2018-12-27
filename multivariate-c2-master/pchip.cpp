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

#include "pchip.h"
#include <math.h>
#include "mex.h"

inline int find(unsigned b, double *xs, int n, double x) {
    unsigned i = 0, j;
    for (; b; b >>= 1) {
        j = i | b;
        if (j < n && xs[j] <= x) i = j;
    }
    return i || *xs <= x ? i : -1;
}

inline double hermit(double x0, double h0, double i0, double y0, double y1, double m0, double m1, double x) {
    double t1 = (x - x0) * i0;
    double t2 = t1 * t1;
    double t3 = t2 * t1;
    double c4 = t3 - t2;
    double c3 = t2 - c4 - c4;
    double c2 = c4 - t2 + t1;
    double c1 = 1 - c3;
    return c1 * y0 + c2 * h0 * m0 + c3 * y1 + c4 * h0 * m1;
}

inline double slope_left(double h0, double h1, double i0, double i1, double y0, double y1, double y2) {
    double m0 = (y1 - y0) * i0;
    double m1 = (y2 - y1) * i1;
    double m = ((2 * h0 + h1) * m0 - h0 * m1) / (h0 + h1);
    if (m * m0 <= 0) return 0;
    if (m0 * m1 <= 0 && abs(m) > abs(3 * m0)) return 3 * m0;
    return m;
}

inline double slope_right(double h0, double h1, double i0, double i1, double y0, double y1, double y2) {
    double m0 = (y1 - y0) * i0;
    double m1 = (y2 - y1) * i1;
    double m = ((2 * h1 + h0) * m1 - h1 * m0) / (h0 + h1);
    if (m * m1 <= 0) return 0;
    if (m0 * m1 <= 0 && abs(m) > abs(3 * m1)) return 3 * m1;
    return m;
}

inline double slope(double h0, double h1, double i0, double i1, double y0, double y1, double y2) {
    double m0 = (y1 - y0) * i0;
    double m1 = (y2 - y1) * i1;
    double k0, k1;
    if (m0 * m1 <= 0) return 0;
    k0 = (h0 + 2 * h1) * m1;
    k1 = (2 * h0 + h1) * m0;
    return (m0 * k0 + m1 * k1) / (k0 + k1);
}

inline double int2(double x0, double i0, double y0, double y1, double x) {
    return y0 + (x - x0) * (y1 - y0) * i0;
}

inline double
int3_out_left(double x0, double h0, double h1, double i0, double i1, double y0, double y1, double y2, double x) {
    double m0 = slope_left(h0, h1, i0, i1, y0, y1, y2);
    return y0 + (x - x0) * m0;
}

inline double
int3_out_right(double x2, double h0, double h1, double i0, double i1, double y0, double y1, double y2, double x) {
    double m2 = slope_right(h0, h1, i0, i1, y0, y1, y2);
    return y2 + (x - x2) * m2;
}

inline double
int3_first(double x0, double h0, double h1, double i0, double i1, double y0, double y1, double y2, double x) {
    double m0 = slope_left(h0, h1, i0, i1, y0, y1, y2);
    double m1 = slope(h0, h1, i0, i1, y0, y1, y2);
    return hermit(x0, h0, i0, y0, y1, m0, m1, x);
}

inline double
int3_last(double x1, double h0, double h1, double i0, double i1, double y0, double y1, double y2, double x) {
    double m1 = slope(h0, h1, i0, i1, y0, y1, y2);
    double m2 = slope_right(h0, h1, i0, i1, y0, y1, y2);
    return hermit(x1, h1, i1, y1, y2, m1, m2, x);
}

inline double
int4(double x1, double h0, double h1, double h2, double i0, double i1, double i2, double y0, double y1, double y2, double y3, double x) {
    double m1 = slope(h0, h1, i0, i1, y0, y1, y2);
    double m2 = slope(h1, h2, i1, i2, y1, y2, y3);
    return hermit(x1, h1, i1, y1, y2, m1, m2, x);
}

inline double fetch(grid_t *grid, double *fs, double *x, int d, int offset, int tick) {
    if (d == grid->d - 1) return fs[offset + tick * grid->os[d]];
    return interpolate(grid, fs, x, d + 1, offset + tick * grid->os[d]);
}

double interpolate(grid_t *grid, double *fs, double *x, int d, int offset) {
    int n = grid->ns[d];
    int p = -1;
    double *xs = grid->xss[d];
    double *hs = grid->hss[d];
    double *is = grid->iss[d];
    double y0, y1, y2, y3;
    if (n == 1) return fetch(grid, fs, x, d, offset, 0);
    if (n == 2) {
        y0 = fetch(grid, fs, x, d, offset, 0);
        y1 = fetch(grid, fs, x, d, offset, 1);
        return int2(xs[0], is[0], y0, y1, x[d]);
    }
    p = find(grid->bs[d], xs, n, x[d]);
    if (p == -1) {
        y0 = fetch(grid, fs, x, d, offset, 0);
        y1 = fetch(grid, fs, x, d, offset, 1);
        y2 = fetch(grid, fs, x, d, offset, 2);
        return int3_out_left(xs[0], hs[0], hs[1], is[0], is[1], y0, y1, y2, x[d]);
    }
    if (p == 0) {
        y0 = fetch(grid, fs, x, d, offset, 0);
        y1 = fetch(grid, fs, x, d, offset, 1);
        y2 = fetch(grid, fs, x, d, offset, 2);
        return int3_first(xs[0], hs[0], hs[1], is[0], is[1], y0, y1, y2, x[d]);
    }
    if (p == n - 2) {
        y0 = fetch(grid, fs, x, d, offset, n - 3);
        y1 = fetch(grid, fs, x, d, offset, n - 2);
        y2 = fetch(grid, fs, x, d, offset, n - 1);
        return int3_last(xs[n - 2], hs[n - 3], hs[n - 2], is[n - 3], is[n - 2], y0, y1, y2, x[d]);
    }
    if (p == n - 1) {
        y0 = fetch(grid, fs, x, d, offset, n - 3);
        y1 = fetch(grid, fs, x, d, offset, n - 2);
        y2 = fetch(grid, fs, x, d, offset, n - 1);
        return int3_out_right(xs[n - 1], hs[n - 3], hs[n - 2], is[n - 3], is[n - 2], y0, y1, y2, x[d]);
    }
    y0 = fetch(grid, fs, x, d, offset, p - 1);
    y1 = fetch(grid, fs, x, d, offset, p);
    y2 = fetch(grid, fs, x, d, offset, p + 1);
    y3 = fetch(grid, fs, x, d, offset, p + 2);
    return int4(xs[p], hs[p - 1], hs[p], hs[p + 1], is[p - 1], is[p], is[p + 1], y0, y1, y2, y3, x[d]);
}