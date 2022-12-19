# A simple script to process VCF files and produce FFPE induced variants from the VCFs for input into SigProfiler

suppressPackageStartupMessages(library("argparse"))

# create parser object
parser <- ArgumentParser()

# specify our desired options
# by default ArgumentParser will add an help option
parser$add_argument("-i", "--input_dir",
    type = "character",
    metavar = "PATH",
    help = "Path to the directory containing input VCF file(s) to fix for FFPE mutations"
)

parser$add_argument("-o", "--output_dir",
    type = "character",
    metavar = "PATH",
    help = "Path to the directory to create and write fix VCFs to"
)

parser$add_argument("-r", "--ref_genome",
    type = "character",
    metavar = "PATH",
    help = "Path to the FASTA file of the reference genome variants were called from"
)

parser$add_argument("-s", "--setup",
    action = "store_true", default = FALSE,
    help = "Install needed R libraries to process things (only needed after Conda env is built fresh)"
)

# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults,
args <- parser$parse_args()

if (is.null(args$input_dir) || is.null(args$output_dir) || is.null(args$ref_genome)) {
    write("Input and Output directory and referece genome paths must be specified!\n", stderr())
    stop("Incorrect Input")
}

if (args$setup) {
    print("Running setup...")
    ##### Needed for specific model version used by the tool and noted by failure of Vignette to build #####
    # install the language server for vscode
    install.packages("languageserver")
    install.packages("httpgd")
    # specific version release info https://h2o-release.s3.amazonaws.com/h2o/rel-xu/1/index.html
    if (!require("devtools")) install.packages("devtools")

    # The following two commands remove any previously installed H2O packages for R.
    if ("package:h2o" %in% search()) {
        detach("package:h2o", unload = TRUE)
    }
    if ("h2o" %in% rownames(installed.packages())) {
        remove.packages("h2o")
    }

    # Next, we download packages that H2O depends on.
    pkgs <- c("RCurl", "jsonlite")
    for (pkg in pkgs) {
        if (!(pkg %in% rownames(installed.packages()))) {
            install.packages(pkg)
        }
    }

    # Now we download, install and initialize the H2O package for R.
    install.packages("h2o", type = "source", repos = "https://h2o-release.s3.amazonaws.com/h2o/rel-xu/1/R")
}

# load H2O and start up an H2O cluster
library("stringr")
library(h2o)
library(ideafix)
h2o.init()

if (!dir.exists(args$output_dir)) dir.create(args$output_dir)
vcf_files <- list.files(args$input_dir, pattern = ".+\\.vcf", full.names = TRUE)
for (vcf in vcf_files) {
    cat("Fixing ", basename(vcf), "\n")
    # get the descriptors for the variants using the VCF and ref genome
    descriptors <- get_descriptors(vcf_filename = vcf, fasta_filename = args$ref_genome)

    # predict with the random forest model
    predictions_RF <- classify_variants(variant_descriptors = descriptors, algorithm = "RF")

    # annotate deamination info filag to vcf for downstream filtering
    outname <- str_replace(basename(vcf), ".vcf", ".ideafix")
    annotate_deaminations(classification = predictions_RF, format = "vcf", vcf_filename = vcf, outfolder = args$output_dir, outname = outname)

    # use BCFTools to filter out the deamination flagged variants from the VCF
    output_vcf <- file.path(args$output_dir, paste(outname, ".vcf", sep = ""))
    cmd <- sprintf("bcftools view --exclude 'INFO/DEAMINATION=\"deamination\"' %s -Ov -o %s_tmp.vcf; mv %s_tmp.vcf %s", output_vcf, output_vcf, output_vcf, output_vcf)
    system(cmd, intern = TRUE)

    # log the number of variants removed due to predicted deamination
    cat(format(sum(predictions_RF$DEAMINATION == "deamination")), "variants predicted to be deamination induced and removed from", output_vcf, "\n")
}

# Shutdown H20 cluster when things are done processing
h2o.shutdown(prompt = FALSE)
