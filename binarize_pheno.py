#!/usr/bin/env python

import sys
import fileinput
import pandas as pd
import scipy as sp

if len(sys.argv[1:]) < 3:
	sys.stderr.write('Error: Missing argument\nUsage: script.py <table.tsv> <file.header.tsv> <fileout.tsv> \n')
	sys.exit(1)


#col_file contains 2 columns: the first with the ID of the phenotype field and the 2nd wth description
col_file = pd.read_csv(sys.argv[2],sep='\t')
outfile = sys.argv[3]
col = {}
col_index = {}
final_dict = {}
file_indexes = []
for x in xrange(col_file.shape[0]):
	key = col_file.iloc[x,:][1]
	value = col_file.iloc[x,:][0]
	if key not in col:
		col[key]=[value]
		col_index[key]=[]
		final_dict[key] = []
	else:
		col[key].append(value)

for line in fileinput.input(sys.argv[1]):
	line = line.split('\t')
	line = map(lambda x:x.strip(),line)
	if line[0].startswith('Sample'):
		header = line
		for k,y in col.iteritems():
			for z in y:
				index = header.index(z)
				col_index[k].append(index)
	else:
		file_indexes.append(str(line[0]))
		for k in col_index:
			v = sp.array(line)
			vv = v[col_index[k]]
			if 'deaf' in vv and 'No' not in vv and 'Not' not in vv: #for cochlear phenotype
				final_dict[k].append('Yes')
			elif 'Yes' in vv and 'No' not in vv and 'Not' not in vv:
				final_dict[k].append('Yes')
			elif 'No' in vv and 'Yes' not in vv and 'Not' not in vv:
				final_dict[k].append('No')
			elif 'Yes' in vv and 'No' in vv and 'Not' not in vv:
				final_dict[k].append('NA')
			else:
				final_dict[k].append('NA')

df = pd.DataFrame(final_dict)
df = df.set_index([file_indexes])
df.to_csv(outfile,sep='\t',header=True,index=True)

#new_header= 'Sample_ID\t'+'\t'.join(columns)+'\n'
