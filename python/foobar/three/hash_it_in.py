#!/usr/bin/env python
"""
Use the big brain on Brad, err yourself, to attempt to find the formula they want.
"""
import itertools
import sys

inputs = [
            [0, 129, 3, 129, 7, 129, 3, 129, 15, 129, 3, 129, 7, 129, 3, 129],
            [0, 129, 5, 141, 25, 137, 61, 149, 113, 145, 53, 157, 233, 185, 109, 165]
        ]
solutions = [
            [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
            [0, 1, 4, 9, 16, 25, 36, 49, 64, 81, 100, 121, 144, 169, 196, 225]
            ]

def mult(a,b):
    return a * b
def mod(a):
    return a % 256
def xor(a,b):
    return a ^ b

def dereference(operand,c,i0,i1):
    if operand == "c":
        return c
    elif operand == "i0":
        return i0
    elif operand == "i1":
        return i1

def calculate(c,i0,i1,operands,operators):
    result = dereference(operands.pop(0),c,i0,i1)
    for operator in operators:
        if operator == "mult":
            result = mult(result,dereference(operands.pop(0),c,i0,i1))
        elif operator == "xor":
            result = xor(result,dereference(operands.pop(0),c,i0,i1))
        elif operator == "mod":
            result = mod(result)
    return result

def previous(idx,digest):
    return digest[idx-1] if idx>0 else 0

def first_tier(i0,i1,o):
    possibilities = []
    operands = list(itertools.permutations([ "c", "i0", "i1" ]))
    operations = {
            "*^%": ["mult","xor","mod"],
            "*%^": ["mult","mod","xor"],
            "^*%": ["xor","mult","mod"],
            "^%*": ["xor","mod","mult"],
            "*%^": ["mod","mult","xor"],
            "*^%": ["mod","xor","mult"]
            }

    for oidx,operand in enumerate(operands):
        for rname,rators in operations.iteritems():
            for const in range(0,255):
                result = calculate(c=const,i0=i0,i1=i1,operands=list(operand),operators=rators)
                if result == o:
                    possibilities.append([const,operand,rators])
                    #print "c=%d, operand=%s, operators=%s [%d=%d]" %(const,operand,rators,result,o)

    return possibilities

def later_tier(n,trials,i0,i1,o):
    print "Tier #%x starting ---------------------------------------------------------------" %(n+1)
    possibilities = []
    for trial in trials:
        result = calculate(c=trial[0],i0=i0,i1=i1,operands=list(trial[1]),operators=trial[2])
        if result == o:
            possibilities.append([trial[0],trial[1],trial[2]])
            print "c=%d, operand=%s, operators=%s [%d=%d]" %(trial[0],trial[1],trial[2],result,o)

    print "Tier #%x complete (%8d) possibilities found --------------------------------" %(n+1,len(possibilities))
    return possibilities

def main():
    digest = inputs[0]
    target = solutions[0]

    print "Tier #1 starting ---------------------------------------------------------------"
    possibilities = first_tier(previous(0,digest),digest[0],target[0])
    print "Tier #1 complete (%8d) possibilities found --------------------------------" %(len(possibilities))

    for i in range(1,len(target)):
        if len(possibilities) == 0:
            print "No solution found"
            sys.exit(1)
        possibilities = later_tier(i,possibilities,previous(i,digest),digest[i],target[i])

if __name__ == "__main__":
    main()
