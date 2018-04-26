#; -*- mode: Makefile;-*
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

samples_file ?= european.txt
vcf ?= vcf
Sex ?= /nfs4/suffolk/DataGenomicsC/cc926/ukbb_phenotypes/Sex.tsv
covariate_file ?= covariates.txt
phenotype_file ?= BMR.mean.novascularproblems.tsv
phenotype_name ?= aa
out_name ?= out
out_dir ?= ./
conf ?= conf.sh
plot_dir ?= plots
pheno_dir ?= ./
results_dir ?= results
cov_names ?= bmi_bs,Array,Sex,Age_square,Age,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10

include $(conf)
all: $(pheno_dir)/$(phenotype_file).cov.tsv $(phenotype_name).split.done $(phenotype_name).hist1.done $(phenotype_name).filt.done $(phenotype_name).hist2.done $(phenotype_name).plink.done $(phenotype_name).association.done clean 


$(pheno_dir)/$(phenotype_file).cov.tsv: $(pheno_dir)/$(phenotype_file) $(Sex)
	echo $(pheno_dir)
	python /data/genomics/cc926/scripts/merge_tables.py $(pheno_dir)/$(phenotype_file) $(Sex) Sample_ID Sample_ID int inner $(pheno_dir)/$(phenotype_file).cov.tsv

$(phenotype_name).split.done: $(pheno_dir)/$(phenotype_file).cov.tsv 
	python /data/genomics/cc926/scripts/split_pheno_by_var.py $(pheno_dir)/$(phenotype_file).cov.tsv Sex $(pheno_dir)/$(phenotype_file)_Sex &&\
	touch $@

$(phenotype_name).hist1.done: $(phenotype_name).split.done
	mkdir -p $(plot_dir) &&\
	/usr/bin/Rscript /data/genomics/cc926/scripts/histogram.R $(pheno_dir)/$(phenotype_file)_Sex.males.tsv $(phenotype_name) "Freq" "" grey $(plot_dir)/$(phenotype_file).male.hist.png &&\
	/usr/bin/Rscript /data/genomics/cc926/scripts/histogram.R $(pheno_dir)/$(phenotype_file)_Sex.females.tsv $(phenotype_name) "Freq" "" grey $(plot_dir)/$(phenotype_file).female.hist.png &&\
	touch $@

$(phenotype_name).filt.done: $(phenotype_name).hist1.done
	python /data/genomics/cc926/scripts/filter_trait.py $(pheno_dir)/$(phenotype_file)_Sex.males.tsv $(phenotype_name) $(pheno_dir)/$(phenotype_name).male.filt.tsv &&\
	python /data/genomics/cc926/scripts/filter_trait.py $(pheno_dir)/$(phenotype_file)_Sex.females.tsv $(phenotype_name) $(pheno_dir)/$(phenotype_name).female.filt.tsv &&\
	touch $@

$(phenotype_name).hist2.done: $(phenotype_name).filt.done
	/usr/bin/Rscript /data/genomics/cc926/scripts/histogram.R $(pheno_dir)/$(phenotype_name).male.filt.tsv $(phenotype_name) "Freq" "" grey $(plot_dir)/$(phenotype_name).male.filt.hist.png &&\
	/usr/bin/Rscript /data/genomics/cc926/scripts/histogram.R $(pheno_dir)/$(phenotype_name).female.filt.tsv $(phenotype_name) "Freq" "" grey $(plot_dir)/$(phenotype_name).female.filt.hist.png &&\
	touch $@

$(phenotype_name).plink.done: $(phenotype_name).hist2.done
	@echo -e "Preparing plink file...\n"
	head -n1 $(pheno_dir)/$(phenotype_name).female.filt.tsv > $(pheno_dir)/$(phenotype_name).filt.ped.tmp &&\
	cat $(pheno_dir)/$(phenotype_name)*male.filt.tsv | grep -v Sample_ID >> $(pheno_dir)/$(phenotype_name).filt.ped.tmp &&\
	echo -e "FID\tIID\tM\tP\tSex\t"$(phenotype_name) > $(pheno_dir)/$(phenotype_name).filt.ped.tmp.tmp &&\
	awk -v OFS='\t' '{print $$1,$$1,0,0,$$4,$$2}' $(pheno_dir)/$(phenotype_name).filt.ped.tmp | grep -v Sample >> $(pheno_dir)/$(phenotype_name).filt.ped.tmp.tmp &&\
	python /data/genomics/cc926/scripts/merge_tables.py $(pheno_dir)/$(phenotype_name).filt.ped.tmp.tmp $(samples_file) FID FID str inner $(pheno_dir)/$(phenotype_name).filt.ped &&\
	echo -e "Done!"
	touch $@

$(phenotype_name).association.done: $(phenotype_name).plink.done
	mkdir -p $(results_dir) &&\
	/data/genomics/cc926/tools/rvtests/executable/rvtest --inVcf $(vcf) --dosage DS --pheno $(pheno_dir)/$(phenotype_name).filt.ped --covar $(covariate_file) --covar-name $(cov_names) --out $(results_dir)/$(out_name)  --single wald,score --inverseNormal --useResidualAsPhenotype &&\
	touch $@


.PHONY: clean
clean:
	rm $(phenotype_name)*.done
	rm $(pheno_dir)/$(phenotype_name).filt.ped.tmp*

