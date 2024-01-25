#!/usr/bin/env python3
# Copyright (c) 2024 Egor
# SPDX-License-Identifier: GPL-2.0-or-later
import struct
import argparse
from PIL import Image
def extractdpm(args):
    dpm = args.dpm.read()
    magic, dataoffset, filecount, unk = struct.unpack('<4sIII', dpm[:16])
    assert magic == b'DPMX'
    print(magic, dataoffset, filecount, unk)
    for i in range(filecount):
        fn, unk, key, ofs, siz = struct.unpack('<16sIIII', dpm[16+32*i:16+32*(i+1)])
        assert unk == 0xffffffff
        assert key == 0
        fn = fn.split(b'\0')[0].decode()
        print(fn, ofs, siz)
        if not args.n:
            with open(fn, 'wb') as f:
                f.write(dpm[dataoffset+ofs:dataoffset+ofs+siz])
def replacedpmbmp(args):
    # a tom of assumptions about the image format on both sides
    with Image.open(args.replacement).transpose(Image.Transpose.FLIP_TOP_BOTTOM) as img:
        pal = img.getpalette('RGB')
        pal += [0]*(3*256-len(pal))
        replen = 4*256+img.width*img.height
        repdata = bytearray(replen)
        for i in range(256):
            repdata[i*4:i*4+3] = pal[i*3:i*3+3][::-1]
            repdata[i*4+3] = 0
        repdata[4*256:] = img.tobytes()
    dpm = bytearray(args.dpm.read())
    magic, dataoffset, filecount, unk = struct.unpack('<4sIII', dpm[:16])
    assert magic == b'DPMX'
    for i in range(filecount):
        fn, unk, key, ofs, siz = struct.unpack('<16sIIII', dpm[16+32*i:16+32*(i+1)])
        assert unk == 0xffffffff
        assert key == 0
        fn = fn.split(b'\0')[0].decode()
        if fn == args.entry:
            dpm[dataoffset+ofs+0x36:dataoffset+ofs+0x36+replen] = repdata
    args.out.write(dpm)
def decrypt(buf, i, j):
    buf2 = bytearray(len(buf))
    x = 0
    for k in range(len(buf)):
        x = buf2[k] = (((buf[k]-j)^i)+x)&0xff
    return buf2
def encrypt(buf, i, j):
    buf2 = bytearray(len(buf))
    x = 0
    for k in range(len(buf)):
        buf2[k] = (((buf[k]-x)^i)+j)&0xff
        x = buf[k]
    return buf2
def patchexe(args):
    exe = bytearray(args.exe.read())
    dpmxoff = exe.rfind(b'DPMX')
    dpm = exe[dpmxoff:]
    magic, dataoffset, filecount, unk = struct.unpack('<4sIII', dpm[:16])
    assert magic == b'DPMX'
    assert filecount == 1
    fn, unk, key, ofs, siz = struct.unpack('<16sIIII', dpm[16:16+32])
    fn = fn.split(b'\0')[0].decode()
    assert fn == 'start.ax'
    assert unk == 0xffffffff
    ax = dpm[dataoffset+ofs:dataoffset+ofs+siz]
    for k1 in range(128):
        k2 = (ax[0]-(ord('H')^k1)) & 255
        if decrypt(ax[:4], k1, k2) == b'HSP3':
            break
    else:
        raise ValueError("bruteforce failed")
    ax = decrypt(ax, k1, k2)
    if args.scale:
        code = b'\1\x20\0\0\0\0\x08\0\1\0\0\0\4\0\1\0\0\0\0\0\4\0\3\0\0\0\4\0'
        rep = bytearray(code)
        rep[-6] = args.scale
        ax = ax.replace(code, rep)
    if args.dpmname:
        assert len(args.dpmname) <= len('data\\data.dpm')
        code = b'DPM:data\\data.dpm:chip_\0'
        rep = b'DPM:' + args.dpmname.encode() + b':chip_\0'
        rep += bytes(len(code)-len(rep))
        ax = ax.replace(code, rep)
    ax = encrypt(ax, k1, k2)
    exe[dpmxoff+dataoffset+ofs:dpmxoff+dataoffset+ofs+siz] = ax
    args.out.write(exe)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(required=True)
    parser_extractdpm = subparsers.add_parser('extractdpm')
    parser_extractdpm.add_argument('dpm', type=argparse.FileType('rb'))
    parser_extractdpm.add_argument('-n', action='store_true')
    parser_extractdpm.set_defaults(func=extractdpm)
    parser_replacedpmbmp = subparsers.add_parser('replacedpmbmp')
    parser_replacedpmbmp.add_argument('dpm', type=argparse.FileType('rb'))
    parser_replacedpmbmp.add_argument('entry')
    parser_replacedpmbmp.add_argument('replacement', type=argparse.FileType('rb'))
    parser_replacedpmbmp.add_argument('out', type=argparse.FileType('wb'))
    parser_replacedpmbmp.set_defaults(func=replacedpmbmp)
    parser_patchexe = subparsers.add_parser('patchexe')
    parser_patchexe.add_argument('exe', type=argparse.FileType('rb'))
    parser_patchexe.add_argument('--scale', type=int)
    parser_patchexe.add_argument('--dpmname')
    parser_patchexe.add_argument('out', type=argparse.FileType('wb'))
    parser_patchexe.set_defaults(func=patchexe)
    args = parser.parse_args()
    args.func(args)
