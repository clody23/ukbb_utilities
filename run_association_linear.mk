#; -*- mode: Makefile;-*
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

samples_file ?= samples.txt
ped_file_name ?= file_ped
covariate_file ?= covariates.txt
phenotype_file ?= pheno.plink.tsv
out_prefix ?= out
out_dir ?= ./
conf ?= test.conf
assoc_type ?= logistic
mpheno ?= 1
maf ?= 0.01
missing ?=0.1

#all: $(out_dir)/tmp/subset_pheno.tsv $(out_dir)/plink.done clean
all: $(out_dir)/plink.done clean

include $(conf)

#$(out_dir)/tmp/subset_pheno.tsv: $(samples_file) $(phenotype_file)
#	mkdir -p $(out_dir)/tmp &&\
	echo "Subsetting the phenotype on unrelated individuals only..."
#	python /data/genomics/cc926/scripts/merge_tables.py $(samples_file) $(phenotype_file) Family_ID Family_ID inner $(out_dir)/tmp/subset_pheno.tmp.tsv &&\
	echo 'Family_ID' > $(out_dir)/tmp/genotype.samples.txt; cut -f 1 $(ped_file_name)*.ped  >> $(out_dir)/tmp/genotype.samples.txt &&\
	python /data/genomics/cc926/scripts/merge_tables.py $(out_dir)/tmp/genotype.samples.txt  $(out_dir)/tmp/subset_pheno.tmp.tsv Family_ID Family_ID inner $(out_dir)/tmp/subset_pheno.tsv

$(out_dir)/plink.done: $(phenotype_file) $(covariate_file) $(samples_file)
	mkdir -p $(out_dir)/plink_results &&\
	plink --noweb --file $(ped_file_name) --pheno $(phenotype_file) --mpheno $(mpheno) --covar $(covariate_file) --linear --beta --out $(out_dir)/plink_results/$(out_prefix) --maf $(maf) --geno $(missing) --keep $(samples_file) --adjust &&\
	touch plink.done

.PHONY: clean
clean:
	mv plink.done plink.old

