#!/usr/bin/env python3
"""Experimental literal conversion model. NOT wired to HarbourRust or codegen.

Returns abstract type/payload/width/dec fields only. No ABI choice is made.
Bounds: byte strings <=4096, at most17 decimal places, finite F64 result.
"""
import math
import struct


def parse_literal(text):
    if not isinstance(text, bytes):
        raise ValueError('literal gate requires constant byte-string input')
    if len(text) > 4096:
        raise ValueError('literal gate input exceeds4096bytes')
    n=len(text)
    i=0
    while i<n and text[i] in b' \t\r\n':
        i+=1
    negative=i<n and text[i]==45
    if i<n and text[i] in (43,45):
        i+=1
    width=i
    integer=0
    floating=0.0
    overflow=False
    point=False
    decimals=0
    suffix_decimals=0
    while i<n:
        c=text[i]
        if 48<=c<=57:
            digit=c-48
            if overflow:
                floating=floating*10.0+digit
            elif integer <= (9223372036854775807-digit)//10:
                integer=integer*10+digit
            else:
                floating=float(integer)*10.0+digit
                overflow=True
            if point:
                decimals+=1
            else:
                width+=1
        elif c==46 and not point:
            point=True
        else:
            if not point:
                while i<n:
                    c=text[i]
                    i+=1
                    if c==46:
                        point=True
                        break
                    width+=1
            if point:
                suffix_decimals=n-i
            break
        i+=1
    if decimals+suffix_decimals>17:
        raise ValueError('literal gate decimal metadata exceeds17')
    if negative:
        if overflow:
            floating=-floating
        else:
            integer=-integer
    double=overflow or point
    if double:
        if not overflow:
            floating=float(integer)
        if decimals:
            floating/=10.0**decimals
        if not math.isfinite(floating):
            raise ValueError('literal gate nonfinite F64 not admitted')
    if width>10:
        value=floating if double else integer
        width=20 if value>9999999999 or value< -999999999 else 10
    elif decimals+suffix_decimals==0:
        width=n
    elif width==0:
        width=1
    elif negative and width==1 and floating!=0:
        width=2
    if width<=0 or width>99:
        width=20 if (floating if double else integer)>9999999999 or (floating if double else integer)< -999999999 else 10
    payload=struct.pack('>d',floating).hex() if double else str(integer)
    return ['F64' if double else 'INT',width,decimals+suffix_decimals,payload]


def lower_literal(text):
    """Deliberately unavailable: metadata tuple is not an ABI value."""
    parse_literal(text)
    raise ValueError('Val lowering is parked: numeric width metadata representation is undecided; no codegen permitted')
