#!/usr/bin/env python

import argparse
import subprocess
import getpass
import jinja2
import re
import os

THIS_DIR    = os.path.dirname(os.path.abspath(__file__))
jinja2env   = jinja2.Environment(loader=jinja2.FileSystemLoader("%s/templates" % THIS_DIR), keep_trailing_newline=True)

SHELLS      = [ '/bin/bash', '/bin/csh', '/bin/zsh' '/bin/sh', '/bin/ksh' ]

def unboundldapcommand( cmd, args ):
    basecmd =   [
                    '/usr/bin/%s' % cmd,
                    '-x',
                ]
    return basecmd + args;

def boundldapcommand( cmd, args ):
    basecmd =   [
                    '/usr/bin/%s' % cmd,
                    '-x',
                    '-D',
                    '"uid=%s,ou=people,dc=itap,dc=com"' % getpass.getuser(),
                ]
    return basecmd + args;

def get_groups():
    p = subprocess.Popen(unboundldapcommand('ldapsearch', [ '-b', 'ou=groups,dc=itap,dc=com', '(objectclass=posixgroup)', 'cn gidnumber']), stdout=subprocess.PIPE)
    (standardout,stderr) = p.communicate()

    groups = []
    cnmatch = re.compile('cn: (\w+)')
    for line in standardout.split():
        cn = cnmatch.match(line)
        if cn:
            groups.append(cn.group(1))

    return groups;

def get_users():
    p = subprocess.Popen(unboundldapcommand('ldapsearch', [ '-b', 'ou=people,dc=itap,dc=com', '(objectclass=posixaccount)', 'uid uidnumber']), stdout=subprocess.PIPE)
    (standardout,stderr) = p.communicate()

    names = {}
    uids  = {}
    namematch   = re.compile('uid: (\w+)')
    uidmatch    = re.compile('uidnumber: (\d+)')

    for line in standardout.split():
        name = namematch.match(line)
        if name:
            names[name.group(1)] = True
        uid  = uidmatch.match(line)
        if uid:
            uids[uid.group(1)] = True

    return { 'names': names, 'uids': uids };


def jinja_groups(j2,attrs):
    "group_add.ldif template defines: cn, username"

    for group in attrs.groups:
        print j2.get_template("group_add.ldif").render(attrs)

    return;

def jinja_user(j2,attrs):
    "user_add.ldif template defines: username, password, first, last, email, site, uid, gid, fullname, shell, manager, company, phone, expiration"

    print j2.get_template("user_add.ldif").render(attrs)

    return;

def adjust_user(base):
    user = base

    existing = get_users()

    if 'username' not in user:
        user['username'] = (user['first'][0] + user['last'])[0:8].lower()

    if 'fullname' not in user:
        user['fullname'] = "%s %s" % [ user['first'], user['last'] ]

    if 'uidnumber' not in user:
        # Someday, someone will screw up my nice uid numbering, then this
        # function will have to get ugly to fill in the empty slots.  Please
        # don't be that person.
        user['uidnumber'] = max(map(int,existing['uids'].keys())) + 1

    return user;

def parse_args(group_list,shell_list):
    parser = argparse.ArgumentParser(description='Create new ITAP user accounts')
    parser.add_argument('-f', '--first', type=str, required=True, help="First Name")
    parser.add_argument('-l', '--last',  type=str, required=True, help="Last Name")
    parser.add_argument('-e', '--email', type=str, required=True, help="unclassified email address")
    parser.add_argument('-p', '--phone', type=str, required=True, help="business contact phone number")
    parser.add_argument('-s', '--site',  type=str, required=True, help="business site")
    parser.add_argument('-m', '--manager',  type=str, required=True, help="manager's name")
    parser.add_argument('-c', '--company',  type=str, required=True, help="employer's name")
    parser.add_argument('--fullname', type=str, help="A specific full name, incase <first> <last> is insufficient")
    parser.add_argument('-u', '--username', type=str, help="username, default is first initial, last name (8 chars)")
    parser.add_argument('-U', '--uidnumber', type=str, help="default is next available uid")
    parser.add_argument('-S', '--shell', type=str, help="login shell, default is bash", choices=shell_list,
                                            default="/bin/bash")
    parser.add_argument('-g', '--groups', type=str, nargs='+', help="one or more additional groups (everyone is in users)",
                                            choices=group_list)

    args = parser.parse_args()

    phonematch=re.match('(\d{3}).*(\d{3}).*(\d{4})',args.phone)
    if phonematch:
        args.phone = "%03d %03d-%04d" % phonematch.group(1,2,3)
    else:
        print "Phone number not in a valid format: NNN AAA-BBBB\n"
        sys.exit(1);

    return adjust_user(vars(args));

def create_user():
    user = parse_args(get_groups(),SHELL_LIST)

    jinja_groups(jinja2env,user)
    jinja_user(jinja2env,user)

if __name__ == '__main__':
    create_user()
