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
        recurse_minions([i],minions,1-probabilityOf(minion),minion[0])

    return optimal[0]

def recurse_minions(used,minions,pn,t):
    global optimal
    for i, minion in enumerate(minions):
        try:
            used.index(i)
            next
        except ValueError:
            # Counterintuitive warning: ValueError indicates that 'i' does not
            # exist within the list of currently used minions.  This means that
            # we process this minion.  Lack of ValueError indicates that this
            # minion has already been processed.
            p = pn*(1-probabilityOf(minion))
            time = t + (pn*minion[0])
            curr = used+[i]
            if len(curr) == len(minions):
                if len(optimal[0])>0:
                    if time < optimal[1]:
                        optimal[0] = curr
                        optimal[1] = time
            else:
                recurse_minions(curr,minions,p,time)

def probabilityOf(minion):
    return ((1.0*minion[1])/minion[2])

for i in range(0,len(solutions)):
    print answer(inputs[i])
    print solutions[i]
