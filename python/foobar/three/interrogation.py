#!/usr/bin/env python

# Foreach minion, x[0] = time, x[1]/x[2] = probability of response.
inputs = [ [[5, 1, 5], [10, 1, 2]], [[390, 185, 624], [686, 351, 947], [276, 1023, 1024], [199, 148, 250]] ]
solutions = [ [1,0], [2,3,0,1] ]

minions = inputs

def answer(minions):
    orderable = map(order,range(0,len(minions)),minions)
    return map(index,sorted(orderable,key=lambda minion: minion[1]))

def order(i,minion):
    return [i,minion[0]/(1.0*minion[1]/minion[2])]

def index(minion):
    return minion[0]

for i in range(0,len(solutions)):
    print answer(inputs[i])
    print solutions[i]
