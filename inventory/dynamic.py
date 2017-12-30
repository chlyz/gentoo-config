#!/usr/bin/python

import re
import socket

host = socket.gethostname()

if host == 'petrucci':
    group = 'work'
else:
    group = 'local'

print """
{
  "%s": {
    "hosts": [
      "localhost"
    ],
    "vars": {
      "ansible_connection": "local"
    }
  }
}
""" % group
