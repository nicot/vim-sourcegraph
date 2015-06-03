#!/usr/bin/env python
import vim
import re
import json
from string import Template

def definition(src):
    t = Template('''\
 Name: $name
 Type: $Type
 Kind: $kind
 Import Path: $packageImportPath
 File: $File

 Source:
 $source

 ''')
    s = t.substitute(name=src['Name'], Type=src['Data']['TypeString'],
            kind=src['Kind'], packageImportPath=src['Data']['PackageImportPath'],
            File=src['File'], source=readBuffer(src['File'], src['DefStart'], src['DefEnd']))
    return s

def readBuffer(path, start, stop):
    with open(path) as f:
        f.seek(start)
        s = f.read(stop-start)
        s = s.replace("\n", "\n ")
        return s

def output(srcOutput):
    try:
        info = json.loads(srcOutput)
        s = ""
        if 'Def' in info:
            s = definition(info['Def'])
            s += json.dumps(info, indent=4)
        else:
            s = json.dumps(info, indent=4)
    except  ValueError:
        s = srcOutput
    return s

def write(string, buf):
    for line in string.split('\n'):
        buf.append(line)
    del buf[0]

srcOutput = vim.eval('a:content')
buf = vim.current.buffer
string = output(srcOutput)
write(string, buf)
