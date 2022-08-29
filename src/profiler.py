import argparse
import datetime
from pathlib import Path
import os
from SigProfilerMatrixGenerator import install as genInstall
from SigProfilerExtractor import sigpro as sig

VCF_DIR = "/usr/sigprof/vcfs"
# output directory name that will be used, it is created realtive to where this script runs in the container, /usr/sigprof/results is default
OUTPUT_DIR = "results" 

print(f"======= running the profiler for {VCF_DIR} ========")
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