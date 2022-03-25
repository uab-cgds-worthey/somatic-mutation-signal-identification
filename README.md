# Somatic mutation signal identification

Mutational signal profiling from somatic variation to detect disrupted mechanisms in somatic cells (typically cancers) using https://github.com/AlexandrovLab/SigProfilerExtractor

*NOTE*: the documentation for the profiling tool isn't super awesome, and the options are sometimes wrong, consult source code

# Loose and dirty setup of this

## Docker on MacOS
  1. build the docker image for build 38 and the simple CLI tool for using it
        ```
        docker build -t sigprof-testing:v0.0.1 .
        ```
  2. run the container specifying inner path to vcf file(s) directory that was mounted
        ```
        docker run --rm -v "$(pwd)"/data:/usr/sigprof/vcfs -v "$(pwd)"/output:/usr/sigprof/results -it --entrypoint bash sigprof-testing:v0.0.1
        ```

This did not end well... It ran with max resources on all CPUs and did not complete. It seemely stopped working after
about 24 hours and could have been due to a number of factors...

## Conda environment on MacOS
  1. build the conda env
     1. `conda env create -f env/sigprofiler-env.yml`
  2. activate the env
     1. `conda activate sigprofiler`
  3. install the reference genome materials needed to run the sigprofiler
     1. `cd data`
     2. `python -c "from SigProfilerMatrixGenerator import install as genInstall; genInstall.install('GRCh38')"`
     3. *NOTE*: the profiler, or the script it's run from, must run from this directory as well due to it expecting a certain path for tthis information being installed
     4. *WARNING*: This can be a long running process so don't run in a setting where the task could be accidentally terminated
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
                cosmic_version=3.2,
                collapse_to_SBS96=False,
                get_all_signature_matrices=False)
        ```
  6. the profiler should complete relatively quickly with a single sample. Results will appear in `data/results/`
  7. 