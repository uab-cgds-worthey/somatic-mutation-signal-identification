[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15467698.svg)](https://doi.org/10.5281/zenodo.15467698)

# Chorangioma mutation identification

## Identifying and removing FFPE induced deamination events

Part of the FFPE fixation process typically causes C > T deaminations in a semi-spontaneous manner, within certain
context in the genome. To correctly analyze samples at the variant level and for mutation signature identification use
of post-secondary processing tools is needed to identify and remove these false positives. After extensive review and
analysis [performed by Brandon on several tools]() it was determined that the easiest to use and performed relatively
well was the tool called [Ideafix](). Since it's an R package some work was done to make environment setup simple using
Ananconda3 and Mamba as well as a small wrapper script to provide an easy to use CLI to run the tool.

### Setup

First build the Anaconda3 environment for the tool

```
conda env create -f env/fix-ffpe-env.yml
```

or if you're using the Mamba wrapper/replacement for Conda

```
mamba env create -f env/fix-ffpe-env.yml
```

After the environment's been created activate it using

```
conda activate fixffpe
```

then run the setup/installer for all the R packages that need to be installed and used (only needed to be done once)

```
Rscript --vanilla src/fix_ffpe_vars.R --setup
```

Now you're ready to run the tool!

### Running Ideafix

The simple wrapper built for Ideafix operates on directories containing VCF files and outputs all "fixed" VCF into an
output folder. This setup was choosen as the input to mutation signature identification in SigProfiler is a directory of
VCF files.

To run the script just use the simple CLI it provides

```
Rscript --vanilla src/fix_ffpe_vars.R -i ~/Documents/Projects/PVP/mutational_signatures/pvp_unaffected_villi -o ~/Documents/Projects/PVP/mutational_signatures/ffpefixed_unaffected_villi -r /Users/bwilk/grch38_reference_genome/GRCh38/processed/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna
```

for further information you can acces the help documentation for the wrapper script by using the `--help` flag

```
Rscript --vanilla src/fix_ffpe_vars.R --help
usage: src/fix_ffpe_vars.R [-h] [-i PATH] [-o PATH] [-r PATH] [-s]

optional arguments:
  -h, --help            show this help message and exit
  -i PATH, --input_dir PATH
                        Path to the directory containing input VCF file(s) to
                        fix for FFPE mutations
  -o PATH, --output_dir PATH
                        Path to the directory to create and write fix VCFs to
  -r PATH, --ref_genome PATH
                        Path to the FASTA file of the reference genome
                        variants were called from
  -s, --setup           Install needed R libraries to process things (only
                        needed after Conda env is built fresh)

```

Please note that use of `Rscript --vanilla` to run the wrapper script will prevent R from trying to create and save
session information which is essential for the wrapper script to not create or store unnecessary information.

### Output from Ideafix

Following successful processing the wrapper script will have created a directory, using the name specified by the
`-o | --output_dir` option, with VCFs with names matching the input VCFs (appended with `.ideafix` in the file name)
where the FFPE induced variants have been removed. These can be used for downstream variant and mutational signature
identification.

## Confirmation of FFPE induced variant removal using FFPEsig

FFPEsig was developed to correct mutational signatures by adjusting for the expected signatures of FFPE induced
variants. In this way we can use it as an orthogonal tool to Ideafix to confirm that FFPE induced variants were
correctly identified and removed. Essentially if FFPEsig determines that little to no correction is needed in changing
the mutational signature profile then it validates the removal process performed by Ideafix.

### Setup

First build the Anaconda3 environment for the tool

```
conda env create -f env/ffpesig-env.yml
```

or if you're using the Mamba wrapper/replacement for Conda

```
mamba env create -f env/ffpesig-env.yml
```

After the environment's been created activate it using

```
conda activate ffpesig
```

then download the FFPEsig Python script from the authors GitHub repo to run (this has already been done for this repo)

```
curl -L https://raw.githubusercontent.com/QingliGuo/FFPEsig/main/FFPEsig.py -o etc/ffpesig/FFPEsig.py
```

Now you're ready to run the tool!

### Running FFPEsig

With the FFPEsig script downloaded the tool has a CLI and can be run on the count matrix output by SigProfilerExtractor.

```
cd etc/ffpesig
python FFPEsig.py -i data/ffpesig_input/ffpefixed_tumor_normal_called_all_hiconf.SBS96.all.csv -s "CHORANGIOMA" -l Unrepaired -o ../../data/ffpesig_output
python FFPEsig.py -i data/ffpesig_input/ffpefixed_tumor_normal_called_all_hiconf.SBS96.all.csv -s "NORM_VILLI" -l Unrepaired -o ../../data/ffpesig_output
```

Results will appear in (data/ffpesig_output)[data/ffpesig_output] and comparing the `before_correction` to the
`after_correction` results for each tissue will confirm that minimal correction was needed by FFPESig, confirming
that Ideafix correctly removed spurious variants caused by the FFPE fixation process.

## Somatic mutation signal identification

Mutational signal profiling from somatic variation to detect disrupted mechanisms in somatic cells (typically cancers)
using https://github.com/AlexandrovLab/SigProfilerExtractor

_NOTE_: the documentation for the profiling tool doesn't help with realizing some of the customizations (like
input/output paths or reference genome materials install paths) so it it recommended to check the
[source code for SigProfiler](https://github.com/AlexandrovLab/SigProfilerExtractor/blob/master/SigProfilerExtractor/sigpro.py)
when in doubt.

### Setup SigProfiler

A simple wrapper has been composed to facilitate running SigProfiler to overcome some of the limitations of hard-coded
paths built into the tool.

Ensure that your somatic variant VCF files are all located in a directory and are uncompressed (SigProfiler can't work
with Gzipped or Bgzipped VCFs yet).

First build the Anaconda3 environment for the tool

```
conda env create -f env/sigprofiler-env.yml
```

or if you're using the Mamba wrapper/replacement for Conda

```
mamba env create -f env/sigprofiler-env.yml
```

After the environment's been created activate it using

```
conda activate sigprofiler
```

and run the wrapper

```
python src/profiler.py --vcf_dir /Users/bwilk/Documents/Projects/PVP/mutational_signatures/pvp_chorangioma --outdir mutsig_chorangioma
```

output will be contained in the `--outdir` directory which is created under the parent directory of `--vcf_dir`. The
output directory being in the same location as the VCF input direcotry is an unfortunate limitation of SigProfiler and
not something that can be changed.

### Running SigProfiler

The simple wrapper built for SigProfiler operates on directories containing VCF files (uncompressed only) and outputs
all results into a directory at the same level as the specified input directory (sorry, no changing this functionality
as it's a hard-coded operation internal to SigProfiler).

To run the script just use the simple CLI it provides

```
python src/profiler.py -vd /Users/bwilk/Documents/Projects/PVP/mutational_signatures/ffpefixed_unaffected_villi --outdir mutsig_ffpefixed_unaffected_villi
```

This will download a version of the specified reference genome (GRCh38 is the default) in the background the first time
and store it within an accessible location within the Conda environments file locations (again, this can not be changed
because it's hard coded into SigProfiler). Following successful reference download the tool with coordinate setting up
and running SigProfiler.

for further information you can acces the help documentation for the wrapper script by using the `--help` flag

```
python src/profiler.py --help
usage: profiler.py [-h] -od [-vd | -mf] [-rg]

Simple wrapper for setup and use of SigProfiler

optional arguments:
  -h, --help            show this help message and exit
  -vd, --vcf_dir    Path to Directory containing VCFs to supply to SigProfiler (default: None)
  -mf, --matrix_file
                        Path to a TSV file contining the 96 SBS mutation counts across samples from SigMatrixGenerator for input to SigProfiler (default:
                        None)

Required Arguments:
  -od, --outdir     Output directory name where the SigProfiler should write results, will appear at same level as `vcf_dir` or `matrix_file` exists
                        (default: None)

Reference Options:
  -rg, --ref_genome
                        Reference Genome VCFs were aligned to (will download reference materials for SigProfiler if not already done) (default: GRCh38)
```

### SigProfiler output

Sigprofiler outputs information for a complete run into an output directory which continas information on the Single,
Double, and indel signatures identified (both De Novo and Composite from the
[COSMIC database of reference signatures](https://cancer.sanger.ac.uk/signatures/)). The outputs are in labeled
subdirectories per signature type (SBS, DBS, IDS) and contains PDFs of signatures as well as signature stats and other
accompanying information used in signature identification. More information can be found on the SigProfiler Wiki and
Youtube videos.
