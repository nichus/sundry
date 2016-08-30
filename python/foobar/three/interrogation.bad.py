#!/usr/bin/env python

# Foreach minion, x[0] = time, x[1]/x[2] = probability of response.
inputs = [ [[5, 1, 5], [10, 1, 2]], [[390, 185, 624], [686, 351, 947], [276, 1023, 1024], [199, 148, 250]] ]
solutions = [ [1,0], [2,3,0,1] ]

minions = inputs

def answer(minions):
    """Calculate the optimal interrogation order, providing the answer in the shortest time"""
    """ T[1] + (1-P[1])*T[2] + (1-P[1])(1-P[2])*T[3]"""

    optimal = [ [], 0 ]

    for i,minion in enumerate(minions):
        optimal = goDeeper(optimal,[i],minions,1-probabilityOf(minion),minion[0])

    return optimal[0]

def goDeeper(optimal,used,minions,pn,t):
    """My recursion function to evaluate all the combinations of interrogation orders"""
    for i, minion in enumerate(minions):
        if i not in used:
            p = pn*(1-probabilityOf(minion))
            time = t + (pn*minion[0])
            curr = used+[i]

            if len(curr) == len(minions):
                if len(optimal[0])>0:
                    if time < optimal[1]:
                        optimal = [ curr, time ]
                else:
                    optimal = [ curr, time ]
            else:
                optimal = goDeeper(optimal,curr,minions,p,time)
    return optimal

def probabilityOf(minion):
    return ((1.0*minion[1])/minion[2])

for i in range(0,len(solutions)):
    print answer(inputs[i])
    print solutions[i]

