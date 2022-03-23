# Somatic mutation signal identification

Mutational signal profiling from somatic variation to detect disrupted mechanisms in somatic cells (typically cancers) using https://github.com/AlexandrovLab/SigProfilerExtractor

*NOTE*: the documentation for the profiling tool isn't super awesome, and the options are sometimes wrong, consult source code

# Loose and dirty setup of this
  1. build the docker image for build 38 and the simple CLI tool for using it
    ```
    docker build -t sigprof-testing:v0.0.1 .
    ```
  2. run the container specifying inner path to vcf file(s) directory that was mounted
    ```
    docker run --rm -v "$(pwd)"/data:/usr/sigprof/vcfs -v "$(pwd)"/output:/usr/sigprof/results -it --entrypoint bash sigprof-testing:v0.0.1
    ```