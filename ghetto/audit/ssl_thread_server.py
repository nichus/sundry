#!/usr/bin/env python

"""Simple HTTP Server With Upload and SSL.
This module builds on BaseHTTPServer by implementing the standard GET
and HEAD requests in a fairly straightforward manner.

Create a certificate using the hostname or IP address as the common name with
the following command: openssl req -new -x509 -keyout server.pem -out server.pem -days 365 -nodes
Enter that path under /path/to/cert
"""

__version__ = "0.2"
__all__ = ["SimpleHTTPRequestHandler"]
__author__ = "bones7456"
__home_page__ = "http://li2z.cn/"
__ssl_addition__ = 'rhmoult'

import sys
import os
#import sys  # Modification by rmoulton
#import ssl  # Modification by rmoulton

try:
    from cStringIO import StringIO
    from SocketServer import ThreadingMixIn
    from BaseHTTPServer import HTTPServer
    from SimpleHTTPServer import SimpleHTTPRequestHandler
except ImportError:
    from StringIO import StringIO
    from socketserver import ThreadingMixIn
    from http.server import SimpleHTTPRequestHandler, HTTPServer

class ThreadingSimpleServer(ThreadingMixIn, HTTPServer):
    pass

def main(HandlerClass=SimpleHTTPRequestHandler, ServerClass=HTTPServer, protocol="HTTP/1.0"):

    if sys.argv[1:]:
        port = int(sys.argv[1])
    else:
        port = 8000

    if sys.argv[2:]:
        os.chdir(sys.argv[2])

    server_address = ('', port)

    server = ThreadingSimpleServer(server_address, SimpleHTTPRequestHandler)

    try:
        while 1:
            sys.stdout.flush()
            server.handle_request()
    except KeyboardInterrupt:
        print("Finished")
    #HandlerClass.protocol_version = protocol
    #httpd = ServerClass(server_address, HandlerClass)

    #sa = httpd.socket.getsockname()
    #print "Serving HTTP on", sa[0], "port", sa[1], "..."
    #httpd.socket = ssl.wrap_socket(httpd.socket, certfile='/path/to/cert', server_side=True)
    #httpd.serve_forever()


if __name__ == '__main__':
    main()
