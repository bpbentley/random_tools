#!/bin/bash

# Check if a file was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <species_list_file>"
    exit 1
fi

INPUT_FILE="$1"

# Count lines in the input file
SPP_NUM=$(wc -l < "$INPUT_FILE")
echo "Number of species in $INPUT_FILE: $SPP_NUM"

TOGA_URL="https://genome.senckenberg.de/download/TOGA/human_hg38_reference/"

while IFS=$'\t' read -r SPP CN TAXID TAX ABB ASSEMBLY REST; do
    echo "$SPP"

    # species abbreviation like zalCal
    ABBREV=$(echo "$SPP" | awk -F"_" '{print tolower(substr($1,1,3)) toupper(substr($2,1,1)) tolower(substr($2,2,2))}')
    mkdir -p "$ABBREV"
    cd "$ABBREV" || exit

    # find LEVEL from taxonomy string
    LEVEL=""
    while read -r d; do
        d=${d%/}
        if [[ "$TAX" == *"$d"* ]]; then
            LEVEL=$d
            break
        fi
    done < ../species_dirs.txt

    echo "$LEVEL"

    wget -q --no-check-certificate "${TOGA_URL}/${LEVEL}/${SPP// /_}__${CN// /_}__${ABB}/codonAlignments.allCESARexons.fa.gz"
	wget -q --no-check-certificate "${TOGA_URL}/${LEVEL}/${SPP// /_}__${CN// /_}__${ABB}/codonAlignments.fa.gz"
	wget -q --no-check-certificate "${TOGA_URL}/${LEVEL}/${SPP// /_}__${CN// /_}__${ABB}/geneAnnotation.bed.gz"
	wget -q --no-check-certificate "${TOGA_URL}/${LEVEL}/${SPP// /_}__${CN// /_}__${ABB}/geneAnnotation.gtf.gz"
    wget -q --no-check-certificate "${TOGA_URL}/${LEVEL}/${SPP// /_}__${CN// /_}__${ABB}/geneInactivatingMutations.tsv.gz"
	wget -q --no-check-certificate "${TOGA_URL}/${LEVEL}/${SPP// /_}__${CN// /_}__${ABB}/processedPseudogeneAnnotation.bed.gz"
	wget -q --no-check-certificate "${TOGA_URL}/${LEVEL}/${SPP// /_}__${CN// /_}__${ABB}/loss_summ_data.tsv.gz"
    wget -q --no-check-certificate "${TOGA_URL}/${LEVEL}/${SPP// /_}__${CN// /_}__${ABB}/orthologsClassification.tsv.gz"
	wget -q --no-check-certificate "${TOGA_URL}/${LEVEL}/${SPP// /_}__${CN// /_}__${ABB}/processedPseudogeneAnnotation.bed.gz"
	wget -q --no-check-certificate "${TOGA_URL}/${LEVEL}/${SPP// /_}__${CN// /_}__${ABB}/proteinAlignments.allCESARexons.fa.gz"
	wget -q --no-check-certificate "${TOGA_URL}/${LEVEL}/${SPP// /_}__${CN// /_}__${ABB}/pproteinAlignments.fa.gz"

    cd ..
done < "$INPUT_FILE"

echo "Done with all TOGA annotation downloads."