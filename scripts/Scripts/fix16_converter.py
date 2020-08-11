#/usr/bin/env python3

import sys
import math

def Q_to_float(q, bits):
    return float(q) * pow(2, -bits)

def float_to_Q(f, bits):
    return int(f * pow(2, bits));

if len(sys.argv) < 2:
	print("Usage:")
	print("    ./float_to_fix16.py FLOAT ...")
	print("    ./float_to_fix16.py 0xHEX ...")
	exit(1)

for num in sys.argv[1:]:
	# If hex -> float
	if('x' in num ) or ('X' in num):
		val = int(num,16)
		f = Q_to_float(val, 16)
		print("%s -> %0.8f" % ("0x" + format(val, 'X').rjust(8, '0'), f))
	else: # If float -> hex
		val = float(num)
		q = float_to_Q(val, 16)
		print("%0.8f -> %0.8f (%s)" % (val, Q_to_float(q,16), "0x" + format(q, 'X').rjust(8, '0')))

