#!/usr/bin/env python

import sys
import struct
import scipy as sp


if len(sys.argv[1:])< 2:
	sys.stderr.write('ERROR:\nArgument missing\nUsage: script.py <file.bin>  <file.txt>\n')
	sys.exit(1)

## number of lines expected 265 SNPs X 2 X ~400000 samples
n_snps = 265
n_samples = 488377

n_tot = n_snps*2*n_samples 
#258839810
#args
a,out = sys.argv[1:]
#open file
a = open(a,'rb')
#intitialize empty array
ea = sp.empty((n_samples,n_snps*2))

f_values = []
for x in xrange(n_tot):
	f_values.append(round(struct.unpack('f', a.read(4))[0],2))

c = 0
start = 0
while c<=(n_snps*2):
	i = (n_samples*2)
	end = start+i
	f_slice = f_values[start:end]
	aa = sp.array(f_slice).reshape(n_samples,2) #take one allele at the time
	ea[:,c:(c+2)] = aa #populate the empty array 
	start = end
	c +=2

sp.savetxt(out,ea,delimiter='\t',fmt='%1.2f')

sys.exit(0)


