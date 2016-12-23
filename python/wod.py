#!/usr/bin/env python
"""
    Simply display the word of the day, with meaning sourced from merriam-webster
"""

import os
import argparse
from datetime import date
import requests
from lxml import html

RED     = "\033[1;33m"
PURPLE  = "\033[0;35m"
NC      = "\033[0m"


def cache_directory():
    return os.path.join(os.environ['HOME'],'.wod')

def cache_filename():
    filename = date.today().strftime('%Y%m%d.cache.html')
    return os.path.join(cache_directory(),filename)

def is_cached():
    if not os.path.exists(cache_directory()):
        os.mkdir(cache_directory(),0755)
    if os.path.exists(cache_filename()):
        return True
    return False

def parse_and_display(content):
    tree = html.fromstring(content)

    word = tree.xpath('//h1/text()')[0]
    attribute  = tree.xpath('//span[@class="main-attr"]/text()')[0]
    syllables  = tree.xpath('//span[@class="word-syllables"]/text()')[0]
    definition = tree.xpath('//div[@class="wod-definition-container"]/p[1]')[0].text_content().replace(': ','',1).capitalize()

    try:
        alternate   = tree.xpath('//div[@class="wod-definition-container"]/p[1]/a[1]/text()')[0]
    except IndexError:
        alternate   = ""

    print "Word of the Day: %s%s : %s (%s)%s"   % (RED, word, attribute, syllables, NC)
    if alternate:
        print "        Meaning: %s%s : %s%s"    % (PURPLE, definition, alternate, NC)
    else:
        print "        Meaning: %s%s%s"         % (PURPLE, definition, NC)

def read_cached(filename):
    return open(filename, "r").read()

def fetch_content():
    url = 'http://www.merriam-webster.com/word-of-the-day'
    response = requests.get(url)
    content = ""

    if response.status_code == 200:
        content = response.content
        f = open(cache_filename(),'w')
        f.write(content)
        f.close()
    else:
        print "No word of the day, %s" % (response.content)

    return content

def main():
    parser = argparse.ArgumentParser(description="Grab and display the current word of the day")
    parser.add_argument("--debug", type=str, help="Grab a local file for iterative testing, rather than the actual site content")
    args = parser.parse_args()

    content = ""

    if args.debug:
        content = read_cached(args.debug)
    elif is_cached():
        content = read_cached(cache_filename())
    else:
        content = fetch_content()

    if content:
        parse_and_display(content)
        print

if __name__ == "__main__":
    main()
