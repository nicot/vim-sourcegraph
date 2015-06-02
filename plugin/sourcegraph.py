#!/usr/bin/env python
import vim
import json

def output(srcOutput, buf):
    try:
        js = json.loads(srcOutput)
        s = json.dumps(js, indent=2)
        for line in s.split('\n'):
            buf.append(line)
    except  ValueError:
        buf.append(srcOutput)
    del buf[0]

srcOutput = vim.eval("a:content")
buf = vim.current.buffer
output(srcOutput, buf)
