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

### Failed setup and use of SigProfiler

This are simple notes marking past attempts for using SigProfiler which didn't work correctly. This is kept purely for
reminder notes on what was done in the development of the wrapper for SigProfiler.

#### Docker on MacOS

This did not end well... It ran with max resources on all CPUs and did not complete. It seemingly stopped working after
about 24 hours and could have been due to a number of factors...

1. build the docker image for build 38 and the simple CLI tool for using it
    ```
    docker build -t sigprof-testing:v0.0.1 .
    ```
2. run the container specifying inner path to vcf file(s) directory that was mounted
    ```
    docker run --rm -v "$(pwd)"/data:/usr/sigprof/vcfs -v "$(pwd)"/output:/usr/sigprof/results -it --entrypoint bash sigprof-testing:v0.0.1
    ```

#### Conda environment on MacOS

This setup ran but was hard coded to certain paths and very specific to a single machine setup. Ultimately the more this
tool was needing to be run the more difficult it was to use this.

1. build the conda env
    1. `conda env create -f env/sigprofiler-env.yml`
2. activate the env
    1. `conda activate sigprofiler`
3. install the reference genome materials needed to run the sigprofiler
    1. `cd data`
    2. `python -c "from SigProfilerMatrixGenerator import install as genInstall; genInstall.install('GRCh38')"`
    3. _NOTE_: the profiler, or the script it's run from, must run from this directory as well due to it expecting a
       certain path for this information being installed
    4. _WARNING_: This can be a long running process so don't run in a setting where the task could be accidentally
       terminated
4. start an interactive python session
    1. `python`
5. Import SigProfileExtractor and run the application
    1. ```
           from SigProfilerExtractor import sigpro as sig
           sig.sigProfilerExtractor(
               input_type="vcf",
               output="results",
               input_data="pvp_input",
               reference_genome="GRCh38",
               opportunity_genome="GRCh38",
               minimum_signatures=1,
               maximum_signatures=10,
               cosmic_version=3.3,
               collapse_to_SBS96=False,
               get_all_signature_matrices=False)
       ```
6. the profiler should complete relatively quickly with a single sample. Results will appear in `data/results/`

## Somatic Driver variant identification

Testing new tool reported in
["Genome-wide mapping of somatic mutation rates uncovers drivers of cancer"](https://www.nature.com/articles/s41587-022-01353-8)
that should aid in driver variant (previously identified and novel) identification including those in non-coding and
regulatory regions that could be confirmed with RNASeq.

**WARNING**: The authors of this tool note that use of the tool could be "spurious" when analyzing a type of cancer
against a pretrained model that doesn't match the mechanisms/signatures of cancers provided in the pretrained models.
see this [GitHub Issue](https://github.com/maxwellsh/DIGDriver/issues/2#issuecomment-1168689782) explaining more from
the authors of the tool.

**Annoyance**: The authors recommend using liftover to `hg19` perform analysis of datasets aligned to `GRCh38/hg38`. See
their [recommendation](https://github.com/maxwellsh/DIGDriver/issues/2#issuecomment-1168689782) notes on this process.
This isn't the greatest but if it's what it take to use the tool it may be an acceptable limitation.

### Conda environment

-   [Conda environment info](https://anaconda.org/mutation_density/digdriver)
-   [Install and setup wiki](https://github.com/maxwellsh/DIGDriver/wiki)

1. Build the conda environment as defined in the [yaml file](./env/digdriver-env.yml) for DigDriver
    1. ```sh
         conda env create -f env/digdriver-env.yml
       ```
2. Download the required [supporting data files](https://github.com/maxwellsh/DIGDriver/wiki/02:-Data-files) for running
   DigDiver
    1. Download the pretrained models that might work out of the box ( Brandon's best guess ¯\_(ツ)\_/¯ ) using the
       [download script](./setup/downloadDigModels.sh)
    2. ```sh
         ./setup/downloadDigModels.sh
       ```
    3. All supporting data will be downloaded under `data/dig_driver/` for use with DigDriver
