#!/usr/bin/env python

import sys
import struct
import scipy as sp


if len(sys.argv[1:])< 2:
	sys.stderr.write('ERROR:\nArgument missing\nUsage: script.py <file.bin>  <file.txt>\n')
	sys.exit(1)

## number of lines expected 265 SNPs X 2 X ~400000 samples
n_snps = 265
#n_samples = 2
#n_samples = 488377
n_samples = 500000
n_tot = n_snps*2*n_samples 
#258839810
#args
a,out = sys.argv[1:]
#open file
a = open(a,'rb')

f_values = []
for x in xrange(n_tot):
	f_values.append(round(struct.unpack('f', a.read(4))[0],2))
#reshaping the dataset
f_values = sp.array(f_values).reshape(n_snps*2,n_samples)
sp.savetxt(out,f_values,delimiter='\t',fmt='%1.2f')

sys.exit(0)


