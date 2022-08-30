import argparse
import datetime
import inspect
from pathlib import Path
import os
from SigProfilerMatrixGenerator import install as genInstall
from SigProfilerExtractor import sigpro as sig


REF_GENOMES = {"GRCh37", "GRCh38", "mm9", "mm10", "rn6"}


def check_install_ref(genome):
    """_summary_

    This function is a total hack by looking at the source code of SigProfiler to determine where the developers
    hard-coded reference genome files to be stored. See https://github.com/AlexandrovLab/SigProfilerMatrixGenerator/blob/master/SigProfilerMatrixGenerator/scripts/SigProfilerMatrixGeneratorFunc.py#L255
    for the precise location determination. Basically it installs files in the package install location that PIP puts
    SigProfilerMatrixGenerator into. This function allows for reliably checking that location to see if the reference
    files for SigProfiler need download. This is terribly risky as it depends on the developers of SigProfiler to
    not change this pathing, but not much we can do about that.

    """

    print(
        f"Checking if {genome} Reference Genome materials for SigProfiler needs to be downloaded..."
    )
    from SigProfilerMatrixGenerator.scripts import (
        SigProfilerMatrixGeneratorFunc as ref_genome_downloader,
    )

    ref_genome_dir, _ = os.path.split(
        os.path.dirname(inspect.getfile(ref_genome_downloader))
    )
    ref_genome_dir = (
        Path(ref_genome_dir) / "references" / "chromosomes" / "tsb" / "genome"
    )
    if not ref_genome_dir.is_dir():
        print(f"Downloading {genome} Reference Genome materials for SigProfiler...")
        genInstall.install(genome)
    else:
        print(
            f"Found {genome} Reference Genome materials for SigProfiler! Skipping download."
        )


def run_sigprofiler(working_dir, vcf_input, output_dir_name, genome):

    # SigProfiler bases input and output paths off of the current working directory so switching to the directory
    # where the VCF input directory is located before running the tool is needed to allow flexibility in input and
    # output location
    os.chdir(working_dir)

    print(f"======= running the profiler for {str(working_dir / vcf_input)} ========")
    sig.sigProfilerExtractor(
        input_type="vcf",
        output=output_dir_name,
        input_data=vcf_input,
        reference_genome=genome,
        opportunity_genome=genome,
        minimum_signatures=1,
        maximum_signatures=10,
        collapse_to_SBS96=False,
        get_all_signature_matrices=False,
    )


def is_valid_output_file(p, arg):
    if os.access(Path(os.path.expandvars(arg)).parent, os.W_OK):
        return os.path.expandvars(arg)
    else:
        p.error(f"Output file {arg} can't be accessed or is invalid!")


def is_valid_file(p, arg):
    if not Path(os.path.expandvars(arg)).is_file():
        p.error("The file '%s' does not exist!" % arg)
    else:
        return os.path.expandvars(arg)


def is_valid_dir(p, arg):
    if not Path(os.path.expandvars(arg)).is_dir():
        p.error("The directory '%s' does not exist!" % arg)
    else:
        return os.path.expandvars(arg)


if __name__ == "__main__":

    PARSER = argparse.ArgumentParser(
        description="Simple wrapper for setup and use of SigProfiler",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )

    REQUIRED_ARGS = PARSER.add_argument_group("Required Arguments")

    REQUIRED_ARGS.add_argument(
        "-vd",
        "--vcf_dir",
        help="Path to Directory containing VCFs to supply to SigProfiler",
        required=True,
        type=lambda x: is_valid_dir(PARSER, x),
        metavar="\b",
    )

    REQUIRED_ARGS.add_argument(
        "-od",
        "--outdir",
        help="Output directory name where the SigProfiler should write results, will appear at same level as `vcf_dir` exists",
        required=True,
        type=str,
        metavar="\b",
    )

    REFERENCE_GENOME = PARSER.add_argument_group("Reference Options")

    REFERENCE_GENOME.add_argument(
        "-rg",
        "--ref_genome",
        help="Reference Genome VCFs were aligned to (will download reference materials for SigProfiler if not already done)",
        default="GRCh38",
        type=str,
        choices=REF_GENOMES,
        metavar="\b",
    )

    ARGS = PARSER.parse_args()

    check_install_ref(ARGS.ref_genome)

    vcfdir = Path(ARGS.vcf_dir)
    run_sigprofiler(vcfdir.parent, vcfdir.name, ARGS.outdir, ARGS.genome)
