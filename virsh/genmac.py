#!/usr/bin/env python

# Stolen from https://www.centos.org/docs/5/html/5.2/Virtualization/sect-Virtualization-Tips_and_tricks-Generating_a_new_unique_MAC_address.html

import virtinst.util

print "UUID: " + virtinst.util.uuidToString(virtinst.util.randomUUID())
print "MAC1: " + virtinst.util.randomMAC()
print "MAC2: " + virtinst.util.randomMAC()
print "MAC3: " + virtinst.util.randomMAC()
print "MAC4: " + virtinst.util.randomMAC()
