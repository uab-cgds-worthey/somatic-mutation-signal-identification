#!/usr/bin/env bash
APP_ROOT="$(dirname "$(dirname "$(readlink -fm "$0")")")"
echo "Working dir: ${APP_ROOT}"

set -eo pipefail

function mkdir_download {
    local dlpath=$1      # Save first argument in a variable
    shift                # Shift all arguments to the left (original $1 gets lost)
    local dlarray=("$@") # Rebuild the array with rest of arguments

    mkdir -p "${dlpath}"
    for url in "${dlarray[@]}"; do
        echo "Downloading ${url}"
        dlfile=$(basename ${url})
        curl -o "${dlpath}/${dlfile}" "$url"
    done
}

echo "Downloading models..."
MODELS_PATH="${APP_ROOT}/data/dig_driver/models/"
models=(
    "http://cb.csail.mit.edu/cb/DIG/downloads/mutation_maps/Female_reproductive_system_tumors_SNV_MNV_INDEL_msi_low.Pretrained.h5"
    "http://cb.csail.mit.edu/cb/DIG/downloads/mutation_maps/Uterus-AdenoCA_SNV_MNV_INDEL_msi_low.Pretrained.h5"
    "http://cb.csail.mit.edu/cb/DIG/downloads/mutation_maps/Pancan_SNV_MNV_INDEL.Pretrained.h5"
)
mkdir_download "${MODELS_PATH}" "${models[@]}"

echo "Downloading support data files..."
SUPP_PATH="${APP_ROOT}/data/dig_driver/support/"
support=(
    "http://cb.csail.mit.edu/cb/DIG/downloads/dig_data_files/element_data.h5"
    "http://cb.csail.mit.edu/cb/DIG/downloads/dig_data_files/gene_data.h5"
    "http://cb.csail.mit.edu/cb/DIG/downloads/dig_data_files/genome_counts.h5"
    "http://cb.csail.mit.edu/cb/DIG/downloads/dig_data_files/hg19.fasta"
    "http://cb.csail.mit.edu/cb/DIG/downloads/dig_data_files/hg19.fasta.fai"
    "http://cb.csail.mit.edu/cb/DIG/downloads/dig_data_files/sites_data.h5"
)
mkdir_download "${SUPP_PATH}" "${support[@]}"

echo "Downloading Non-coding annotation data files..."
ANNO_PATH="${APP_ROOT}/data/dig_driver/annotation/noncoding/"
noncoding=(
    "http://cb.csail.mit.edu/cb/DIG/downloads/annotions/noncoding/grch37.canonical_5utr_with_splice.bed"
    "http://cb.csail.mit.edu/cb/DIG/downloads/annotions/noncoding/grch37.PCAWG_noncoding.bed"
    "http://cb.csail.mit.edu/cb/DIG/downloads/annotions/noncoding/grch37.TP53_5UTR_exon1.bed"
    "http://cb.csail.mit.edu/cb/DIG/downloads/annotions/noncoding/README.txt"
)
mkdir_download "${ANNO_PATH}" "${noncoding[@]}"

echo "Downloading splicing annotation data files..."
ANNO_PATH="${APP_ROOT}/data/dig_driver/annotation/splice/"
splice=(
    "http://cb.csail.mit.edu/cb/DIG/downloads/annotions/splicing/grch37.spliceAI_CANONICAL.txt.gz"
    "http://cb.csail.mit.edu/cb/DIG/downloads/annotions/splicing/grch37.spliceAI_CRYPTIC.coding.txt.gz"
    "http://cb.csail.mit.edu/cb/DIG/downloads/annotions/splicing/grch37.spliceAI_CRYPTIC.noncoding.txt.gz"
    "http://cb.csail.mit.edu/cb/DIG/downloads/annotions/splicing/grch37.spliceAI_CRYPTIC.txt.gz"
    "http://cb.csail.mit.edu/cb/DIG/downloads/annotions/splicing/README.txt"
)
mkdir_download "${ANNO_PATH}" "${splice[@]}"

echo "Downloading coding annotation data files..."
ANNO_PATH="${APP_ROOT}/data/dig_driver/annotation/coding/"
coding=(
    "http://cb.csail.mit.edu/cb/DIG/downloads/annotions/coding/grch37.coding_sequence.bed"
    "http://cb.csail.mit.edu/cb/DIG/downloads/annotions/coding/grch37.CGI_activating_snvs.txt.gz"
    "http://cb.csail.mit.edu/cb/DIG/downloads/annotions/coding/grch37.missense_CADD_15.txt.gz"
    "http://cb.csail.mit.edu/cb/DIG/downloads/annotions/coding/README.txt"
)
mkdir_download "${ANNO_PATH}" "${coding[@]}"
