#!/usr/bin/env python


"""
Process:

    Phase 1:
        Iterate over directory full of files, for all closed files, collect
        contents into singular file, generate metadatafile containing
        auditreport (aureport), 4 checksums (2 each for raw and compressed
        forms), compress content, name in a consistent fashion, remove source
        files.
    Phase 2a:
        Translate input into json format, and filter to "interesting" events,
        store in reduced directory
    Phase 2b (instead of 2a):
        Translate input into json format, and store in database.
    Phase 3:
        TBD
"""

import os
import sys
import glob

def file_open(target):
    """
    Implement a test for open files
    """
    fds = glob.glob('/proc/[0-9]*/fd/*')
    for fd in fds:
        if not os.access(fd,os.R_OK):
            continue
        try:
            fname = os.readlink(fd)
            if fname == target:
                return True
        except OSError as err:
            if err.errno != 2:
                raise(err)
    return False

def main():
    """
    Executable mainline function
    """
    if os.geteuid() != 0:
        print "This script must run as root, engaging sudo-powers..."
        os.execv('/usr/bin/sudo', ['python'] + sys.argv)
        sys.exit('Running sudo failed somehow, please remedy')

    auditdir    = '/var/log/audit'
    auditfiles  = glob.glob(auditdir+'/audit.log.*')

    if file_open('/var/log/audit/audit.log'):
        print "It's open"
    else:
        print "Not open"

if __name__ == "__main__":
    main()
