def step(digest,prev_m):
    k = 0
    while True:
        rem = ((digest ^ prev_m) + k * 256) % 129
        if rem == 0:
            return ((digest ^ prev_m) + k * 256) / 129
        else:
            k = k + 1

def answer(digest):
    prev = 0
    message = []
    for index, num in enumerate(digest):
        if index == 0:
            message.append(step(num,0))
        else:
            message.append(step(num,message[-1]))

    return message
