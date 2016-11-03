#!/usr/bin/python

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

ssl_sock = ssl.wrap_socket(s,keyfile="client.key", certfile="client.crt",ca_certs="ca.crt", cert_reqs,ssl.CERT_REQUIRED)

ssl_sock.connect(('127.0.0.1', 8080))

print repr(ssl_sock.getpeername())
print ssl_sock.cipher()
print pprint.pformat(ssl_sock.getpeercert())

ssl_sock.write("testing")
data = ssl_sock.read()
print data

ssl_sock.close()
