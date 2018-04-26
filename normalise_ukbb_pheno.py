#!/usr/bin/env python

import normalise as NM
import pandas as pd
import scipy as sp

import sys


def usage():
	print """ 
This script optionally transforms filtered continous phenotypes to standard normal distribution. It takes a matrix of Samples X Phenotype.
Usage:
normalising_pheno.py <pheno.tsv> <column_name> <by_cov> <expr_transform> <out_filename_prefix> 
- expr_transform = [gauss | log | none]
"""


if len(sys.argv[1:]) < 5:
	sys.stderr.write("ERROR: missing parameter\n")
	usage()
	sys.exit(1)


pheno,column,by_cov,expr_transform,phenout=sys.argv[1:]
if expr_transform == "log":
	print "Sorry. I still didn't implement other transformations. It will be set to standard normal\n"
	prefix = "log"
elif expr_transform == "gauss":
	prefix = "rnk.std"
else:
	prefix = "none"
pheno = pd.read_csv(pheno, sep='\t', index_col=[0])

def transf(Y):
	Y = Y.dropna(axis=0)
	print "After filtering, counting {0} samples\n".format(Y.shape[0])
	print "Converts the columns of the matrix to the quantiles of a standard normal\n"
	index = Y.index
	Y = Y[:].values.reshape(Y[:].shape[0],1)
	Y = NM.gaussianize(Y[:])
	return Y,index

if by_cov == 'y':
	males = pheno[pheno['Sex']==1][column]
	females = pheno[pheno['Sex']==2][column]
	print "Counting {0} males\n".format(males.shape[0])
	print "Drop NAs. If at least one NA per row then drop the Sample...\n"
	print "Counting {0} females\n".format(females.shape[0])
	print "Drop NAs. If at least one NA per row then drop the Sample...\n"
	Ymales,index_males = transf(males)
	Yfemales,index_females = transf(females)
else:
	pheno = pheno[column]
	print "Counting {0} samples\n".format(pheno.shape[0])
	print "Drop NAs. If at least one NA per row then drop the Sample...\n"
	Y,index = transf(pheno)

print "Done.\nWriting into file...\n"

if by_cov == 'y':
	df = pd.DataFrame(Ymales)
	df = df.set_index(index_males)
	df.to_csv(phenout+"."+prefix+'.males.tsv',header=[column],index=True,sep='\t')
	df = pd.DataFrame(Yfemales)
	df = df.set_index(index_females)
	df.to_csv(phenout+"."+prefix+'.females.tsv',header=[column],index=True,sep='\t')
else:
	df = pd.DataFrame(Y)
	df = df.set_index(index)
	df.to_csv(phenout+"."+prefix+'.tsv',sep='\t',header=[column],index=True)

print "All done!"
sys.exit(0)

