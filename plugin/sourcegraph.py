#!/usr/bin/env python
import vim

def output(json, buf):
    buf.append("JSON")
    del buf[0]

json = vim.eval("a:0")
buf = vim.current.buffer
output(json, buf)
