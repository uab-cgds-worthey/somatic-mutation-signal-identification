# Chorangioma mutation identification

## Somatic mutation signal identification

Mutational signal profiling from somatic variation to detect disrupted mechanisms in somatic cells (typically cancers)
using https://github.com/AlexandrovLab/SigProfilerExtractor

_NOTE_: the documentation for the profiling tool doesn't help with realizing some of the customizations (like
input/output paths or reference genome materials install paths) so it it recommended to check the
[source code for SigProfiler](https://github.com/AlexandrovLab/SigProfilerExtractor/blob/master/SigProfilerExtractor/sigpro.py)
when in doubt.

## Running SigProfiler

A simple wrapper has been composed to facilitate running SigProfiler to overcome some of the limitations of hard-coded
paths built into the tool.

Ensure that your somatic variant VCF files are all located in a directory and are uncompressed (SigProfiler can't work
with Gzipped or Bgzipped VCFs yet).

First build the Anaconda3 environment for the tool

```
conda env create -f env/sigprofiler-env.yml
```

activate the environment

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

## Failed setup and use of SigProfiler

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
