#!/usr/bin/env python3

import socket
import sys

def get_header(sock):
    try:
        data = sock.recv(4096, socket.MSG_DONTWAIT) # 0x40 : O_NONBLOCK
        #sys.stdout.write(data)
        print(data.decode("utf-8"), end="")
    except socket.error as msg:
        # Nothing left
        pass

try:
    sock = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
except socket.error as msg:
    print(msg)
    sys.exit(1)

try:
    sock = socket.create_connection((sys.argv[1], sys.argv[2]),60)
except socket.error as msg:
    print(msg)
    sock.close()
    sys.exit(1)

if sock is None:
    print('Unable to connect')
    sys.exit(2)

#sock.setblocking(0)
sock.shutdown(socket.SHUT_WR)
print("Connected to %s:%s" % (sys.argv[1],sys.argv[2]))
get_header(sock)
sock.close()
