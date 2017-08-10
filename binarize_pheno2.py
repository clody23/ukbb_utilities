#!/usr/bin/env python

import sys
import pandas as pd
import scipy as sp


table,outfile = sys.argv[1:]


table = pd.read_csv(table,sep='\t',index_col=0)

table.fillna(0,inplace=True)

val_dict = {}
for x in xrange(table.shape[1]):
	v = sp.unique(table.iloc[:,x].values[sp.where(table.iloc[:,x].values!=0)[0]])
	for k in v:
		if k not in val_dict and k!= 'Do not know' and k!= 'Prefer not to answer' and k != '-1' and k != '-3':
			val_dict[k] = []

for x in xrange(table.shape[0]):
	print x
	for k in val_dict:
		if k in table.iloc[x,:].values.tolist():
			val_dict[k].append('Yes')
		else:
			val_dict[k].append('No')



df = pd.DataFrame(val_dict)
df = df.set_index([table.index])
df.to_csv(outfile,sep='\t',header=True,index=True)
