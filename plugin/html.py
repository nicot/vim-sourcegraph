#!/usr/bin/env python
import vim

def write(string, buf):
    for line in string.split('\n'):
        buf.append(line)
    del buf[0]

html = vim.eval('a:html')
buf = vim.current.buffer
write(html, buf)
