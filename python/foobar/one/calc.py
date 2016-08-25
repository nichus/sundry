#!/usr/bin/env python

samples = [ [ "2+3*2", "232*+" ], ["2*4*3+9*3+5", "243**93*5++"], ["8*9+7*6+1+2+4*5*6", "89*76*12456**++++" ] ]

def answer(str):
    rpn = ""
    groups = str.split('+')
    for group in groups:
        entries = group.split('*')
        for entry in entries:
            rpn += entry
        rpn += "*"*(len(entries)-1)
    rpn += "+"*(len(groups)-1)
    return rpn

for sample in samples:
    print answer(sample[0])
    print sample[1]

