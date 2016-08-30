#!/usr/bin/env python

samples = [ [[1,4,1],3], [[1,2],1] ]

def answer(x):
    """Find the number of cars that can be made an equal weight via bunny redistribution between cars"""
    remainder = sum(x)%(len(x))
    return len(x) if (remainder==0) else len(x)-1

for sample in samples:
    print answer(sample[0])
    print sample[1]
