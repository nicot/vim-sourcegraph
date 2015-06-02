#!/usr/bin/env python
import vim

def output(json, buf):
    buf.append(json)
    del buf[0]

json = vim.eval("a:content")
buf = vim.current.buffer
output(json, buf)
