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
parser$add_argument("-s", "--setup",
    action = "store_true", default = FALSE,
    help = "Install needed R libraries to process things (only needed after Conda env is built fresh)"
)

# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults,
args <- parser$parse_args()

if (is.null(args$input_dir) || is.null(args$output_dir)) {
    write("Input and Output directory paths must be specified!\n", stderr())
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


