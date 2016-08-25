#!/usr/bin/env python

samples = [ [[[1,3],[3,6]],5], [[[10,14],[4,18],[19,20],[19,20],[13,20]],16] ]

def answer(intervals):
    """Calculate the total number of units covered by the supplied collection of intervals"""
    while True:
        changed, intervals = iterate(intervals)
        if not changed:
            break

    covered = 0
    for interval in intervals:
        covered += interval[1] - interval[0]

    return covered

def iterate(intervals):
    ranges = [intervals.pop(0)]
    changed = False
    while (len(intervals)>0):
        interval = intervals.pop()
        merged = False
        for i in range(0,len(ranges)):
            if overlaps(interval,ranges[i]):
                ranges[i] = merge(ranges[i],interval)
                merged = True
                changed = True
        if not merged:
            ranges.append(interval)
    return changed, ranges

def overlaps(a,b):
    if (a[0]<b[1]) and (a[1]>b[0]):
        return True
    else:
        return False

def merge(a,b):
    return [min(a[0],b[0]),max(a[1],b[1])]

for sample in samples:
    print answer(sample[0])
    print sample[1]
