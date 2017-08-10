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
mpheno ?= 1

all: $(out_dir)/tmp/subset_pheno.tsv $(out_dir)/plink.done clean

include $(conf)

$(out_dir)/tmp/subset_pheno.tsv: $(samples_file) $(phenotype_file)
	mkdir -p $(out_dir)/tmp &&\
	echo "Subsetting the phenotype on unrelated individuals only..."
	python /data/genomics/cc926/scripts/merge_tables.py $(samples_file) $(phenotype_file) Family_ID Family_ID inner $(out_dir)/tmp/subset_pheno.tmp.tsv &&\
	echo 'Family_ID' > $(out_dir)/tmp/genotype.samples.txt; tail -n +2 $(ped_file_name)*.ped | cut -f 1 >> $(out_dir)/tmp/genotype.samples.txt &&\
	python /data/genomics/cc926/scripts/merge_tables.py $(out_dir)/tmp/genotype.samples.txt  $(out_dir)/tmp/subset_pheno.tmp.tsv Family_ID Family_ID inner $(out_dir)/tmp/subset_pheno.tsv

$(out_dir)/plink.done: $(out_dir)/tmp/subset_pheno.tsv $(covariate_file)
	mkdir -p $(out_dir)/plink_results &&\
	plink --noweb --file $(ped_file_name) --1 --pheno $(out_dir)/tmp/subset_pheno.tsv --mpheno $(mpheno) --covar $(covariate_file) --logistic --beta --out $(out_dir)/plink_results/$(out_prefix) --adjust --maf 0.01 &&\
	touch plink.done

.PHONY: clean
clean:
	mv plink.done plink.old

