from SigProfilerExtractor import sigpro as sig

VCF_DIR = "/usr/sigprof/vcfs"
# output directory name that will be used, it is created realtive to where this script runs in the container, /usr/sigprof/results is default
OUTPUT_DIR = "results" 

print(f"======= running the profiler for {VCF_DIR} ========")
sig.sigProfilerExtractor(
    input_type="vcf", 
    output=OUTPUT_DIR, 
    input_data=VCF_DIR, 
    reference_genome="GRCh38",
    maximum_signatures=5)