#!/usr/bin/env python
import vim
import json

def output(srcOutput):
    try:
        s = json.dumps(info, indent=4)
    except  ValueError:
        s = srcOutput
    return s

def write(string, buf):
    for line in string.split('\n'):
        buf.append(line)
    del buf[0]

srcOutput = vim.eval("a:content")
buf = vim.current.buffer
string = output(srcOutput)
write(string, buf)
