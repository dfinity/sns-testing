#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: bjoernassmann
"""


# Global constants 
# See, https://sourcegraph.com/github.com/dfinity/ic/-/blob/rs/nervous_system/neurons_fund/src/lib.rs?L31
nf_global_contribution_cap =333 * 10**3
t_1 = 33 * 10**3
t_2 = 100 * 10**3
t_3 = 167 * 10**3

def determine_thresholds(nf_total_maturity):
    nf_10_percent = nf_total_maturity / 10
    cap = min(nf_global_contribution_cap, nf_10_percent)
    t_4 = 2 * cap
    return  t_4, cap

# Convex cube with f(t_1)=0, f(t_2) = 0.5*t_2 and f'(t_2)=2
def f_1(x, t_1, t_2, cap):
    a = t_1 / ((t_2 - t_1)**2)
    
    a = (2.0*t_1 - t_2)/(t_1**3 - 3.0*t_1**2*t_2 + 3.0*t_1*t_2**2 - t_2**3)
    b = (-8.0*t_1**2 + t_1*t_2 + t_2**2)/(2.0*t_1**3 - 6.0*t_1**2*t_2 + 6.0*t_1*t_2**2 - 2.0*t_2**3)
    c = (2.0*t_1**3 + 2.0*t_1**2*t_2 - t_1*t_2**2)/(t_1**3 - 3.0*t_1**2*t_2 + 3.0*t_1*t_2**2 - t_2**3)
    d = (-3.0*t_1**3*t_2 + t_1**2*t_2**2)/(2.0*t_1**3 - 6.0*t_1**2*t_2 + 6.0*t_1*t_2**2 - 2.0*t_2**3)
    
    return min( cap, 0.5* x, max( 0, a*x**3 + b*x**2 + c*x + d) )

# Cubic concave with f(t_2) = 0.5*t_2, f'(t_2)=2,  f(t_3) = t_3 and f'(t_3)=1
def f_2(x, t_2, t_3, cap):

    a = (2.0*t_2 - t_3)/(t_2**3 - 3.0*t_2**2*t_3 + 3.0*t_2*t_3**2 - t_3**3)
    b = (-5.0*t_2**2 - 5.0*t_2*t_3 + 4.0*t_3**2)/(2.0*t_2**3 - 6.0*t_2**2*t_3 + 6.0*t_2*t_3**2 - 2.0*t_3**3)
    c = (t_2**3 + 2.0*t_2**2*t_3 + 2.0*t_2*t_3**2 - 2.0*t_3**3)/(t_2**3 - 3.0*t_2**2*t_3 + 3.0*t_2*t_3**2 - t_3**3)
    d = (-5.0*t_2**2*t_3**2 + 3.0*t_2*t_3**3)/(2.0*t_2**3 - 6.0*t_2**2*t_3 + 6.0*t_2*t_3**2 - 2.0*t_3**3)
    
    return min(cap, x, a*x**3 + b*x**2 + c*x + d )

# Quartic concave with  f(t_3) = t_3 , f'(t_3)=1, f(t_4) = cap and f'(t_4)=0
def f_3(x, t_3, t_4, cap):
    a = (-4.0*t_3 + t_4) / (2.0*t_3**4 - 8.0*t_3**3*t_4 + 12.0*t_3**2*t_4**2 - 8.0*t_3*t_4**3 + 2.0*t_4**4)
    b = (3.0*t_3**2 + 4.0*t_3*t_4 - t_4**2) / (t_3**4 - 4.0*t_3**3*t_4 + 6.0*t_3**2*t_4**2 - 4.0*t_3*t_4**3 + t_4**4)
    c = -9.0*t_3**2*t_4 / (t_3**4 - 4.0*t_3**3*t_4 + 6.0*t_3**2*t_4**2 - 4.0*t_3*t_4**3 + t_4**4)
    d = (9.0*t_3**2*t_4**2 - 4.0*t_3*t_4**3 + t_4**4) / (t_3**4 - 4.0*t_3**3*t_4 + 6.0*t_3**2*t_4**2 - 4.0*t_3*t_4**3 + t_4**4)
    e = (t_3**4*t_4 - 4.0*t_3**3*t_4**2) / (2.0*t_3**4 - 8.0*t_3**3*t_4 + 12.0*t_3**2*t_4**2 - 8.0*t_3*t_4**3 + 2.0*t_4**4)
    
    return min(cap, x, a*x**4 + b*x**3 + c*x**2 + d*x + e )


def matching_function(x, nf_total_maturity):
    t_4, cap  = determine_thresholds(nf_total_maturity)
    if x < t_1:
        return 0
    elif t_1 <= x < t_2:
        return f_1(x, t_1, t_2, cap)
    elif t_2 <= x < t_3:
        return f_2(x, t_2, t_3, cap)
    elif t_3 <= x < t_4:
        return f_3(x, t_3, t_4, cap)
    else:
        return cap
