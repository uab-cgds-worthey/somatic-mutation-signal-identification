# Chorangioma mutation identification

## Somatic mutation signal identification

Mutational signal profiling from somatic variation to detect disrupted mechanisms in somatic cells (typically cancers)
using https://github.com/AlexandrovLab/SigProfilerExtractor

_NOTE_: the documentation for the profiling tool isn't super awesome, and the options are sometimes wrong, consult
source code

### Loose and dirty setup of mutation signal identification

#### Docker on MacOS

1. build the docker image for build 38 and the simple CLI tool for using it
    ```
    docker build -t sigprof-testing:v0.0.1 .
    ```
2. run the container specifying inner path to vcf file(s) directory that was mounted
    ```
    docker run --rm -v "$(pwd)"/data:/usr/sigprof/vcfs -v "$(pwd)"/output:/usr/sigprof/results -it --entrypoint bash sigprof-testing:v0.0.1
    ```

This did not end well... It ran with max resources on all CPUs and did not complete. It seemingly stopped working after
about 24 hours and could have been due to a number of factors...

#### Conda environment on MacOS

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
