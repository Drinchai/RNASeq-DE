#! /bin/bash

#########################################################
#
# Platform: NCI Gadi HPC
# Description: Creates input file for fastqc_run_parallel.pbs
#  for all samples in <cohort>.config
# Files are processed from largest to smallest for optimum E.
# Usage: Create <cohort>.config file using template.
# sh fastqc_make_input.sh <cohort>
# Author: Tracy Chew
# tracy.chew@sydney.edu.au
# Date last modified: 27/08/2020
#
# If you use this script towards a publication, please acknowledge the
# Sydney Informatics Hub (or co-authorship, where appropriate).
#
# Suggested acknowledgement:
# The authors acknowledge the scientific and technical assistance
# <or e.g. bioinformatics assistance of <PERSON>> of Sydney Informatics
# Hub and resources and services from the National Computational
# Infrastructure (NCI), which is supported by the Australian Government
# with access facilitated by the University of Sydney.
#
########################################################

if [ -z "$1" ]
then
	echo "Please run this script with the base name of your config file, e.g. sh bbduk_trim_make_input.sh samples"
	exit
fi

cohort=$1
config=../$cohort.config
logs=./Logs/fastQC
INPUTS=./Inputs
unsorted=${INPUTS}/fastqc.inputs_unsorted
input_file=${INPUTS}/fastqc.inputs
NCPUS=1

mkdir -p ${INPUTS}
mkdir -p ${logs}

rm -rf ${input_file}

while read -r fastq sampleid dataset reference seqcentre platform run_type library; do
	if [[ ! ${fastq} =~ ^#.*$ ]]; then
		basename=$(basename "$fastq" | cut -d. -f1)
		in=../${dataset}/${fastq}
		logdir=${logs}/${cohort}/${dataset}
		logfile=${logdir}/${basename}.oe
		out=../${dataset}\_fastQC
		bytes=$(ls -s "${in}" | awk '{print $1}')

		mkdir -p ${out}
		mkdir -p ${logdir}

		echo "${in},${out},${logfile},${NCPUS},${bytes}" >> ${unsorted}
	fi
done < "${config}"

# Reverse numeric sort bytes, comma delimited unsorted file
sort -rnk 5 -t ',' ${unsorted} > ${input_file}
rm -rf ${unsorted}

echo "Number of tasks for fastqc_run_parallel.pbs: $(wc -l ${input_file} | awk '{print $1}')"
